//
//  OptionalHasValueTests.swift
//  FireNetwork
//
//  Created by Tom Sinlgeton on 13/01/2017.
//  Copyright © 2017 Tom Sinlgeton. All rights reserved.
//

import XCTest
@testable import DotDotDot

class OptionalHasValueTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTrueValue() {
        let item: String? = "Hello, World!"
        XCTAssertTrue(item.hasValue, "Value should be true")
    }
    
    func testFalseValue() {
        let item: String? = nil
        XCTAssertFalse(item.hasValue, "Value should be false")
    }
    
}
