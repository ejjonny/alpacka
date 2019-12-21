//
//  Sized.swift
//  
//
//  Created by Ethan John on 12/20/19.
//

import UIKit

/// Conform to `Sized` by providing a `packingSize` property to an object.
public protocol Sized {
    var packingSize: CGSize { get }
}

extension Sized {
    internal var size: Size {
        Size(packingSize)
    }
}
