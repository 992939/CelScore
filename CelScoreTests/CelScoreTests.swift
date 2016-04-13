//
//  CelScoreTests.swift
//  CelScoreTests
//
//  Created by Gareth.K.Mensah on 6/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//


import XCTest
import UIKit
import Result
import ReactiveCocoa
@testable import CelebrityScore

class CelScoreTests: XCTestCase {
    
    func testCalculatePositiveVoteSignal() {
        let calculate = SettingsViewModel().calculatePositiveVoteSignal()
        let expectation = expectationWithDescription("check that calculatePositiveVoteSignal()")
        
        calculate.startWithNext { positive in XCTAssertTrue(true); expectation.fulfill() }
        
        waitForExpectationsWithTimeout(1) { error in
            if let error = error { XCTFail("waitForExpectationsWithTimeout errored: \(error)") }
        }
    }
}
