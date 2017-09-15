//
//  CelebrityViewModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/13/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
import RealmSwift
import ReactiveCocoa
import ReactiveSwift

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
    
    func testGetCelebrityStructSignal() {
        let expectation = self.expectation(description: "getCelebrityStructSignal callback")
        CelebrityViewModel().getCelebrityStructSignal(id: "0001")
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { celeb in
                XCTAssertEqual(celeb.id, "0001", "getCelebrityStructSignal returns celeb."); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("getCelebrityStructSignal error: \(error)") } }
    }
    
    func testGetCelebritySignal() {
        let expectation = self.expectation(description: "getCelebritySignal callback")
        CelebrityViewModel().getCelebritySignal(id: "0001")
            .flatMapError { _ in .empty }
            .startWithValues  { celeb in
            XCTAssert((celeb as Any) is CelebrityModel, "getCelebritySignal returns CelebrityModel."); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("getCelebritySignal error: \(error)") } }
    }
    
    func testUpdateUserActivitySignal() {
        let expectation = self.expectation(description: "updateUserActivitySignal callback")
        CelebrityViewModel().updateUserActivitySignal(id: "0001")
            .flatMapError { _ in .empty }
            .startWithValues { activity in
            XCTAssertEqual(activity.isEligibleForSearch, true, "NSUserActivity must be eligibleForSearch."); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("updateUserActivitySignal error: \(error)") } }
    }
    
    func testFollowCebritySignal() {
        let expectation = self.expectation(description: "followCebritySignal callback")
        CelebrityViewModel().followCebritySignal(id: "0001", isFollowing: false)
            .flatMapError { _ in .empty }
            .startWithValues  { celeb in
            XCTAssertEqual(celeb.isFollowed, false, "Celebrity isFollowed must be false."); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("followCebritySignal error: \(error)") } }
    }
    
    func testCountFollowedCelebritiesSignal() {
        let expectation = self.expectation(description: "countFollowedCelebritiesSignal callback")
        CelebrityViewModel().countFollowedCelebritiesSignal().startWithValues { count in
            XCTAssertEqual(count, 1, "countFollowedCelebritiesSignal returns 1."); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("countFollowedCelebritiesSignal error: \(error)") } }
    }
    
    func testUpdateWidgetSignal() {
        let expectation = self.expectation(description: "userdefault returns 1")
        SettingsViewModel().updateTodayWidgetSignal().startWithValues { result in
            XCTAssertEqual(result.count, 1, "testUpdateWidgetSignal returns 1.")
            let userDefaults: UserDefaults = UserDefaults(suiteName:"group.NotificationApp")!
            userDefaults.synchronize()
            let rowsNumber: Int = userDefaults.integer(forKey: "count")
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
        
        let count = realm.objects(CelebrityModel.self).count
        XCTAssertEqual(count, 1, "count of CelebrityModel must return 0.")
        let expectation = self.expectation(description: "remove the CelebrityModel instance")
        CelebrityViewModel().removeCelebsNotInPublicOpinionSignal().startWithValues { removedCount in
            XCTAssertEqual(removedCount, 1, "count of CelebrityModel must return 1.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("removeCelebsNotInPublicOpinionSignal error: \(error)") } }
    }
}
