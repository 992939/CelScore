//
//  SettingsViewModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/13/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
import RealmSwift
@testable import CelebrityScore

class SettingsViewModelTests: XCTestCase {
    
    func testCalculatePositiveVoteSignal() {
        let expectation = expectationWithDescription("calculatePositiveVoteSignal callback")
        SettingsViewModel().calculatePositiveVoteSignal().startWithNext { positive in
            XCTAssert(positive >= 0, "calculatePositiveVoteSignal superior or equal to zero.")
            expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("calculatePositiveVoteSignal error: \(error)") } }
    }
    
    func testCalculateUserAverageCelScoreSignal() {
        let expectation = expectationWithDescription("calculateUserAverageCelScoreSignal callback")
        SettingsViewModel().calculateUserAverageCelScoreSignal().startWithNext { score in
            XCTAssert(score >= 0, "calculateUserAverageCelScoreSignal superior or equal to zero.")
            expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("calculateUserAverageCelScoreSignal error: \(error)") } }
    }
    
    func testCalculateSocialConsensusSignal() {
        let expectation = expectationWithDescription("calculateSocialConsensusSignal callback")
        SettingsViewModel().calculateSocialConsensusSignal()
            .on(next: { consensus in XCTAssert(consensus >= 0, "calculateSocialConsensusSignal superior or equal to zero."); expectation.fulfill() })
            .on(failed: { error in expectation.fulfill() })
            .start()
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("calculateSocialConsensusSignal error: \(error)") } }
    }
    
    func testIsPositiveVoteSignal() {
        let expectation = expectationWithDescription("isPositiveVoteSignal callback")
        SettingsViewModel().isPositiveVoteSignal()
            .on(next: { value in XCTAssert((value as Any) is Bool); expectation.fulfill() })
            .on(failed: { value in XCTAssert((value as Any) is Bool); expectation.fulfill() })
            .start()
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("isPositiveVoteSignal error: \(error)") } }
    }
    
    func testUpdateUserNameSignal() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = expectationWithDescription("updateUserNameSignal callback")
        SettingsViewModel().updateUserNameSignal(username: "user1").startWithNext { model in
            XCTAssertEqual(model.userName, "user1", "updateUserNameSignal must update SettingsViewModel with given username.");
            expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("updateUserNameSignal error: \(error)") } }
    }
}










