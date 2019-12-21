import UIKit

public enum Alpacka {
    /// An object for packing items into a containing area.
    public struct Packer<Item> where Item: Hashable, Item: Sized {
        
        /**
         Pack items into a containing area.
         
         Switch on result to check for overflow.
         
         - Parameters:
         - items: Hashable, sized items that can be packed into a containing area.
         - size: The container to arrange items within.
         - Returns: `.success([Item: CGPoint])` or `.overFlow([Item: CGPoint], overFlow: [Item])` depending on whether or not all items fit in the space using Alpacka's algorithm.
         */
        public enum SortMethod {
            case area
            case height
            case width
            case perimeter
        }
        public func pack(_ items: [Item], in size: CGSize, sorting: SortMethod = .height) -> Result {
            var packed: Section<Item> = .space(Size(size))
            var overFlow = [Item]()
            var added = [Item]()
            var sorted = [Item]()
            switch sorting {
            case .area:
                sorted = items.sorted {
                    $0.size.height * $0.size.width > $1.size.height * $1.size.width
                }
            case .height:
                sorted = items.sorted {
                    $0.size.height > $1.size.height
                }
            case .width:
                sorted = items.sorted {
                    $0.size.width > $1.size.width
                }
            case .perimeter:
                sorted = items.sorted {
                    $0.size.width + $0.size.height > $1.size.width + $1.size.height
                }
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
            if overFlow.isEmpty {
                return .success(packedDict)
            } else {
                return .overFlow(packedDict, overFlow: overFlow)
            }
        }
        
        /**
         Automatically applies new origin to items after packing & REMOVES items that did not fit from array.
         
         Check for overflow by switching on return value.
         
         - Parameters:
           - items: Hashable, sized items that can be packed into a containing area.
           - origin: Writable keyPath of the origin that you want to modify to arrange items.
           - size: The container to arrange items within.
         
         ```
        var packer = Alpacka.Packer<MyItemType>()
        packer.pack(&myItemArray, origin: \.origin, in: CGSize(width: 100, height: 100))
        */
        @discardableResult
        public func pack(_ items: inout [Item], origin: WritableKeyPath<Item, CGPoint>, in size: CGSize, sorting: SortMethod = .height) -> Result {
            let result = pack(items, in: size, sorting: sorting)
            var itemsToMutate = [Item: CGPoint]()
            var overFlow = [Item]()
            switch result {
            case let .success(packed):
                itemsToMutate = packed
            case let .overFlow(packed, overFlow: over):
                itemsToMutate = packed
                overFlow = over
            }
            items = Array(Set(items).subtracting(Set(overFlow)))
            items.updateEach { item in
                guard let point = itemsToMutate[item] else { return }
                item[keyPath: origin] = point
            }
            
            return result
        }
        
        public init() {}
        
        public enum Result {
            case success(_ packedItems: [Item: CGPoint])
            case overFlow(_ packedItems: [Item: CGPoint], overFlow: [Item])
        }
    }
}
