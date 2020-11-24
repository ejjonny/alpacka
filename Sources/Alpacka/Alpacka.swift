#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

public enum Alpacka {
    /// An object for packing items into a containing area.
    public struct Packer<Item> where Item: Hashable, Item: Sized {
        
        /**
         Packs items & applies the new origin to the `WritableKeyPath` that is provided.
         
         If any items do not fit this method will return the `.overFlow` result, containing a packed items associated value & an overFlow items associated value. These arrays will not have items in common. Check for overflow by switching on return value.
         
         - Parameters:
           - items: Hashable, sized items to be packed into a containing area.
           - origin: Writable keyPath of the origin on your items that you want to modify to arrange them.
           - size: The container size to arrange items within.
         
         ```
        var packer = Alpacka.Packer<MyItemType>()
        let packedItems = packer.pack(myItemArray, origin: \.myItemOrigin, in: CGSize(width: 100, height: 100))
        */
        @discardableResult
        public func pack(_ items: [Item], origin: WritableKeyPath<Item, CGPoint>, in size: CGSize) -> Result {
            var items = items
            let result = pack(items, in: size)
            var itemsToMutate = [Item: CGPoint]()
            itemsToMutate = result.packed
            items = Array(Set(items).subtracting(Set(result.overFlow)))
            items.updateEach { item in
                guard let point = itemsToMutate[item] else { return }
                item[keyPath: origin] = point
            }
            if result.overFlow.isEmpty {
                return .success(items)
            } else {
                return .overFlow(items, overFlow: result.overFlow)
            }
        }
        
        /// An asynchronous option for packing a higher number of objects.
        /// - Parameters:
        ///   - items: Hashable, sized items to be packed into a containing area.
        ///   - origin: Writable keyPath of the origin on your items that you want to modify to arrange them.
        ///   - size: The container size to arrange items within.
        ///   - qos: The quality of service to use on the background thread where work will be performed. Defaults to `.default`.
        ///   - completion: The code to execute when work is completed. This method will complete with `.success` normally or `.overFlow` if all items did not fit in the given container size.
        public func pack(_ items: [Item], origin: WritableKeyPath<Item, CGPoint>, in size: CGSize, qos: DispatchQoS.QoSClass = .default, completion: @escaping (Result) -> ()) {
            DispatchQueue.global(qos: qos).async {
                completion(self.pack(items, origin: origin, in: size))
            }
        }

        public init() {}
        
        public enum Result {
            case success(_ packedItems: [Item])
            case overFlow(_ packedItems: [Item], overFlow: [Item])
        }
        
        internal func pack(_ items: [Item], in size: CGSize) -> (packed: [Item: CGPoint], overFlow: [Item]) {
            var packed: Section<Item> = .space(Size(size))
            var overFlow = [Item]()
            var added = [Item]()
            let sorted = items.sorted {
                $0.size.height > $1.size.height
            }
            for (item, index) in zip(sorted, sorted.indices) {
                guard let attempt = packed.traverseAndPlace(item) else {
                    overFlow.append(item)
                    if packed.areaUsed() >= Size(size).area {
                        overFlow.append(contentsOf: sorted[(index + 1)...])
                        break
                    }
                    continue
                }
                packed = attempt
                added.append(item)
            }
            let packedDict = added.reduce([Item: CGPoint]()) { current, next in
                guard let origin = packed.origin(next) else { assert(false) ; return current }
                var dict = current
                dict[next] = origin.cgPoint
                return dict
            }
            return (packedDict, overFlow)
        }
    }
}
