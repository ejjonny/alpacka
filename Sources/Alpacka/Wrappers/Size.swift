//
//  Size.swift
//  
//
//  Created by Ethan John on 12/20/19.
//

extension Alpacka {
    /// A simple size representation that uses all `Double` properties.
    public struct Size {
        public let width: Double
        public let height: Double
        var area: Double {
            width * height
        }
        public init(w: Double, h: Double) {
            width = w
            height = h
        }
        func fits(_ size: Size) -> Bool {
            return size.height <= self.height && size.width <= self.width
        }
    }
}
