//
//  CelScoreViewModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 5/3/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
import RealmSwift
@testable import CelebrityScore

class CelScoreViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testShareVoteOnSignal() {
        let expectation = self.expectation(description: "shareVoteOnSignal callback")
        CelScoreViewModel().shareVoteOnSignal(socialLogin: .Facebook, message: "message", screenshot: UIImage()).startWithNext { composer in
            XCTAssertNotNil(composer, "SLComposeViewController must not be nil")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("shareVoteOnSignal error: \(error)") } }
    }
}
