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
        let ratings = RatingsModel(id: "0001")
        XCTAssertNotNil(ratings, "RatingsModel() not nil")
    }
}
