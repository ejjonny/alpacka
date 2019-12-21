import UIKit

public enum Alpacka {
    /** An object for packing items into a containing area.
     
     ```
     let packer = Packer<MyObjectThatConformsToSized>()
     packer.pack()
     
     ```
     */
    
    public struct Packer<Item> where Item: Hashable, Item: Sized {
        /// Pack items into a containing area.
        ///
        /// Overflowing items will be added to the `.overFlow` property. Calling `pack(_:in:)` will clear this overflow array so store anything that you need to keep track of, or make a new `Packer` object before attempting to pack again.
        /// - Parameters:
        ///   - items: Hashable, sized items that can be packed into a containing area.
        ///   - size: The container to arrange items within.
        /// - Returns: A dictionary with your items as keys, and their proposed origin relative to the container.
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
        
        public enum Result {
            case success(_ packedItems: [Item: CGPoint])
            case overFlow(_ packedItems: [Item: CGPoint], overFlow: [Item])
        }
    }
}

extension MutableCollection {
  mutating func updateEach(_ update: (inout Element) -> Void) {
    for i in indices {
      update(&self[i])
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
