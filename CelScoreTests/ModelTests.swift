//
//  ModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/12/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
@testable import CelebrityScore

class ModelTests: XCTestCase {
    
    func testRatingsModelInit() {
        let ratings = RatingsModel(id: "0001")
        XCTAssertNotNil(ratings, "RatingsModel() not nil")
    }
}
