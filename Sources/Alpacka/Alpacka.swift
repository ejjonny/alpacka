
import Combine
import Foundation

/// Alpacka namespace. Use static method `Alpacka.pack`.
public enum Alpacka {
    /**
     Packs items within the provided container & applies the new origin to the `WritableKeyPath` that is provided.
     
     If any items do not fit this method will return the `.overFlow` result (not an error), containing a packed items associated value & an overFlow items associated value. These arrays will not have items in common. Check for overflow by switching on return value. _Note that the result is not stable. Calling pack twice with the same input will not produce the same result._
     
     - parameter items: Hashable, sized items to be packed into a containing area.
     - parameter origin: A `WritableKeyPath` of the origin property on the items that Alpacka can modify to arrange the items. The type of this keypath must conform to `OriginConvertible`. _Alpacka adds UIKit / AppKit CGPoint conformance to this protocol._
     - parameter size: The container size to arrange items within.
     - Returns: A publisher that publishes the result of the packing attempt. *(This is a deferred publisher that will be subscribed to on DispatchQueue.global(qos: default). The result will be calculated when a subscriber requests a value.)*
     
     ```
     Alpacka.pack(myItemArray, origin: \.myItemOrigin, in: .init(w: 100, h: 100))
     .sink { result in
     // Check for overflow & proceed with arranged items here.
     }
     .store(in: &cancellables)
     */
    public static func pack<Item, Origin>(_ items: [Item], origin: WritableKeyPath<Item, Origin>, in size: Size) -> AnyPublisher<Result<Item>, Never> where Item: Hashable, Item: Sized, Origin: OriginConvertible {
        pack(items, origin: origin, in: size, scheduler: DispatchQueue.global(qos: .default))
    }
    /**
     Packs items within the provided container & applies the new origin to the `WritableKeyPath` that is provided.
     
     If any items do not fit this method will return the `.overFlow` result (not an error), containing a packed items associated value & an overFlow items associated value. These arrays will not have items in common. Check for overflow by switching on return value. _Note that the result is not stable. Calling pack twice with the same input will not produce the same result._
     
     - parameter items: Hashable, sized items to be packed into a containing area.
     - parameter origin: A `WritableKeyPath` of the origin property on the items that Alpacka can modify to arrange the items. The type of this keypath must conform to `OriginConvertible`. _Alpacka adds UIKit / AppKit CGPoint conformance to this protocol._
     - parameter size: The container size to arrange items within.
     - parameter scheduler: The scheduler to perform work on. _This parameter can be omitted to use the default background queue. (DispatchQueue.global(qos: .default))_
     - Returns: A publisher that publishes the result of the packing attempt. *(This is a deferred publisher that will be subscribed to on the specified scheduler. The result will be calculated when a subscriber requests a value.)*
     
     ```
     Alpacka.pack(myItemArray, origin: \.myItemOrigin, in: .init(w: 100, h: 100))
     .sink { result in
     // Check for overflow & proceed with arranged items here.
     }
     .store(in: &cancellables)
     */
    public static func pack<Item, Origin, T: Scheduler>(_ items: [Item], origin: WritableKeyPath<Item, Origin>, in size: Size, scheduler: T) -> AnyPublisher<Result<Item>, Never> where Item: Hashable, Item: Sized, Origin: OriginConvertible {
        Deferred {
            Future<Result<Item>, Never> { promise in
                var items = items
                let result = pack(items, in: size)
                var itemsToMutate = [Item: Point]()
                itemsToMutate = result.packed
                items = Array(Set(items).subtracting(Set(result.overFlow)))
                items.updateEach { item in
                    guard let point = itemsToMutate[item] else { return }
                    item[keyPath: origin] = Origin(point)
                }
                if result.overFlow.isEmpty {
                    promise(.success(.packed(items)))
                } else {
                    promise(.success(.overFlow(items, overFlow: result.overFlow)))
                }
            }
        }
        .subscribe(on: scheduler)
        .eraseToAnyPublisher()
    }
    
    /// The result of a packing attempt.
    ///
    /// Either every item was successfully packed into the container or a number of items did not fit.
    public enum Result<Item> where Item: Hashable, Item: Sized {
        case packed(_ packedItems: [Item])
        case overFlow(_ packedItems: [Item], overFlow: [Item])
    }
    
    internal static func pack<Item>(_ items: [Item], in size: Size) -> (packed: [Item: Point], overFlow: [Item]) where Item: Hashable, Item: Sized {
        var packed: Section<Item> = .space(size)
        var overFlow = [Item]()
        var added = [Item]()
        let sorted = items.sorted {
            $0.size.height > $1.size.height && $0.hashValue > $1.hashValue
        }
        for (item, index) in zip(sorted, sorted.indices) {
            guard let attempt = packed.traverseAndPlace(item) else {
                overFlow.append(item)
                if packed.areaUsed() >= size.area {
                    overFlow.append(contentsOf: sorted[(index + 1)...])
                    break
                }
                continue
            }
            packed = attempt
            added.append(item)
        }
        let packedDict = added.reduce([Item: Point]()) { current, next in
            guard let origin = packed.origin(next) else { assert(false) ; return current }
            var dict = current
            dict[next] = origin
            return dict
        }
        return (packedDict, overFlow)
    }
}
