//
//  ModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/12/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
import RealmSwift
@testable import CelebrityScore

class ModelTests: XCTestCase {
    
    func testRatingsModelNil() {
        let ratings = RatingsModel()
        XCTAssertNotNil(ratings, "RatingsModel() not nil")
        XCTAssertNotNil(ratings.id, "RatingsModel().id not nil")
        XCTAssertNotNil(ratings.rating1, "RatingsModel().rating1 not nil")
        XCTAssertNotNil(ratings.rating2, "RatingsModel().rating2 not nil")
        XCTAssertNotNil(ratings.rating3, "RatingsModel().rating3 not nil")
        XCTAssertNotNil(ratings.rating4, "RatingsModel().rating4 not nil")
        XCTAssertNotNil(ratings.rating5, "RatingsModel().rating5 not nil")
        XCTAssertNotNil(ratings.rating6, "RatingsModel().rating6 not nil")
        XCTAssertNotNil(ratings.rating7, "RatingsModel().rating7 not nil")
        XCTAssertNotNil(ratings.rating8, "RatingsModel().rating8 not nil")
        XCTAssertNotNil(ratings.rating9, "RatingsModel().rating9 not nil")
        XCTAssertNotNil(ratings.rating10, "RatingsModel().rating10 not nil")
        XCTAssertNotNil(ratings.variance1, "RatingsModel().variance1 not nil")
        XCTAssertNotNil(ratings.variance2, "RatingsModel().variance2 not nil")
        XCTAssertNotNil(ratings.variance3, "RatingsModel().variance3 not nil")
        XCTAssertNotNil(ratings.variance4, "RatingsModel().variance4 not nil")
        XCTAssertNotNil(ratings.variance5, "RatingsModel().variance5 not nil")
        XCTAssertNotNil(ratings.variance6, "RatingsModel().variance6 not nil")
        XCTAssertNotNil(ratings.variance7, "RatingsModel().variance7 not nil")
        XCTAssertNotNil(ratings.variance8, "RatingsModel().variance8 not nil")
        XCTAssertNotNil(ratings.variance9, "RatingsModel().variance9 not nil")
        XCTAssertNotNil(ratings.variance10, "RatingsModel().variance10 not nil")
        XCTAssertNotNil(ratings.totalVotes, "RatingsModel().totalVotes not nil")
        XCTAssertNotNil(ratings.isSynced, "RatingsModel().isSynced not nil")
        XCTAssertNotNil(ratings.startIndex, "RatingsModel().startIndex not nil")
        XCTAssertNotNil(ratings.endIndex, "RatingsModel().endIndex not nil")
        XCTAssertNotNil(ratings.updatedAt, "RatingsModel().updatedAt not nil")
    }
    
    func testRatingsModelType() {
        let ratings = RatingsModel()
        XCTAssert((ratings.id as Any) is String, "RatingsModel().id is String")
        XCTAssert((ratings.rating1 as Any) is Double, "RatingsModel().rating1 is Double")
        XCTAssert((ratings.rating2 as Any) is Double, "RatingsModel().rating2 is Double")
        XCTAssert((ratings.rating3 as Any) is Double, "RatingsModel().rating3 is Double")
        XCTAssert((ratings.rating4 as Any) is Double, "RatingsModel().rating4 is Double")
        XCTAssert((ratings.rating5 as Any) is Double, "RatingsModel().rating5 is Double")
        XCTAssert((ratings.rating6 as Any) is Double, "RatingsModel().rating6 is Double")
        XCTAssert((ratings.rating7 as Any) is Double, "RatingsModel().rating7 is Double")
        XCTAssert((ratings.rating8 as Any) is Double, "RatingsModel().rating8 is Double")
        XCTAssert((ratings.rating9 as Any) is Double, "RatingsModel().rating9 is Double")
        XCTAssert((ratings.rating10 as Any) is Double, "RatingsModel().rating10 is Double")
        XCTAssert((ratings.variance1 as Any) is Double, "RatingsModel().variance1 is Double")
        XCTAssert((ratings.variance2 as Any) is Double, "RatingsModel().variance2 is Double")
        XCTAssert((ratings.variance3 as Any) is Double, "RatingsModel().variance3 is Double")
        XCTAssert((ratings.variance4 as Any) is Double, "RatingsModel().variance4 is Double")
        XCTAssert((ratings.variance5 as Any) is Double, "RatingsModel().variance5 is Double")
        XCTAssert((ratings.variance6 as Any) is Double, "RatingsModel().variance6 is Double")
        XCTAssert((ratings.variance7 as Any) is Double, "RatingsModel().variance7 is Double")
        XCTAssert((ratings.variance8 as Any) is Double, "RatingsModel().variance8 is Double")
        XCTAssert((ratings.variance9 as Any) is Double, "RatingsModel().variance9 is Double")
        XCTAssert((ratings.variance10 as Any) is Double, "RatingsModel().variance10 is Double")
        XCTAssert((ratings.totalVotes as Any) is Int, "RatingsModel().totalVotes is Int")
        XCTAssert((ratings.isSynced as Any) is Bool, "RatingsModel().isSynced is Bool")
        XCTAssert((ratings.updatedAt as Any) is String, "RatingsModel().updatedAt is String")
        XCTAssert((ratings.startIndex as Any) is Int, "RatingsModel().startIndex is Int")
        XCTAssert((ratings.endIndex as Any) is Int, "RatingsModel().endIndex is Int")
    }
    
    func testCelebrityModelNil() {
        let celeb = CelebrityModel()
        XCTAssertNotNil(celeb, "CelebrityModel() not nil")
        XCTAssertNotNil(celeb.id, "CelebrityModel().id not nil")
        XCTAssertNotNil(celeb.firstName, "CelebrityModel().firstName not nil")
        XCTAssertNotNil(celeb.lastName, "CelebrityModel().lastName not nil")
        XCTAssertNotNil(celeb.middleName, "CelebrityModel().middleName not nil")
        XCTAssertNotNil(celeb.nickName, "CelebrityModel().nickName not nil")
        XCTAssertNotNil(celeb.height, "CelebrityModel().height not nil")
        XCTAssertNotNil(celeb.birthdate, "CelebrityModel().birthdate not nil")
        XCTAssertNotNil(celeb.netWorth, "CelebrityModel().netWorth not nil")
        XCTAssertNotNil(celeb.picture3x, "CelebrityModel().picture3x not nil")
        XCTAssertNotNil(celeb.gold3x, "CelebrityModel().gold3x not nil")
        XCTAssertNotNil(celeb.from, "CelebrityModel().from not nil")
        XCTAssertNotNil(celeb.rank, "CelebrityModel().rank not nil")
        XCTAssertNotNil(celeb.status, "CelebrityModel().status not nil")
        XCTAssertNotNil(celeb.twitter, "CelebrityModel().twitter not nil")
        XCTAssertNotNil(celeb.prevScore, "CelebrityModel().prevScore not nil")
        XCTAssertNotNil(celeb.sex, "CelebrityModel().sex not nil")
        XCTAssertNotNil(celeb.isSynced, "CelebrityModel().isSynced not nil")
        XCTAssertNotNil(celeb.isFollowed, "CelebrityModel().isFollowed not nil")
        XCTAssertNotNil(celeb.isKing, "CelebrityModel().isKing not nil")
    }
    
    func testCelebrityModelType() {
        let celeb = CelebrityModel()
        XCTAssert((celeb.id as Any) is String, "CelebrityModel().id is String")
        XCTAssert((celeb.firstName as Any) is String, "CelebrityModel().firstName is String")
        XCTAssert((celeb.lastName as Any) is String, "CelebrityModel().lastName is String")
        XCTAssert((celeb.middleName as Any) is String, "CelebrityModel().middleName is String")
        XCTAssert((celeb.nickName as Any) is String, "CelebrityModel().nickName is String")
        XCTAssert((celeb.height as Any) is String, "CelebrityModel().height is String")
        XCTAssert((celeb.birthdate as Any) is String, "CelebrityModel().birthdate is String")
        XCTAssert((celeb.netWorth as Any) is String, "CelebrityModel().netWorth is String")
        XCTAssert((celeb.picture3x as Any) is String, "CelebrityModel().picture3x is String")
        XCTAssert((celeb.gold3x as Any) is String, "CelebrityModel().gold3x is String")
        XCTAssert((celeb.from as Any) is String, "CelebrityModel().from is String")
        XCTAssert((celeb.rank as Any) is String, "CelebrityModel().rank is String")
        XCTAssert((celeb.status as Any) is String, "CelebrityModel().status is String")
        XCTAssert((celeb.twitter as Any) is String, "CelebrityModel().twitter is String")
        XCTAssert((celeb.prevScore as Any) is Double, "CelebrityModel().prevScore is Double")
        XCTAssert((celeb.sex as Any) is Bool, "CelebrityModel().sex is Bool")
        XCTAssert((celeb.isSynced as Any) is Bool, "CelebrityModel().isSynced is Bool")
        XCTAssert((celeb.isFollowed as Any) is Bool, "CelebrityModel().isFollowed is Bool")
        XCTAssert((celeb.isKing as Any) is Bool, "CelebrityModel().isKing is Bool")
    }
    
    func testSettingsModelNil() {
        let settings = SettingsModel()
        XCTAssertNotNil(settings, "SettingsModel() not nil")
        XCTAssertNotNil(settings.id, "SettingsModel().id not nil")
        XCTAssertNotNil(settings.userName, "SettingsModel().userName not nil")
        XCTAssertNotNil(settings.loginTypeIndex, "SettingsModel().loginTypeIndex not nil")
        XCTAssertNotNil(settings.publicService, "SettingsModel().publicService not nil")
        XCTAssertNotNil(settings.onCountdown, "SettingsModel().onCountdown not nil")
        XCTAssertNotNil(settings.isFirstLaunch, "SettingsModel().isFirstLaunch not nil")
        XCTAssertNotNil(settings.isFirstDetail, "SettingsModel().isFirstDetail not nil")
        XCTAssertNotNil(settings.isFirstConsensus, "SettingsModel().isFirstConsensus not nil")
        XCTAssertNotNil(settings.isFirstPublic, "SettingsModel().isFirstPublic not nil")
        XCTAssertNotNil(settings.isFirstFollow, "SettingsModel().isFirstFollow not nil")
        XCTAssertNotNil(settings.isFirstCompleted, "SettingsModel().isFirstCompleted not nil")
        XCTAssertNotNil(settings.isFirstInterest, "SettingsModel().isFirstInterest not nil")
        XCTAssertNotNil(settings.isFirstVoteDisabled, "SettingsModel().isFirstVoteDisabled not nil")
        XCTAssertNotNil(settings.isFirstSocialDisabled, "SettingsModel().isFirstSocialDisabled not nil")
        XCTAssertNotNil(settings.isFirstTrollWarning, "SettingsModel().isFirstTrollWarning not nil")
        XCTAssertNotNil(settings.isSynced, "SettingsModel().isSynced not nil")
    }
    
    func testSettingsModelType() {
        let settings = SettingsModel()
        XCTAssert((settings.id as Any) is String, "SettingsModel().id is String")
        XCTAssert((settings.userName as Any) is String, "SettingsModel().userName is String")
        XCTAssert((settings.loginTypeIndex as Any) is Int, "SettingsModel().loginTypeIndex is Int")
        XCTAssert((settings.publicService as Any) is Bool, "SettingsModel().publicService is Bool")
        XCTAssert((settings.onCountdown as Any) is Bool, "SettingsModel().onCountdown is Bool")
        XCTAssert((settings.isFirstLaunch as Any) is Bool, "SettingsModel().isFirstLaunch is Bool")
        XCTAssert((settings.isFirstDetail as Any) is Bool, "SettingsModel().isFirstDetail is Bool")
        XCTAssert((settings.isFirstConsensus as Any) is Bool, "SettingsModel().isFirstConsensus is Bool")
        XCTAssert((settings.isFirstPublic as Any) is Bool, "SettingsModel().isFirstPublic is Bool")
        XCTAssert((settings.isFirstFollow as Any) is Bool, "SettingsModel().isFirstFollow is Bool")
        XCTAssert((settings.isFirstCompleted as Any) is Bool, "SettingsModel().isFirstCompleted is Bool")
        XCTAssert((settings.isFirstInterest as Any) is Bool, "SettingsModel().isFirstInterest is Bool")
        XCTAssert((settings.isFirstVoteDisabled as Any) is Bool, "SettingsModel().isFirstVoteDisabled is Bool")
        XCTAssert((settings.isFirstSocialDisabled as Any) is Bool, "SettingsModel().isFirstSocialDisabled is Bool")
        XCTAssert((settings.isFirstTrollWarning as Any) is Bool, "SettingsModel().isFirstTrollWarning is Bool")
        XCTAssert((settings.isSynced as Any) is Bool, "SettingsModel().isSynced is Bool")
    }
    
    func testListsModelNil() {
        let list = ListsModel()
        XCTAssertNotNil(list, "ListsModel() not nil")
        XCTAssertNotNil(list.id, "ListsModel().id not nil")
        XCTAssertNotNil(list.name, "ListsModel().name not nil")
        XCTAssertNotNil(list.isSynced, "ListsModel().isSynced not nil")
        XCTAssertNotNil(list.celebList, "ListsModel().celebList not nil")
    }
    
    func testListsModelType() {
        let list = ListsModel()
        XCTAssert((list.id as Any) is String, "ListsModel().id is String")
        XCTAssert((list.name as Any) is String, "ListsModel().name is String")
        XCTAssert((list.isSynced as Any) is Bool, "ListsModel().name is Bool")
        XCTAssert((list.celebList as Any) is List<CelebId>, "ListsModel().id is List<CelebId>")
    }
    
    func testCelebIdNil() {
        let celebId = CelebId()
        XCTAssertNotNil(celebId, "CelebId() not nil")
        XCTAssertNotNil(celebId.id, "CelebId().id not nil")
    }
    
    func testCelebIdType() {
        let celebId = CelebId()
        XCTAssert((celebId.id as Any) is String, "CelebId().id is String")
    }
    
    func testUserRatingsInterpolation() {
        let userRatings = UserRatingsModel(id: "0001", joinedString: "1/2/1/1/1/1/1/1/1/1")
        XCTAssertEqual(userRatings.rating2, Double(2.00), "UserRatingsModel().interpolation() error1.")
        XCTAssertEqual(userRatings.interpolation(), "1/2/1/1/1/1/1/1/1/1", "UserRatingsModel().interpolation() error2.")
    }
    
    func testUserRatingsGetCelScore() {
        let userRatings = UserRatingsModel(id: "0001", joinedString: "1/1/1/1/1/1/1/1/1/1")
        XCTAssertEqual(userRatings.getCelScore(), Double(20), "userRatings.getCelScore() error.")
    }
    
    func testUserRatingsGetAverageVariance() {
        let userRatings = UserRatingsModel()
        userRatings.variance1 = 1
        userRatings.variance2 = 1
        userRatings.variance3 = 1
        userRatings.variance4 = 1
        userRatings.variance5 = 1
        userRatings.variance6 = 1
        userRatings.variance7 = 1
        userRatings.variance8 = 1
        userRatings.variance9 = 1
        userRatings.variance10 = 1
        XCTAssertEqual(userRatings.getAvgVariance(), Double(1.00), "userRatings.getAvgVariance() error.")
    }
    
    func testCelebrityStructEquality() {
        let celebA = CelebrityStruct(id: "0001", imageURL:"", nickname:"A", prevScore: 0, sex: false, isFollowed:false, isKing:true)
        let celebB = CelebrityStruct(id: "0001", imageURL:"@3x", nickname:"A", prevScore: 2, sex: true, isFollowed:true, isKing:false)
        let celebC = CelebrityStruct(id: "0000", imageURL:"", nickname:"A", prevScore: 0, sex: false, isFollowed:false, isKing:falsex)
        XCTAssertEqual(celebA, celebB, "CelebrityStruct equality error.")
        XCTAssertNotEqual(celebA, celebC, "CelebrityStruct unequality error.")
    }
}




