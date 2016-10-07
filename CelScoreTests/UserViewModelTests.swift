//
//  UserViewModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 5/3/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
import RealmSwift
@testable import CelebrityScore

class UserViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let realm = try! Realm()
        realm.beginWrite()
        let model: SettingsModel = realm.objects(SettingsModel).first ?? SettingsModel()
        model.userName = "testUser"
        realm.add(model, update: true)
        try! realm.commitWrite()
    }
    
    func testLogoutSignal() {
        let expectation = self.expectation(description: "logoutSignal callback")
        UserViewModel().logoutSignal().startWithValues { _ in
            let realm = try! Realm()
            let count = realm.objects(SettingsModel).count
            XCTAssertEqual(count, 0, "logout must delete all SettingsModel.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("logoutSignal error: \(error)") } }
    }
}
