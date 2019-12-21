//
//  Section.swift
//  
//
//  Created by Ethan John on 12/20/19.
//

internal indirect enum Section<Item> where Item: Hashable, Item: Sized {
    case item(_: Item, right: Section<Item>, down: Section<Item>)
    case space(_: Size)
    
    internal func traverseAndPlace(_ item: Item) -> Section<Item>? {
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
    
    internal func place<Item: Sized>(_ item: Item) -> Section<Item> {
        guard case let .space(size) = self else { fatalError() }
        return .item(item,
                     right: .space(Size(w: Double(size.width) - item.size.width, h: item.size.height)),
                     down: .space(Size(w: size.width, h: size.height - item.size.height)))
    }
    
    internal func origin(_ item: Item, rightDistance: Double = 0, downDistance: Double = 0) -> Point? {
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
    
    internal func areaUsed() -> Double {
        self.allChildren().reduce(0.0) { current, next in
            current + next.size.width * next.size.height
        }
    }
    
    internal func allChildren() -> [Item] {
        switch self {
        case let .item(item, right: right, down: down):
            return [item] + right.allChildren() + down.allChildren()
        case .space:
            return []
        }
    }
}
