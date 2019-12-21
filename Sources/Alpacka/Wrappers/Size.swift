//
//  Size.swift
//  
//
//  Created by Ethan John on 12/20/19.
//

import UIKit

/// A simple size representation that uses all `Double` properties.
internal struct Size {
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

