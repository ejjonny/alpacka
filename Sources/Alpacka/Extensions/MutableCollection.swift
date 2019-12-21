//
//  MutableCollection.swift
//  
//
//  Created by Ethan John on 12/21/19.
//

import Foundation

internal extension MutableCollection {
  mutating func updateEach(_ update: (inout Element) -> Void) {
    for i in indices {
      update(&self[i])
    }
  }
}
