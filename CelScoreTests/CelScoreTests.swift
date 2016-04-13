//
//  CelScoreTests.swift
//  CelScoreTests
//
//  Created by Gareth.K.Mensah on 6/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//


import XCTest
import ReactiveCocoa
@testable import CelebrityScore

class CelScoreTests: XCTestCase {
    
    func testCalculatePositiveVoteSignal() {
        let expectation = expectationWithDescription("SomeService does stuff and runs the callback closure")
        
        SettingsViewModel().calculatePositiveVoteSignal().startWithNext { positive in
            XCTAssertTrue(true)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1) { error in
            if let error = error { XCTFail("waitForExpectationsWithTimeout error: \(error)") }
        }
        
    }
}
