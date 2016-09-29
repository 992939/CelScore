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
        let expectation = self.expectation(description: "calculatePositiveVoteSignal callback")
        SettingsViewModel().calculatePositiveVoteSignal().startWithNext { positive in
            XCTAssert(positive >= 0, "calculatePositiveVoteSignal superior or equal to zero."); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("calculatePositiveVoteSignal error: \(error)") } }
    }
    
    func testCalculateUserAverageCelScoreSignal() {
        let expectation = self.expectation(description: "calculateUserAverageCelScoreSignal callback")
        SettingsViewModel().calculateUserAverageCelScoreSignal().startWithNext { score in
            XCTAssert(score >= 0, "calculateUserAverageCelScoreSignal superior or equal to zero.")
            expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("calculateUserAverageCelScoreSignal error: \(error)") } }
    }
    
    func testCalculateSocialConsensusSignal() {
        let expectation = self.expectation(description: "calculateSocialConsensusSignal callback")
        SettingsViewModel().calculateSocialConsensusSignal()
            .on(next: { consensus in XCTAssert(consensus >= 0, "calculateSocialConsensusSignal superior or equal to zero."); expectation.fulfill() })
            .on(failed: { error in expectation.fulfill() })
            .start()
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("calculateSocialConsensusSignal error: \(error)") } }
    }
    
    func testUpdateUserNameSignal() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "updateUserNameSignal callback")
        SettingsViewModel().updateUserNameSignal(username: "user1").startWithNext { model in
            XCTAssertEqual(model.userName, "user1", "updateUserNameSignal must update SettingsViewModel with given username.");
            expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("updateUserNameSignal error: \(error)") } }
    }
    
    func testGetDefaultListIndex() {
        let expectation = self.expectation(description: "DefaultListIndex returns Int")
        SettingsViewModel().getSettingSignal(settingType: .DefaultListIndex).startWithNext { value in
            XCTAssert((value as Any) is Int); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("DefaultListIndex error: \(error)") } }
    }
    
    func testGetLoginTypeIndex() {
        let expectation = self.expectation(description: "LoginTypeIndex returns Int")
        SettingsViewModel().getSettingSignal(settingType: .LoginTypeIndex).startWithNext { value in
            XCTAssert((value as Any) is Int); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("LoginTypeIndex error: \(error)") } }
    }
    
    func testGetPublicService() {
        let expectation = self.expectation(description: "PublicService returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .PublicService).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("PublicService error: \(error)") } }
    }
    
    func testGetConsensusBuilding() {
        let expectation = self.expectation(description: "ConsensusBuilding returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .ConsensusBuilding).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("ConsensusBuilding error: \(error)") } }
    }
    
    func testGetFirstLaunch() {
        let expectation = self.expectation(description: "FirstLaunch returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .FirstLaunch).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstLaunch error: \(error)") } }
    }
    
    func testGetFirstConsensus() {
        let expectation = self.expectation(description: "FirstConsensus returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .FirstConsensus).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstConsensus error: \(error)") } }
    }
    
    func testGetFirstPublic() {
        let expectation = self.expectation(description: "FirstPublic returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .FirstPublic).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstPublic error: \(error)") } }
    }
    
    func testGetFirstFollow() {
        let expectation = self.expectation(description: "FirstFollow returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .FirstFollow).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstFollow error: \(error)") } }
    }
    
    func testGetFirstInterest() {
        let expectation = self.expectation(description: "FirstInterest returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .FirstInterest).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstInterest error: \(error)") } }
    }
    
    func testGetFirstCompleted() {
        let expectation = self.expectation(description: "FirstCompleted returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .FirstCompleted).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstCompleted error: \(error)") } }
    }
    
    func testGetFirstVoteDisable() {
        let expectation = self.expectation(description: "FirstVoteDisable returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .FirstVoteDisable).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstVoteDisable error: \(error)") } }
    }
    
    func testGetFirstSocialDisable() {
        let expectation = self.expectation(description: "FirstSocialDisable returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .FirstSocialDisable).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstSocialDisable error: \(error)") } }
    }
    
    func testGetFirstTrollWarning() {
        let expectation = self.expectation(description: "FirstTrollWarning returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .FirstTrollWarning).startWithNext { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstTrollWarning error: \(error)") } }
    }
    
    func testUpdateDefaultListIndex() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set DefaultListIndex to Int(1)")
        SettingsViewModel().updateSettingSignal(value: Int(1), settingType: .DefaultListIndex).startWithNext { settings in
            XCTAssertEqual(settings.defaultListIndex, Int(1)); expectation.fulfill() }
       waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set DefaultListIndex error: \(error)") } }
    }
    
    func testUpdateLoginTypeIndex() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set LoginTypeIndex to Int(2)")
        SettingsViewModel().updateSettingSignal(value: Int(2), settingType: .LoginTypeIndex).startWithNext { settings in
            XCTAssertEqual(settings.loginTypeIndex, Int(2)); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set LoginTypeIndex error: \(error)") } }
    }
    
    func testUpdatePublicService() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set PublicService to true")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .PublicService).startWithNext { settings in
            XCTAssertEqual(settings.publicService, true); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set PublicService error: \(error)") } }
    }
    
    func testUpdateConsensusBuilding() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set ConsensusBuilding to true")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .ConsensusBuilding).startWithNext { settings in
            XCTAssertEqual(settings.consensusBuilding, true); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set ConsensusBuilding error: \(error)") } }
    }
    
    func testUpdateFirstLaunch() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstLaunch to false")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .FirstLaunch).startWithNext { settings in
            XCTAssertEqual(settings.isFirstLaunch, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstLaunch error: \(error)") } }
    }
    
    func testUpdateFirstConsensus() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstConsensus to false")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .FirstConsensus).startWithNext { settings in
            XCTAssertEqual(settings.isFirstConsensus, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstConsensus error: \(error)") } }
    }
    
    func testUpdateFirstPublic() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstPublic to false")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .FirstPublic).startWithNext { settings in
            XCTAssertEqual(settings.isFirstPublic, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstPublic error: \(error)") } }
    }
    
    func testUpdateFirstFollow() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstFollow to false")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .FirstFollow).startWithNext { settings in
            XCTAssertEqual(settings.isFirstFollow, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstFollow error: \(error)") } }
    }
    
    func testUpdateFirstInterest() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstInterest to false")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .FirstInterest).startWithNext { settings in
            XCTAssertEqual(settings.isFirstInterest, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstInterest error: \(error)") } }
    }
    
    func testUpdateFirstCompleted() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstCompleted to false")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .FirstCompleted).startWithNext { settings in
            XCTAssertEqual(settings.isFirstCompleted, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstCompleted error: \(error)") } }
    }
    
    func testUpdateFirstVoteDisable() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstVoteDisable to false")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .FirstVoteDisable).startWithNext { settings in
            XCTAssertEqual(settings.isFirstVoteDisabled, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstVoteDisable error: \(error)") } }
    }
    
    func testUpdateFirstSocialDisable() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstSocialDisable to false")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .FirstSocialDisable).startWithNext { settings in
            XCTAssertEqual(settings.isFirstSocialDisabled, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstSocialDisable error: \(error)") } }
    }
    
    func testUpdateFirstTrollWarning() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstTrollWarning to false")
        SettingsViewModel().updateSettingSignal(value: true, settingType: .FirstTrollWarning).startWithNext { settings in
            XCTAssertEqual(settings.isFirstTrollWarning, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstTrollWarning error: \(error)") } }
    }
}










