//
//  File.swift
//  
//
//  Created by Ethan John on 11/29/20.
//
#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

extension Alpacka.Point {
    init(_ point: CGPoint) {
        x = Double(point.x)
        y = Double(point.y)
    }
}

extension CGPoint: OriginConvertible {
    public init(_ point: Alpacka.Point) {
        self.init(x: point.x, y: point.y)
    }
}
