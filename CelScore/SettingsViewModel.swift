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
    
    func getSettingsFromLocalStoreSignal() -> SignalProducer<SettingsModel!, SettingsError> {
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
    
    func setSettingsOnLocalStoreSignal() -> SignalProducer<SettingsModel!, SettingsError> {
        return SignalProducer { sink, _ in
            
        }
    }
}