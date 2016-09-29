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
        let expectation = self.expectation(description: "getCelebritySignal callback")
        CelebrityViewModel().getCelebritySignal(id: "0001").startWithNext { celeb in
            XCTAssert((celeb as Any) is CelebrityModel, "getCelebritySignal returns CelebrityModel."); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("getCelebritySignal error: \(error)") } }
    }
    
    func testUpdateUserActivitySignal() {
        let expectation = self.expectation(description: "updateUserActivitySignal callback")
        CelebrityViewModel().updateUserActivitySignal(id: "0001").startWithNext { activity in
            XCTAssertEqual(activity.eligibleForSearch, true, "NSUserActivity must be eligibleForSearch."); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("updateUserActivitySignal error: \(error)") } }
    }
    
    func testFollowCebritySignal() {
        let expectation = self.expectation(description: "followCebritySignal callback")
        CelebrityViewModel().followCebritySignal(id: "0001", isFollowing: false).startWithNext { celeb in
            XCTAssertEqual(celeb.isFollowed, false, "Celebrity isFollowed must be false."); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("followCebritySignal error: \(error)") } }
    }
    
    func testGetNewCelebsSignal() {
        let expectation = self.expectation(description: "getNewCelebsSignal callback")
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
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("getNewCelebsSignal error: \(error)") } }
    }
    
    func testCountFollowedCelebritiesSignal() {
        let expectation = self.expectation(description: "countFollowedCelebritiesSignal callback")
        CelebrityViewModel().countFollowedCelebritiesSignal().startWithNext { count in
            XCTAssertEqual(count, 1, "countFollowedCelebritiesSignal returns 1."); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("countFollowedCelebritiesSignal error: \(error)") } }
    }
    
    func testUpdateWidgetSignal() {
        let expectation = self.expectation(description: "userdefault returns 1")
        SettingsViewModel().updateTodayWidgetSignal().startWithNext { result in
            XCTAssertEqual(result.count, 1, "testUpdateWidgetSignal returns 1.")
            let userDefaults: NSUserDefaults = NSUserDefaults(suiteName:"group.NotificationApp")!
            userDefaults.synchronize()
            let rowsNumber: Int = userDefaults.integerForKey("count")
            XCTAssertEqual(rowsNumber, 1, "NSUserDefaults equals 1.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("testUpdateWidgetSignal error: \(error)") } }
    }
    
    func testRemoveCelebsNotInPublicOpinionSignal() {
        let realm = try! Realm()
        realm.beginWrite()
        let celebId2 = CelebId()
        celebId2.id = "0002"
        let celebId3 = CelebId()
        celebId3.id = "0003"
        let list = ListsModel()
        list.id = "0001"
        list.celebList.append(celebId2)
        list.celebList.append(celebId3)
        realm.add(list, update: true)
        try! realm.commitWrite()
        
        let count = realm.objects(CelebrityModel).count
        XCTAssertEqual(count, 1, "count of CelebrityModel must return 0.")
        let expectation = self.expectation(description: "remove the CelebrityModel instance")
        CelebrityViewModel().removeCelebsNotInPublicOpinionSignal().startWithNext { removedCount in
            XCTAssertEqual(removedCount, 1, "count of CelebrityModel must return 1.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("removeCelebsNotInPublicOpinionSignal error: \(error)") } }
    }
}
