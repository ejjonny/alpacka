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

extension Alpacka.Size {
    init(_ size: CGSize) {
        width = Double(size.width)
        height = Double(size.height)
    }
}

extension CGSize {
    init(_ size: Alpacka.Size) {
        self.init(width: size.width, height: size.height)
    }
}
