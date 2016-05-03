//
//  ListViewModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/14/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
import RealmSwift
@testable import CelebrityScore

class ListViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        
        let realm = try! Realm()
        realm.beginWrite()
        let celebId1 = CelebId()
        celebId1.id = "0001"
        let celebId2 = CelebId()
        celebId2.id = "0002"
        let celebId3 = CelebId()
        celebId3.id = "0003"
        let list = ListsModel()
        list.id = "0001"
        list.celebList.append(celebId1)
        list.celebList.append(celebId2)
        list.celebList.append(celebId3)
        realm.add(list, update: true)
        
        let celebrity1 = CelebrityModel()
        celebrity1.id = "0001"
        celebrity1.nickName = "testUser"
        let celebrity2 = CelebrityModel()
        celebrity2.id = "0002"
        celebrity2.nickName = "secretUser"
        celebrity2.isFollowed = true
        realm.add(celebrity1, update: true)
        realm.add(celebrity2, update: true)
        try! realm.commitWrite()
    }
    
    func testGetListSignal() {
        let expectation = expectationWithDescription("getListSignal callback")
        ListViewModel().getListSignal(listId: "0001").startWithNext { list in
            XCTAssertEqual(list.celebList.count, 3, "getListSignal returns list with two items."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("getListSignal error: \(error)") } }
    }
    
    func testSanitizeListsSignal() {
        let realm = try! Realm()
        let initialList = realm.objects(ListsModel).filter("id = %@", "0001").first
        XCTAssertEqual(initialList?.celebList.count, 3, "sanitizeListsSignal: ListViewModel starts with 3 CelebIds.")
        
        let expectation = expectationWithDescription("sanitizeListsSignal callback")
        ListViewModel().sanitizeListsSignal().startWithCompleted {
            let list = realm.objects(ListsModel).filter("id = %@", "0001").first
            XCTAssertEqual(list?.celebList.count, 2, "sanitizeListsSignal returns a list with 2 CelebIds.")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("sanitizeListsSignal error: \(error)") } }
    }
    
    func testSearchSignal() {
        let expectation = expectationWithDescription("searchSignal callback")
        ListViewModel().searchSignal(searchToken: "test").startWithNext { list in
            XCTAssertEqual(list.celebList.count, 1, "searchSignal returns list with one item."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("searchSignal error: \(error)") } }
    }
    
    func testUpdateListSignal() {
        let expectation = expectationWithDescription("updateListSignal callback")
        ListViewModel().updateListSignal(listId: "0001").startWithNext { list in
            let celebId: CelebId = list.celebList.first!
            XCTAssertEqual(celebId.id, "0002", "updateListSignal returns list followed item first.")
            XCTAssertEqual(list.celebList.count, 3, "updateListSignal returns list of three items.")
            expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("updateListSignal error: \(error)") } }
    }
    
    func testGetCelebrityStructSignal() {
        let expectation = expectationWithDescription("getCelebrityStructSignal callback")
        ListViewModel().getCelebrityStructSignal(listId: "0001", index: 1).startWithNext { celeb in
            XCTAssertEqual(celeb.id, "0002", "getCelebrityStructSignal returns second item."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("getCelebrityStructSignal error: \(error)") } }
    }
}
