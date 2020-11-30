//
//  Sized.swift
//  
//
//  Created by Ethan John on 12/20/19.
//

/// Conform to `Sized` by providing a `packingSize` property to an object.
public protocol Sized {
    var packingSize: Alpacka.Size { get }
}
extension Sized {
    internal var size: Alpacka.Size { packingSize }
}
