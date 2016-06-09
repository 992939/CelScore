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
        let realm = try! Realm()
        realm.beginWrite()
        let ratings = RatingsModel(id: "0001")
        ratings.rating1 = 5
        let userRatings = UserRatingsModel(id: "0001", joinedString: "1/2/1/1/1/1/1/1/1/1")
        realm.add(ratings, update: true)
        realm.add(userRatings, update: true)
        try! realm.commitWrite()
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
            .start()
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("voteSignal error: \(error)") } }
    }
    
    func testGetRatingsSignal() {
        let expectation = expectationWithDescription("get RatingsSignal callback")
        RatingsViewModel().getRatingsSignal(ratingsId: "0001", ratingType: .Ratings).startWithNext { ratings in
            XCTAssertEqual(ratings.rating1, 5, "getRatingsSignal returns RatingsModel."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("get RatingsSignal error: \(error)") } }
    }
    
    func testGetUserRatingsSignal() {
        let expectation = expectationWithDescription("get UserRatingsSignal callback")
        RatingsViewModel().getRatingsSignal(ratingsId: "0001", ratingType: .UserRatings).startWithNext { ratings in
            XCTAssertEqual(ratings.rating2, 2, "getRatingsSignal returns UserRatingsModel."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("get UserRatingsSignal error: \(error)") } }
    }
    
    func testHasUserRatingsSignal() {
        let expectation = expectationWithDescription("hasUserRatingsSignal callback")
        RatingsViewModel().hasUserRatingsSignal(ratingsId: "0002").startWithNext { value in
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
    
    func testGetCelScoreSignal() {
        let expectation = expectationWithDescription("getCelScoreSignal callback")
        RatingsViewModel().getCelScoreSignal(ratingsId: "0001").startWithNext { score in
            XCTAssertEqual(score, 1.1, "getCelScoreSignal above 0.5."); expectation.fulfill() }
        waitForExpectationsWithTimeout(1) { error in if let error = error { XCTFail("getCelScoreSignal error: \(error)") } }
    }
}
 