//
//  DotDotDotTests.swift
//  DotDotDotTests
//
//  Created by Tom Sinlgeton on 16/01/2017.
//  Copyright © 2017 Tom Sinlgeton. All rights reserved.
//

import XCTest
@testable import DotDotDot

class DotDotDotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetGists() {
        let beforeExpectation = expectation(description: "Before Expectation")
        let completionExpectation = expectation(description: "Completion Expectation")
        let finallyExpectation = expectation(description: "Finally Expectation")
        
        let task = GistPageRequest().createTask()
            .before {
                beforeExpectation.fulfill()
            }
            .onCompletion { (value) in
                completionExpectation.fulfill()
            }
            .finally {
                finallyExpectation.fulfill()
        }
        
        _ = task.start()
        
        waitForExpectations(timeout: 10)
    }
    
    func testUserGistsWithCorrectUser() {
        let beforeExpectation = expectation(description: "Before Expectation")
        let completionExpectation = expectation(description: "Completion Expectation")
        let finallyExpectation = expectation(description: "Finally Expectation")
        
        let task = UsersGistsRequest(username: "radther").createTask()
            .before {
                beforeExpectation.fulfill()
            }
            .onCompletion { (value) in
                completionExpectation.fulfill()
            }
            .finally {
                finallyExpectation.fulfill()
        }
        
        _ = task.start()
        
        waitForExpectations(timeout: 10)
    }
    
    func testUserGistsWithBadUser() {
        let beforeExpectation = expectation(description: "Before Expectation")
        let errorExpectation = expectation(description: "Error Expectation")
        let finallyExpectation = expectation(description: "Finally Expectation")
        
        let task = UsersGistsRequest(username: "not%20a%20user").createTask()
            .before {
                beforeExpectation.fulfill()
            }
            .onCompletion { value in
                fatalError("Completion should not have been called when request errors")
            }
            .onError { (error) in
                guard case DotTaskError.otherError(DotTaskError.rejectedStatusCode(statusCode: 404)) = error else {
                    fatalError("Got wrong error")
                }
                
                errorExpectation.fulfill()
            }
            .finally {
                finallyExpectation.fulfill()
        }
        
        _ = task.start()
        
        waitForExpectations(timeout: 10)
    }
    
}
