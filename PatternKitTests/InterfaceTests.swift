//
//  InterfaceTests.swift
//  PatternKitTests
//
//  Created by Brent Royal-Gordon on 8/23/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import XCTest
@testable import PatternKit

class InterfaceTests: XCTestCase {
    func testExample() {
        let pat = String.pattern("hello"/)
        
        XCTAssertTrue(pat ~= "hello", "basic operator matches when appropriate")
        XCTAssertFalse(pat ~= "hellish", "basic operator doesn't match when appropriate")
        XCTAssertTrue(pat ~= "hello world", "basic operator matches prefix")
        XCTAssertTrue(pat ~= "I say hello", "basic operator matches suffix")
        XCTAssertTrue(pat ~= "I say 'hello'", "basic operator matches inside")
        
        let otherStr = "hello hi hello"
        let otherRanges = otherStr.ranges(with: pat)
        
        XCTAssertEqual(otherRanges.count, 2)
    }
}
