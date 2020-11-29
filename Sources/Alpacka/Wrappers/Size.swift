//
//  Size.swift
//  
//
//  Created by Ethan John on 12/20/19.
//

#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

/// A simple size representation that uses all `Double` properties.
internal struct Size {
    let width: Double
    let height: Double
    var area: Double {
        width * height
    }
    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }
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

