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
        let ratings = RatingsModel()
        XCTAssertNotNil(ratings, "RatingsModel() not nil")
        XCTAssertNotNil(ratings.id, "RatingsModel().id not nil")
    }
    
    func testCelebrityModelInit() { XCTAssertNotNil(CelebrityModel(), "CelebrityModel() not nil") }
    
    func testSettingsModelInit() { XCTAssertNotNil(SettingsModel(), "SettingsModel() not nil") }
    
    func testListsModelInit() { XCTAssertNotNil(ListsModel(), "ListsModel() not nil") }
}
