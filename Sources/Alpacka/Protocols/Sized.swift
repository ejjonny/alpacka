//
//  Sized.swift
//  
//
//  Created by Ethan John on 12/20/19.
//

#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

/// Conform to `Sized` by providing a `packingSize` property to an object.
public protocol Sized {
    var packingSize: CGSize { get }
}

extension Sized {
    internal var size: Size {
        Size(packingSize)
    }
}
