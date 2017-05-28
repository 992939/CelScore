//
//  SettingsViewModelTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/13/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
import RealmSwift
import ReactiveCocoa
import ReactiveSwift
import Result
@testable import CelebrityScore

class SettingsViewModelTests: XCTestCase {
    
    func testCalculateUserAverageCelScoreSignal() {
        let expectation = self.expectation(description: "calculateUserAverageCelScoreSignal callback")
        SettingsViewModel().calculateUserAverageCelScoreSignal().startWithValues { score in
            XCTAssert(score >= 0, "calculateUserAverageCelScoreSignal superior or equal to zero.")
            expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("calculateUserAverageCelScoreSignal error: \(error)") } }
    }
    
    func testUpdateUserNameSignal() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "updateUserNameSignal callback")
        SettingsViewModel().updateUserNameSignal(username: "user1")
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { model in
            XCTAssertEqual(model.userName, "user1", "updateUserNameSignal must update SettingsViewModel with given username.");
            expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("updateUserNameSignal error: \(error)") } }
    }
    
    func testGetDefaultListIndex() {
        let expectation = self.expectation(description: "DefaultListIndex returns Int")
        SettingsViewModel().getSettingSignal(settingType: .defaultListIndex).startWithValues { value in
            XCTAssert((value as Any) is Int); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("DefaultListIndex error: \(error)") } }
    }
    
    func testGetLoginTypeIndex() {
        let expectation = self.expectation(description: "LoginTypeIndex returns Int")
        SettingsViewModel().getSettingSignal(settingType: .loginTypeIndex).startWithValues { value in
            XCTAssert((value as Any) is Int); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("LoginTypeIndex error: \(error)") } }
    }
    
    func testGetPublicService() {
        let expectation = self.expectation(description: "onSocialSharing returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .onSocialSharing).startWithValues { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("PublicService error: \(error)") } }
    }
    
    func testGetonCountdown() {
        let expectation = self.expectation(description: "onCountdown returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .onCountdown).startWithValues { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("onCountdown error: \(error)") } }
    }
    
    func testGetFirstLaunch() {
        let expectation = self.expectation(description: "FirstLaunch returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .firstLaunch).startWithValues { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstLaunch error: \(error)") } }
    }
    
    func testGetFirstFollow() {
        let expectation = self.expectation(description: "FirstFollow returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .firstFollow).startWithValues { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstFollow error: \(error)") } }
    }
    
    func testGetFirstInterest() {
        let expectation = self.expectation(description: "FirstInterest returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .firstInterest).startWithValues { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstInterest error: \(error)") } }
    }
    
    func testGetFirstVoteDisable() {
        let expectation = self.expectation(description: "FirstVoteDisable returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .firstVoteDisable).startWithValues { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstVoteDisable error: \(error)") } }
    }
    
    func testGetFirstSocialDisable() {
        let expectation = self.expectation(description: "FirstSocialDisable returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .firstSocialDisable).startWithValues { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstSocialDisable error: \(error)") } }
    }
    
    func testGetFirstTrollWarning() {
        let expectation = self.expectation(description: "FirstTrollWarning returns Bool")
        SettingsViewModel().getSettingSignal(settingType: .firstTrollWarning).startWithValues { value in
            XCTAssert((value as Any) is Bool); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("FirstTrollWarning error: \(error)") } }
    }
    
    func testUpdateDefaultListIndex() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set DefaultListIndex to Int(1)")
        SettingsViewModel().updateSettingSignal(value: Int(1) as AnyObject, settingType: .defaultListIndex)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { settings in
            XCTAssertEqual(settings.defaultListIndex, Int(1)); expectation.fulfill() }
       waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set DefaultListIndex error: \(error)") } }
    }
    
    func testUpdateLoginTypeIndex() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set LoginTypeIndex to Int(2)")
        SettingsViewModel().updateSettingSignal(value: Int(2) as AnyObject, settingType: .loginTypeIndex)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { settings in
            XCTAssertEqual(settings.loginTypeIndex, Int(2)); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set LoginTypeIndex error: \(error)") } }
    }
    
    func testUpdatePublicService() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set onSocialSharing to true")
        SettingsViewModel().updateSettingSignal(value: true as AnyObject, settingType: .onSocialSharing)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { settings in
            XCTAssertEqual(settings.onSocialSharing, true); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set PublicService error: \(error)") } }
    }
    
    func testUpdateonCountdown() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set onCountdown to true")
        SettingsViewModel().updateSettingSignal(value: true as AnyObject, settingType: .onCountdown)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { settings in
            XCTAssertEqual(settings.onCountdown, true); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set onCountdown error: \(error)") } }
    }
    
    func testUpdateFirstLaunch() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstLaunch to false")
        SettingsViewModel().updateSettingSignal(value: true as AnyObject, settingType: .firstLaunch)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { settings in
            XCTAssertEqual(settings.isFirstLaunch, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstLaunch error: \(error)") } }
    }
    
    func testUpdateFirstFollow() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstFollow to false")
        SettingsViewModel().updateSettingSignal(value: true as AnyObject, settingType: .firstFollow)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { settings in
            XCTAssertEqual(settings.isFirstFollow, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstFollow error: \(error)") } }
    }
    
    func testUpdateFirstInterest() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstInterest to false")
        SettingsViewModel().updateSettingSignal(value: true as AnyObject, settingType: .firstInterest)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { settings in
            XCTAssertEqual(settings.isFirstInterest, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstInterest error: \(error)") } }
    }
    
    func testUpdateFirstVoteDisable() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstVoteDisable to false")
        SettingsViewModel().updateSettingSignal(value: true as AnyObject, settingType: .firstVoteDisable)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { settings in
            XCTAssertEqual(settings.isFirstVoteDisabled, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstVoteDisable error: \(error)") } }
    }
    
    func testUpdateFirstSocialDisable() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstSocialDisable to false")
        SettingsViewModel().updateSettingSignal(value: true as AnyObject, settingType: .firstSocialDisable)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { settings in
            XCTAssertEqual(settings.isFirstSocialDisabled, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstSocialDisable error: \(error)") } }
    }
    
    func testUpdateFirstTrollWarning() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let expectation = self.expectation(description: "set FirstTrollWarning to false")
        SettingsViewModel().updateSettingSignal(value: true as AnyObject, settingType: .firstTrollWarning)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { settings in
            XCTAssertEqual(settings.isFirstTrollWarning, false); expectation.fulfill() }
        waitForExpectations(timeout: 1) { error in if let error = error { XCTFail("set FirstTrollWarning error: \(error)") } }
    }
}










