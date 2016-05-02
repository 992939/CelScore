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
        celeb.picture3x = "https://imageURL.com/test@3x.png"
        celeb.isFollowed = true
        celeb.isNew = true
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
    
    func testGetNewCelebsSignal() {
        let expectation = expectationWithDescription("getNewCelebsSignal callback")
        CelScoreViewModel().getNewCelebsSignal()
            .on(next: { celebInfo in
            XCTAssert(celebInfo.text.characters.count > 0, "NewCelebInfo text String must be > 0")
            XCTAssert(celebInfo.image.characters.count > 0, "NewCelebInfo image String must be > 0") })
            .on(completed: {
                let realm = try! Realm()
                let celebs = realm.objects(CelebrityModel).filter("isNew = %@", true)
                XCTAssertEqual(celebs.count, 0, "new celebs count must be 0")
                expectation.fulfill() })
            .start()
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("getNewCelebsSignal error: \(error)") } }
    }
    
    func testCountFollowedCelebritiesSignal() {
        let expectation = expectationWithDescription("countFollowedCelebritiesSignal callback")
        CelebrityViewModel().countFollowedCelebritiesSignal().startWithNext { count in
            XCTAssertEqual(count, 1, "countFollowedCelebritiesSignal returns 1."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("countFollowedCelebritiesSignal error: \(error)") } }
    }
    
    func testUpdateWidgetSignal() {
        let expectation = expectationWithDescription("userdefault returns 1")
        SettingsViewModel().updateTodayWidgetSignal().startWithNext { result in
            XCTAssertEqual(result.count, 1, "testUpdateWidgetSignal returns 1."); expectation.fulfill()
            let userDefaults: NSUserDefaults = NSUserDefaults(suiteName:"group.NotificationApp")!
            userDefaults.synchronize()
            let rowsNumber: Int = userDefaults.integerForKey("count")
            XCTAssertEqual(rowsNumber, 1, "NSUserDefaults equals 1.")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("testUpdateWidgetSignal error: \(error)") } }
    }
}
