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
    enum SettingsError: ErrorType { case NoCelebrityModels, NoRatingsModel, NoUserRatingsModel, OutOfBoundsVariance }
    enum SettingType: Int { case DefaultListIndex = 0, LoginTypeIndex, PublicService, FortuneMode}
    enum LoginType: Int { case None = 1, Facebook, Twitter }
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
    func calculateUserRatingsPercentageSignal() -> SignalProducer<CGFloat, SettingsError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let userRatingsCount: Int = realm.objects(UserRatingsModel).count
            let celebrityCount: Int = realm.objects(CelebrityModel).count
            guard celebrityCount > 1 else { sendError(sink, .NoCelebrityModels); return }
            sendNext(sink, CGFloat(Double(userRatingsCount)/Double(celebrityCount)))
            sendCompleted(sink)
        }
    }
    
    func calculateSocialConsensusSignal() -> SignalProducer<CGFloat, SettingsError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let ratings = realm.objects(RatingsModel)
            guard ratings.count > 0 else { sendError(sink, .NoRatingsModel); return }

            let variances = ratings.map{ (ratingsModel: RatingsModel) -> Double in
                return (ratingsModel.variance1 + ratingsModel.variance2 + ratingsModel.variance3 + ratingsModel.variance4 + ratingsModel.variance5
                + ratingsModel.variance6 + ratingsModel.variance7 + ratingsModel.variance8 + ratingsModel.variance9 + ratingsModel.variance10) / 10
            }
            let averageVariance = variances.reduce(0, combine: { $0 + $1 }) / Double(variances.count)
            guard averageVariance > 0 && averageVariance < 5  else { sendError(sink, .OutOfBoundsVariance); return }
            let consensus: Double = 1 - Double(0.2 * averageVariance)
            sendNext(sink, CGFloat(consensus))
            sendCompleted(sink)
        }
    }
    
    func calculatePositiveVoteSignal() -> SignalProducer<CGFloat, SettingsError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let ratings = realm.objects(UserRatingsModel)
            guard ratings.count > 0 else { sendError(sink, .NoUserRatingsModel); return }
            
            let positiveRatings = ratings.filter({ (ratingsModel: RatingsModel) -> Bool in
                let celscore = (ratingsModel.rating1 + ratingsModel.rating2 + ratingsModel.rating3 + ratingsModel.rating4 + ratingsModel.rating5
                + ratingsModel.rating6 + ratingsModel.rating7 + ratingsModel.rating8 + ratingsModel.rating9 + ratingsModel.rating10) / 10
                return celscore >= 3 ? true : false
            })
            sendNext(sink, CGFloat(Double(positiveRatings.count)/Double(ratings.count)))
            sendCompleted(sink)
        }
    }
    
    func getSettingSignal(settingType settingType: SettingType) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let model: SettingsModel? = realm.objects(SettingsModel).first
            if let settings = model {
                switch settingType {
                case .DefaultListIndex: sendNext(sink, settings.defaultListIndex)
                case .LoginTypeIndex: sendNext(sink, settings.loginTypeIndex)
                case .PublicService: sendNext(sink, settings.publicService)
                case .FortuneMode: sendNext(sink, settings.fortuneMode)
                }
            } else {
                switch settingType {
                case .DefaultListIndex: sendNext(sink, SettingsModel().defaultListIndex)
                case .LoginTypeIndex: sendNext(sink, SettingsModel().loginTypeIndex)
                case .PublicService: sendNext(sink, SettingsModel().publicService)
                case .FortuneMode: sendNext(sink, SettingsModel().fortuneMode)
                }
            }
            sendCompleted(sink)
        }
    }
    
    func updateSettingSignal(value value: AnyObject, settingType: SettingType) -> SignalProducer<SettingsModel, NoError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            realm.beginWrite()
            
            var model = realm.objects(SettingsModel).first
            if model == nil { model = SettingsModel() }
            let settings: SettingsModel = model!
            
            switch settingType {
            case .DefaultListIndex: settings.defaultListIndex = value as! Int
            case .LoginTypeIndex: settings.loginTypeIndex = value as! Int
            case .PublicService: settings.publicService = value as! Bool
            case .FortuneMode: settings.fortuneMode = value as! Bool
            }
            settings.isSynced = false
            realm.add(settings, update: true)
            try! realm.commitWrite()
            
            sendNext(sink, settings)
            sendCompleted(sink)
        }
    }
    
    func updateTodayWidgetSignal() -> SignalProducer<Results<CelebrityModel>, NoError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "isFollowed = true")
            let celebList = realm.objects(CelebrityModel).filter(predicate)
            let userDefaults = NSUserDefaults(suiteName:"group.NotificationApp")
            if celebList.count > 0 {
                for (index, celeb) in celebList.enumerate() {
                    let idPredicate = NSPredicate(format: "id = %@", celeb.id)
                    let ratings: RatingsModel = realm.objects(RatingsModel).filter(idPredicate).first!.copy() as! RatingsModel
                    let totalRatings: Double = ratings.map{ratings[$0] as! Double }.reduce(0, combine: { $0 + $1 })
                    let currentScore: Double = totalRatings/10
                    let today = ["nickName": celeb.nickName, "image": celeb.picture2x, "prevScore": celeb.prevScore, "currentScore": currentScore]
                    userDefaults!.setObject(today, forKey: String(index))
                }
            }
            userDefaults!.setInteger(celebList.count, forKey: "count")
            sendNext(sink, celebList)
            sendCompleted(sink)
        }
    }
}

