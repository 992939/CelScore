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
import Result


final class SettingsViewModel: NSObject {
    
    //MARK: for widget
    enum SettingsError: ErrorType { case NoCelebrityModels, NoRatingsModel, NoUserRatingsModel, OutOfBoundsVariance }
    enum SettingType: Int { case DefaultListIndex = 0, LoginTypeIndex, PublicService, FortuneMode }

    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
    func calculateUserRatingsPercentageSignal() -> SignalProducer <CGFloat, SettingsError> {
        return SignalProducer  { observer, disposable in
            let realm = try! Realm()
            let userRatingsCount: Int = realm.objects(UserRatingsModel).count
            let celebrityCount: Int = realm.objects(CelebrityModel).count
            guard celebrityCount > 1 else { observer.sendFailed(.NoCelebrityModels); return }
            observer.sendNext(CGFloat(Double(userRatingsCount)/Double(celebrityCount)))
            observer.sendCompleted()
        }
    }
    
    func calculateSocialConsensusSignal() -> SignalProducer<CGFloat, SettingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(RatingsModel)
            guard ratings.count > 0 else { observer.sendFailed(.NoRatingsModel); return }

            let variances = ratings.map{ (ratingsModel: RatingsModel) -> Double in return ratingsModel.getAvgVariance() }
            let averageVariance = variances.reduce(0, combine: { $0 + $1 }) / Double(variances.count)
            guard 0..<5 ~= averageVariance else { observer.sendFailed(.OutOfBoundsVariance); return }
            let consensus: Double = 1 - Double(0.2 * averageVariance)
            observer.sendNext(CGFloat(consensus))
            observer.sendCompleted()
        }
    }
    
    func calculatePositiveVoteSignal() -> SignalProducer<CGFloat, SettingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(UserRatingsModel)
            guard ratings.count > 0 else { observer.sendFailed(.NoUserRatingsModel); return }
            let positiveRatings = ratings.filter({ (ratingsModel: RatingsModel) -> Bool in
                return ratingsModel.getCelScore() < 3 ? false : true
            })
            observer.sendNext(CGFloat(Double(positiveRatings.count)/Double(ratings.count)))
            observer.sendCompleted()
        }
    }
    
    func getSettingSignal(settingType settingType: SettingType) -> SignalProducer<AnyObject, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let model: SettingsModel? = realm.objects(SettingsModel).first
            if let settings = model {
                switch settingType {
                case .DefaultListIndex: observer.sendNext(settings.defaultListIndex)
                case .LoginTypeIndex: observer.sendNext(settings.loginTypeIndex)
                case .PublicService: observer.sendNext(settings.publicService)
                case .FortuneMode: observer.sendNext(settings.fortuneMode)
                }
            } else {
                switch settingType {
                case .DefaultListIndex: observer.sendNext(SettingsModel().defaultListIndex)
                case .LoginTypeIndex: observer.sendNext(SettingsModel().loginTypeIndex)
                case .PublicService: observer.sendNext(SettingsModel().publicService)
                case .FortuneMode: observer.sendNext(SettingsModel().fortuneMode)
                }
            }
            observer.sendCompleted()
        }
    }
    
    func isLoggedInSignal() -> SignalProducer<Bool, NSError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let model = realm.objects(SettingsModel).first
            //guard model!.userName.isEmpty == false else { observer.sendFailed(NSError(domain: "NoList", code: 1, userInfo: nil)); return }
            observer.sendNext(true)
            observer.sendCompleted()
        }
    }
    
    func updateSettingSignal(value value: AnyObject, settingType: SettingType) -> SignalProducer<SettingsModel, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            realm.beginWrite()
            let settings = realm.objects(SettingsModel).isEmpty ? SettingsModel() : realm.objects(SettingsModel).first! //TODO: check .isEmpty
            switch settingType {
            case .DefaultListIndex: settings.defaultListIndex = value as! Int
            case .LoginTypeIndex: settings.loginTypeIndex = value as! Int
            case .PublicService: settings.publicService = value as! Bool
            case .FortuneMode: settings.fortuneMode = value as! Bool
            }
            settings.isSynced = false
            realm.add(settings, update: true)
            try! realm.commitWrite()
            
            observer.sendNext(settings)
            observer.sendCompleted()
        }
    }
    
    func updateTodayWidgetSignal() -> SignalProducer<Results<CelebrityModel>, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebList = realm.objects(CelebrityModel).filter("isFollowed = true")
            let userDefaults = NSUserDefaults(suiteName:"group.NotificationApp")
            if celebList.count > 0 {
                for (index, celeb) in celebList.enumerate() {
                    let ratings: RatingsModel = realm.objects(RatingsModel).filter("id = %@", celeb.id).first!.copy() as! RatingsModel
                    let today = ["nickName": celeb.nickName, "image": celeb.picture3x, "prevScore": celeb.prevScore, "currentScore": ratings.getCelScore()]
                    userDefaults!.setObject(today, forKey: String(index))
                }
            }
            userDefaults!.setInteger(celebList.count, forKey: "count")
            observer.sendNext(celebList)
            observer.sendCompleted()
        }
    }
}

