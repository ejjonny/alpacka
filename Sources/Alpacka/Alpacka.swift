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
        public mutating func pack(_ items: [Item], in size: CGSize) -> Result {
            var packed: Section<Item> = .space(Size(size))
            var overFlow = [Item]()
            items.lazy.sorted { first, second in
                first.size.height > second.size.height
            }.forEach { item in
                guard let attempt = packed.traverseAndPlace(item) else { overFlow.append(item) ; return }
                packed = attempt
            }
            let packedDict = items.reduce([Item: CGPoint]()) { current, next in
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
         Automatically applies new origin to items after packing.
         
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
        public mutating func pack(_ items: inout [Item], origin: WritableKeyPath<Item, CGPoint>, in size: CGSize) -> Result {
            let result = pack(items, in: size)
            var itemsToMutate = [Item: CGPoint]()
            switch result {
            case let .success(packed):
                itemsToMutate = packed
            case let .overFlow(packed, overFlow: _):
                itemsToMutate = packed
            }
            items.updateEach { item in
                guard let point  = itemsToMutate[item] else { return }
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

public func nut() {
    struct Thing: Hashable, Sized {
        var packingSize: CGSize {
            return CGSize(width: 0, height: 0)
        }
        var origin: CGPoint = CGPoint(x: 0, y: 0)

        func hash(into hasher: inout Hasher) {
            hasher.combine(origin.x)
            hasher.combine(origin.y)
        }
    }
    var items = [
        Thing(),
        Thing()
    ]
    var packer = Alpacka.Packer<Thing>()
    packer.pack(&items, origin: \.origin, in: CGSize(width: 100, height: 100))
}
