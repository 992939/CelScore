//
//  SettingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/7/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import RealmSwift
import ReactiveCocoa
import Result


struct SettingsViewModel {
    
    //MARK: Widget
    enum SettingsError: ErrorType { case NoCelebrityModels, NoRatingsModel, NoUserRatingsModel, OutOfBoundsVariance, NoUser }
    enum SettingType: Int { case DefaultListIndex = 0, LoginTypeIndex, PublicService, ConsensusBuilding, FirstLaunch, FirstConsensus, FirstPublic, FirstFollow, FirstStars, FirstNegative, FirstInterest, FirstCompleted, FirstVoteDisable, FirstSocialDisable, FirstTrollWarning }
    
    //MARK: Methods
    func calculateUserRatingsPercentageSignal() -> SignalProducer <CGFloat, NoError> {
        return SignalProducer  { observer, disposable in
            let realm = try! Realm()
            let userRatingsCount: Int = realm.objects(UserRatingsModel).count
            guard userRatingsCount > 4 else { observer.sendNext(0); return }
            let celebrityCount: Int = realm.objects(CelebrityModel).count
            observer.sendNext(CGFloat(Double(userRatingsCount)/Double(celebrityCount)))
            observer.sendCompleted()
        }
    }
    
    func calculateUserAverageCelScoreSignal() -> SignalProducer <CGFloat, NoError> {
        return SignalProducer  { observer, disposable in
            let realm = try! Realm()
            let userRatings = realm.objects(UserRatingsModel)
            guard userRatings.count >= 10 else { return } //observer.sendNext(5); 
            let celscores = userRatings.map({ (ratings:UserRatingsModel) -> Double in return ratings.getCelScore() })
            let average = celscores.reduce(0, combine: { $0 + $1 }) / Double(celscores.count)
            observer.sendNext(CGFloat(average))
            observer.sendCompleted()
        }
    }
    
    func calculatePositiveVoteSignal() -> SignalProducer<CGFloat, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(UserRatingsModel)
            guard ratings.count > 4 else { observer.sendNext(0); return }
            let positiveRatings = ratings.filter({ (ratingsModel: RatingsModel) -> Bool in
                return ratingsModel.getCelScore() < 3 ? false : true
            })
            observer.sendNext(CGFloat(Double(positiveRatings.count)/Double(ratings.count)))
            observer.sendCompleted()
        }
    }
    
    func isPositiveVoteSignal() -> SignalProducer<Bool, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(UserRatingsModel)
            guard ratings.count > 4 else { observer.sendNext(true); return }
            let positiveRatings = ratings.filter({ (ratingsModel: RatingsModel) -> Bool in
                return ratingsModel.getCelScore() < 3 ? false : true
            })
            let average = Double(positiveRatings.count)/Double(ratings.count)
            observer.sendNext(average < 0.5 ? false : true)
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
    
    func getSettingSignal(settingType settingType: SettingType) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let model: SettingsModel? = realm.objects(SettingsModel).first
            if let settings = model {
                switch settingType {
                case .DefaultListIndex: observer.sendNext(settings.defaultListIndex)
                case .LoginTypeIndex: observer.sendNext(settings.loginTypeIndex)
                case .PublicService: observer.sendNext(settings.publicService)
                case .ConsensusBuilding: observer.sendNext(settings.consensusBuilding)
                case .FirstLaunch: observer.sendNext(settings.isFirstLaunch)
                case .FirstConsensus: observer.sendNext(settings.isFirstConsensus)
                case .FirstPublic: observer.sendNext(settings.isFirstPublic)
                case .FirstFollow: observer.sendNext(settings.isFirstFollow)
                case .FirstStars: observer.sendNext(settings.isFirstStars)
                case .FirstNegative: observer.sendNext(settings.isFirstNegative)
                case .FirstInterest: observer.sendNext(settings.isFirstInterest)
                case .FirstCompleted: observer.sendNext(settings.isFirstCompleted)
                case .FirstVoteDisable: observer.sendNext(settings.isFirstVoteDisabled)
                case .FirstSocialDisable: observer.sendNext(settings.isFirstSocialDisabled)
                case .FirstTrollWarning: observer.sendNext(settings.isFirstTrollWarning)
                }
            } else {
                switch settingType {
                case .DefaultListIndex: observer.sendNext(SettingsModel().defaultListIndex)
                case .LoginTypeIndex: observer.sendNext(SettingsModel().loginTypeIndex)
                case .PublicService: observer.sendNext(SettingsModel().publicService)
                case .ConsensusBuilding: observer.sendNext(SettingsModel().consensusBuilding)
                case .FirstLaunch: observer.sendNext(SettingsModel().isFirstLaunch)
                case .FirstConsensus: observer.sendNext(SettingsModel().isFirstConsensus)
                case .FirstPublic: observer.sendNext(SettingsModel().isFirstPublic)
                case .FirstFollow: observer.sendNext(SettingsModel().isFirstFollow)
                case .FirstStars: observer.sendNext(SettingsModel().isFirstStars)
                case .FirstNegative: observer.sendNext(SettingsModel().isFirstNegative)
                case .FirstInterest: observer.sendNext(SettingsModel().isFirstInterest)
                case .FirstCompleted: observer.sendNext(SettingsModel().isFirstCompleted)
                case .FirstVoteDisable: observer.sendNext(SettingsModel().isFirstVoteDisabled)
                case .FirstSocialDisable: observer.sendNext(SettingsModel().isFirstSocialDisabled)
                case .FirstTrollWarning: observer.sendNext(SettingsModel().isFirstTrollWarning)
                }
            }
            observer.sendCompleted()
        }
    }
    
    func loggedInAsSignal() -> SignalProducer<String, SettingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let model = realm.objects(SettingsModel).first ?? SettingsModel()
            guard model.userName.characters.count > 0 else { observer.sendFailed(.NoUser); return }
            observer.sendNext(model.userName)
            observer.sendCompleted()
        }
    }
    
    func updateUserName(username username: String) -> SignalProducer<SettingsModel, NSError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            realm.beginWrite()
            let model: SettingsModel = realm.objects(SettingsModel).first ?? SettingsModel()
            model.userName = username
            realm.add(model, update: true)
            try! realm.commitWrite()
            observer.sendNext(model)
            observer.sendCompleted()
        }
    }
    
    func updateSettingSignal(value value: AnyObject, settingType: SettingType) -> SignalProducer<SettingsModel, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            realm.beginWrite()
            let settings = realm.objects(SettingsModel).first ?? SettingsModel()
            switch settingType {
            case .DefaultListIndex: settings.defaultListIndex = value as! Int
            case .LoginTypeIndex: settings.loginTypeIndex = value as! Int
            case .PublicService: settings.publicService = value as! Bool
            case .ConsensusBuilding: settings.consensusBuilding = value as! Bool
            case .FirstLaunch: settings.isFirstLaunch = false
            case .FirstConsensus: settings.isFirstConsensus = false
            case .FirstPublic: settings.isFirstPublic = false
            case .FirstFollow: settings.isFirstFollow = false
            case .FirstStars: settings.isFirstStars = false
            case .FirstNegative: settings.isFirstNegative = false
            case .FirstInterest: settings.isFirstInterest = false
            case .FirstCompleted: settings.isFirstCompleted = false
            case .FirstVoteDisable: settings.isFirstVoteDisabled = false
            case .FirstSocialDisable: settings.isFirstSocialDisabled = false
            case .FirstTrollWarning: settings.isFirstTrollWarning = false
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

