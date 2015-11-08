//
//  SettingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/7/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//


import Foundation
import RealmSwift

final class SettingsViewModel: NSObject {

    //MARK: Properties
    enum SettingsError: ErrorType { case NoCelebrityModels, NoSettingsModel }
    enum SettingType: Int { case DefaultListId = 0, RankSettingIndex, NotificationSettingIndex, LoginTypeIndex }
    
    
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
    
    func updateSettingOnLocalStoreSignal(value value: AnyObject, settingType: SettingType) -> SignalProducer<SettingsModel, SettingsError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            realm.beginWrite()
            
            let model = realm.objects(SettingsModel).first
            guard let settings = model else {
                sendError(sink, .NoSettingsModel)
                return
            }
            
            switch settingType {
            case .DefaultListId:
                settings.defaultListId = value as! String
            case .RankSettingIndex:
                settings.rankSettingIndex = value as! Int
            case .NotificationSettingIndex:
                settings.notificationSettingIndex = value as! Int
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
}