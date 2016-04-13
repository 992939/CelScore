//
//  ModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/12/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
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
        XCTAssertNotNil(ratings.totalVotes, "RatingsModel().totalVotes not nil")
        XCTAssertNotNil(ratings.isSynced, "RatingsModel().isSynced not nil")
        XCTAssertNotNil(ratings.startIndex, "RatingsModel().startIndex not nil")
        XCTAssertNotNil(ratings.endIndex, "RatingsModel().endIndex not nil")
        XCTAssertNotNil(ratings.updatedAt, "RatingsModel().updatedAt not nil")
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
        XCTAssertNotNil(celeb.picture2x, "CelebrityModel().picture2x not nil")
        XCTAssertNotNil(celeb.picture3x, "CelebrityModel().picture3x not nil")
        XCTAssertNotNil(celeb.from, "CelebrityModel().from not nil")
        XCTAssertNotNil(celeb.rank, "CelebrityModel().rank not nil")
        XCTAssertNotNil(celeb.status, "CelebrityModel().status not nil")
        XCTAssertNotNil(celeb.twitter, "CelebrityModel().twitter not nil")
        XCTAssertNotNil(celeb.prevScore, "CelebrityModel().prevScore not nil")
        XCTAssertNotNil(celeb.sex, "CelebrityModel().sex not nil")
        XCTAssertNotNil(celeb.isSynced, "CelebrityModel().isSynced not nil")
    }
    
    func testSettingsModelNil() {
        let settings = SettingsModel()
        XCTAssertNotNil(settings, "SettingsModel() not nil")
        XCTAssertNotNil(settings.id, "SettingsModel().id not nil")
        XCTAssertNotNil(settings.userName, "SettingsModel().userName not nil")
        XCTAssertNotNil(settings.loginTypeIndex, "SettingsModel().loginTypeIndex not nil")
        XCTAssertNotNil(settings.publicService, "SettingsModel().publicService not nil")
        XCTAssertNotNil(settings.consensusBuilding, "SettingsModel().consensusBuilding not nil")
        XCTAssertNotNil(settings.isFirstLaunch, "SettingsModel().isFirstLaunch not nil")
        XCTAssertNotNil(settings.isFirstConsensus, "SettingsModel().isFirstConsensus not nil")
        XCTAssertNotNil(settings.isFirstPublic, "SettingsModel().isFirstPublic not nil")
        XCTAssertNotNil(settings.isFirstFollow, "SettingsModel().isFirstFollow not nil")
        XCTAssertNotNil(settings.isFirstStars, "SettingsModel().isFirstStars not nil")
        XCTAssertNotNil(settings.isFirstNegative, "SettingsModel().isFirstNegative not nil")
        XCTAssertNotNil(settings.isFirstCompleted, "SettingsModel().isFirstCompleted not nil")
        XCTAssertNotNil(settings.isFirstInterest, "SettingsModel().isFirstInterest not nil")
        XCTAssertNotNil(settings.isFirstVoteDisabled, "SettingsModel().isFirstVoteDisabled not nil")
        XCTAssertNotNil(settings.isFirstSocialDisabled, "SettingsModel().isFirstSocialDisabled not nil")
        XCTAssertNotNil(settings.isFirstTrollWarning, "SettingsModel().isFirstTrollWarning not nil")
        XCTAssertNotNil(settings.isSynced, "SettingsModel().isSynced not nil")
    }
    
    func testListsModelNil() {
        let list = ListsModel()
        XCTAssertNotNil(list, "ListsModel() not nil")
        XCTAssertNotNil(list.id, "ListsModel().id not nil")
        XCTAssertNotNil(list.name, "ListsModel().name not nil")
        XCTAssertNotNil(list.celebList, "ListsModel().celebList not nil")
    }
}




