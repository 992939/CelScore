//
//  RatingsViewModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/13/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
import RealmSwift
import Result
@testable import CelebrityScore

class RatingsViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    func testUpdateUserRatingSignal() {
        let expectation = expectationWithDescription("updateUserRatingSignal callback")
        RatingsViewModel().updateUserRatingSignal(ratingsId: "0001", ratingIndex: 2, newRating: 4).startWithNext { model in
             XCTAssertEqual(model.rating3, 4, "updateUserRatingSignal rating is newRating."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("updateUserRatingSignal error: \(error)") } }
    }
    
    func testVoteSignal() {
        let expectation = expectationWithDescription("voteSignal callback")
        RatingsViewModel().voteSignal(ratingsId: "0001")
            .on(next: { model in
                XCTAssertEqual(model.totalVotes, 1, "voteSignal increments userRatings.")
                XCTAssertEqual(model.isSynced, false, "voteSignal unsynced userRatings.")
                expectation.fulfill() })
            .on(failed: { error in expectation.fulfill() })
            .start()
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("voteSignal error: \(error)") } }
    }
    
    func testHasUserRatingsSignal() {
        let expectation = expectationWithDescription("hasUserRatingsSignal callback")
        RatingsViewModel().hasUserRatingsSignal(ratingsId: "0001").startWithNext { value in
            XCTAssertEqual(value, false, "hasUserRatingsSignal returns false."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("hasUserRatingsSignal error: \(error)") } }
    }
    
    func testCleanUpRatingsSignal() {
        let expectation = expectationWithDescription("cleanUpRatingsSignal callback")
        RatingsViewModel().updateUserRatingSignal(ratingsId: "0001", ratingIndex: 2, newRating: 4)
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (model) -> SignalProducer<RatingsModel, NoError> in
                XCTAssert(model.getCelScore() > 0, "hasUserRatingsSignal set celscore above 0")
                return RatingsViewModel().cleanUpRatingsSignal(ratingsId: "0001") }
            .on(next: { model in XCTAssertEqual(model.getCelScore(), 0, "cleanUpRatingsSignal set celscore to 0"); expectation.fulfill() })
            .start()
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("cleanUpRatingsSignal error: \(error)") } }
    }
}
 