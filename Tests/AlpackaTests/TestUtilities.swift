//
//  TestUtilities.swift
//  
//
//  Created by Ethan John on 12/21/19.
//

import XCTest

extension XCTestCase {
    func completionChecked(_ timeout: Double, _ block: (XCTestExpectation) -> ()) {
        let exp = XCTestExpectation()
        block(exp)
        wait(for: [exp], timeout: timeout)
    }
}
