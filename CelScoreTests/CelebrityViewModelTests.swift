//
//  CelebrityViewModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/13/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
import RealmSwift
@testable import CelebrityScore

class CelebrityViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let realm = try! Realm()
        realm.beginWrite()
        let celeb = CelebrityModel()
        celeb.id = "0001"
        celeb.isFollowed = true
        realm.add(celeb, update: true)
        try! realm.commitWrite()
    }
    
    func testGetCelebritySignal() {
        let expectation = expectationWithDescription("getCelebritySignal callback")
        CelebrityViewModel().getCelebritySignal(id: "0001").startWithNext { celeb in
            XCTAssert((celeb as Any) is CelebrityModel, "getCelebritySignal returns CelebrityModel."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("getCelebritySignal error: \(error)") } }
    }
    
    func testUpdateUserActivitySignal() {
        let expectation = expectationWithDescription("updateUserActivitySignal callback")
        CelebrityViewModel().updateUserActivitySignal(id: "0001").startWithNext { activity in
            XCTAssertEqual(activity.eligibleForSearch, true, "NSUserActivity must be eligibleForSearch."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("updateUserActivitySignal error: \(error)") } }
    }
    
    func testFollowCebritySignal() {
        let expectation = expectationWithDescription("followCebritySignal callback")
        CelebrityViewModel().followCebritySignal(id: "0001", isFollowing: false).startWithNext { celeb in
            XCTAssertEqual(celeb.isFollowed, false, "Celebrity isFollowed must be false."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("followCebritySignal error: \(error)") } }
    }
    
    func testCountFollowedCelebritiesSignal() {
        let expectation = expectationWithDescription("countFollowedCelebritiesSignal callback")
        CelebrityViewModel().countFollowedCelebritiesSignal().startWithNext { count in
            XCTAssertEqual(count, 1, "countFollowedCelebritiesSignal returns 1."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("countFollowedCelebritiesSignal error: \(error)") } }
    }
}
