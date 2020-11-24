//
//  Point.swift
//  
//
//  Created by Ethan John on 12/20/19.
//

#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

internal struct Point {
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
