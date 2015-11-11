//
//  SettingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/7/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//


import Foundation
import RealmSwift
import ReactiveCocoa


final class SettingsViewModel: NSObject {

    //MARK: Properties
    var defaultListId: String = "0001"
    let defaultTodayExtensionNumRows = 3
    let maxTodayExtensionNumberOfRows = 10
    enum SettingsError: ErrorType { case NoCelebrityModels, NoSettingsModel }
    enum SettingType: Int { case DefaultListId = 0, LoginTypeIndex }
    enum LoginType: Int { case None = 1, Facebook, Twitter }
    
    
    //MARK: Initializers
    override init() { super.init() }
    
    
    //MARK: Methods
    func getUserRatingsPercentageSignal() -> SignalProducer<Int, SettingsError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            let userRatingsCount: Int = realm.objects(UserRatingsModel).count
            let celebrityCount: Int = realm.objects(CelebrityModel).count
            
            guard celebrityCount > 1 else {
                sendError(sink, .NoCelebrityModels)
                return
            }
            sendNext(sink, userRatingsCount/celebrityCount)
            sendCompleted(sink)
        }
    }
    
    func getSettingsFromLocalStoreSignal() -> SignalProducer<SettingsModel, SettingsError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            let model = realm.objects(SettingsModel).first
            
            guard let settings = model else {
                sendError(sink, .NoSettingsModel)
                return
            }
            sendNext(sink, settings)
            sendCompleted(sink)
        }
    }
    
    func updateSettingOnLocalStoreSignal(value value: AnyObject, settingType: SettingType) -> SignalProducer<SettingsModel, NoError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            realm.beginWrite()
            
            var model = realm.objects(SettingsModel).first
            if model == nil { model = SettingsModel() }
            let settings: SettingsModel = model!
            
            switch settingType {
            case .DefaultListId:
                settings.defaultListId = value as! String
            case .LoginTypeIndex:
                settings.loginTypeIndex = value as! Int
            }
            settings.isSynced = false
            realm.add(settings, update: true)
            try! realm.commitWrite()
            
            sendNext(sink, settings)
            sendCompleted(sink)
        }
    }
    
    func getNumberOfFollowedCelebritiesSignal() -> SignalProducer<Int, NoError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            
            let predicate = NSPredicate(format: "isFollowed = true")
            let count = realm.objects(CelebrityModel).filter(predicate).count
            
            sendNext(sink, count)
            sendCompleted(sink)
        }
    }
}

