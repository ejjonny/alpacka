import UIKit

private indirect enum Section<Item> where Item: Hashable, Item: Sized {
    case item(_: Item, right: Section<Item>, down: Section<Item>)
    case space(_: Size)
    
    func traverseAndPlace(_ item: Item) -> Section<Item>? {
        switch self {
        case let .item(currentItem, right: right, down: down):
            if let placedRight = right.traverseAndPlace(item) {
                return .item(currentItem, right: placedRight, down: down)
            }
            if let placedDown = down.traverseAndPlace(item) {
                return .item(currentItem, right: right, down: placedDown)
            }
        case let .space(_: size):
            if size.fits(item.size) {
                return place(item)
            }
        }
        return nil
    }
    
    private func place<Item: Sized>(_ item: Item) -> Section<Item> {
        guard case let .space(size) = self else { fatalError() }
        return .item(item,
                     right: .space(Size(w: Double(size.width) - item.size.width, h: item.size.height)),
                     down: .space(Size(w: size.width, h: size.height - item.size.height)))
    }
    
    private func origin(_ item: Item, rightDistance: Double = 0, downDistance: Double = 0) -> Point? {
        switch self {
        case let .item(currentItem, right: right, down: down):
            if currentItem == item {
                return Point(x: rightDistance, y: downDistance)
            }
            if let origin = right.origin(item, rightDistance: rightDistance + currentItem.size.width, downDistance: downDistance) {
                return origin
            }
            if let origin = down.origin(item, rightDistance: rightDistance, downDistance: downDistance + currentItem.size.height) {
                return origin
            }
        case .space:
            return nil
        }
        return nil
    }
    
    public func pack(_ items: [Item]) -> [Item: CGPoint]? {
        var packed: Section<Item>? = self
        for item in items {
            guard let attempt = packed?.traverseAndPlace(item) else { print("FUCK") ; continue }
            packed = attempt
        }
        guard let pack = packed else { return nil }
        var dict = [Item: CGPoint]()
        for item in items {
            guard let origin = pack.origin(item) else { print("FAIL") ; continue }
            dict[item] = origin.cgPoint
        }
        return dict
    }
}

/// Conform to `Sized` by providing a `packingSize` property to an object.
public protocol Sized {
    var packingSize: CGSize { get }
}
extension Sized {
    fileprivate var size: Size {
        Size(packingSize)
    }
}

/// A simple size representation that uses all `Double` properties.
fileprivate struct Size {
    let width: Double
    let height: Double
    init(_ size: CGSize) {
        width = Double(size.width)
        height = Double(size.height)
    }
    init(w: Double, h: Double) {
        width = w
        height = h
    }
    public func fits(_ size: Size) -> Bool {
        return size.height <= self.height && size.width <= self.width
    }
}

fileprivate struct Point {
    let x: Double
    let y: Double
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
    init(_ point: CGPoint) {
        x = Double(point.x)
        y = Double(point.y)
    }
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
