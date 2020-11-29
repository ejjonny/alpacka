
import Combine
import Foundation

public enum Alpacka {
    struct OriginKeyPath<Item, OriginCoordinate> where Item: Hashable, Item: Sized {
        let x: WritableKeyPath<Item, OriginCoordinate>
        let y: WritableKeyPath<Item, OriginCoordinate>
    }
    public static func pack<Item, Origin>(_ items: [Item], origin: WritableKeyPath<Item, Origin>, in size: Size) -> AnyPublisher<Result<Item>, Never> where Item: Hashable, Item: Sized, Origin: OriginConvertible {
        pack(items, origin: origin, in: size, scheduler: DispatchQueue.global(qos: .default))
    }
    /**
     Packs items & applies the new origin to the `WritableKeyPath` that is provided.
     
     If any items do not fit this method will return the `.overFlow` result, containing a packed items associated value & an overFlow items associated value. These arrays will not have items in common. Check for overflow by switching on return value.
     
     - Parameters:
     - items: Hashable, sized items to be packed into a containing area.
     - origin: Writable keyPath of the origin on your items that can be modified to arrage your items. The type must conform to OriginConvertible.
     - size: The container size to arrange items within.
     - scheduler: The scheduler to perform work on. This can be omitted to use the default background queue. (`DispatchQueue.global(qos: .default)`)
     
     ```
     Alpacka.pack(myItemArray, origin: \.myItemOrigin, in: CGSize(width: 100, height: 100))
        .sink { result in
            // Check for overflow & proceed with arranged items here.
        }
        .store(in: &cancellables)
     */
    @discardableResult
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
    
    /// An asynchronous option for packing a higher number of objects.
    /// - Parameters:
    ///   - items: Hashable, sized items to be packed into a containing area.
    ///   - origin: Writable keyPath of the origin on your items that you want to modify to arrange them.
    ///   - size: The container size to arrange items within.
    ///   - qos: The quality of service to use on the background thread where work will be performed. Defaults to `.default`.
    ///   - completion: The code to execute when work is completed. This method will complete with `.success` normally or `.overFlow` if all items did not fit in the given container size.
    
    public enum Result<Item> where Item: Hashable, Item: Sized {
        case packed(_ packedItems: [Item])
        case overFlow(_ packedItems: [Item], overFlow: [Item])
    }
    
    internal static func pack<Item>(_ items: [Item], in size: Size) -> (packed: [Item: Point], overFlow: [Item]) where Item: Hashable, Item: Sized {
        var packed: Section<Item> = .space(size)
        var overFlow = [Item]()
        var added = [Item]()
        let sorted = items.sorted {
            $0.size.height > $1.size.height
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
