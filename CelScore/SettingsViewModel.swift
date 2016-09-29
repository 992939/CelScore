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
    enum SettingsError: Int, Error { case noCelebrityModels, noRatingsModel, noUserRatingsModel, outOfBoundsVariance, noUser }
    enum SettingType: Int { case defaultListIndex = 0, loginTypeIndex, publicService, consensusBuilding, firstLaunch, firstConsensus, firstPublic, firstFollow, firstInterest, firstCompleted, first25, first50, first75, firstVoteDisable, firstSocialDisable, firstTrollWarning }
    
    //MARK: Methods
    func calculateUserRatingsPercentageSignal() -> SignalProducer <CGFloat, NoError> {
        return SignalProducer  { observer, disposable in
            let realm = try! Realm()
            let userRatings = realm.objects(UserRatingsModel)
            guard userRatings.count > 4 else { return observer.sendNext(0) }
            
            let publicList = realm.objects(ListsModel).filter("id = '0001'").first
            guard let list = publicList else { return observer.sendNext(0) }
            
            let userRatingCount = list.celebList.enumerate().filter({ (item: (index: Int, celebId: CelebId)) -> Bool in
                return userRatings.enumerate().contains({ (_, rating: RatingsModel) -> Bool in return rating.id == item.celebId.id })
            })
            
            observer.sendNext(CGFloat(Double(userRatingCount.count)/Double(list.celebList.count)))
            observer.sendCompleted()
        }
    }
    
    func calculateUserAverageCelScoreSignal() -> SignalProducer <CGFloat, NoError> {
        return SignalProducer  { observer, disposable in
            let realm = try! Realm()
            let userRatings = realm.objects(UserRatingsModel)
            guard userRatings.count >= 10 else { observer.sendNext(5); return }
            let celscores: [Double] = userRatings.map({ (ratings:UserRatingsModel) -> Double in return ratings.getCelScore() })
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
    
    func calculateSocialConsensusSignal() -> SignalProducer<CGFloat, SettingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(RatingsModel)
            guard ratings.count > 0 else { observer.sendNext(0); return observer.sendCompleted() }
            let variances: [Double] = ratings.map{ (ratingsModel: RatingsModel) -> Double in return ratingsModel.getAvgVariance() }
            let averageVariance = variances.reduce(0, combine: { $0 + $1 }) / Double(variances.count)
            guard 0..<5 ~= averageVariance else { observer.sendNext(0); return observer.sendCompleted() }
            let consensus: Double = 1 - Double(0.2 * averageVariance)
            observer.sendNext(CGFloat(consensus))
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
    
    func updateUserNameSignal(username: String) -> SignalProducer<SettingsModel, NSError> {
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
    
    func getSettingSignal(settingType: SettingType) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let settings = realm.objects(SettingsModel).first ?? SettingsModel()
            switch settingType {
            case .DefaultListIndex: observer.sendNext(settings.defaultListIndex)
            case .LoginTypeIndex: observer.sendNext(settings.loginTypeIndex)
            case .PublicService: observer.sendNext(settings.publicService)
            case .ConsensusBuilding: observer.sendNext(settings.consensusBuilding)
            case .FirstLaunch: observer.sendNext(settings.isFirstLaunch)
            case .FirstConsensus: observer.sendNext(settings.isFirstConsensus)
            case .FirstPublic: observer.sendNext(settings.isFirstPublic)
            case .FirstFollow: observer.sendNext(settings.isFirstFollow)
            case .FirstInterest: observer.sendNext(settings.isFirstInterest)
            case .FirstCompleted: observer.sendNext(settings.isFirstCompleted)
            case .First25: observer.sendNext(settings.isFirst25)
            case .First50: observer.sendNext(settings.isFirst50)
            case .First75: observer.sendNext(settings.isFirst75)
            case .FirstVoteDisable: observer.sendNext(settings.isFirstVoteDisabled)
            case .FirstSocialDisable: observer.sendNext(settings.isFirstSocialDisabled)
            case .FirstTrollWarning: observer.sendNext(settings.isFirstTrollWarning)
            }
            observer.sendCompleted()
        }
    }
    
    func updateSettingSignal(value: AnyObject, settingType: SettingType) -> SignalProducer<SettingsModel, NSError> {
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
            case .FirstInterest: settings.isFirstInterest = false
            case .FirstCompleted: settings.isFirstCompleted = false
            case .First25: settings.isFirst25 = false
            case .First50: settings.isFirst50 = false
            case .First75: settings.isFirst75 = false
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
            let userDefaults: NSUserDefaults = NSUserDefaults(suiteName:"group.NotificationApp")!
            if celebList.count > 0 {
                for (index, celeb) in celebList.enumerate() {
                    let ratings: RatingsModel = realm.objects(RatingsModel).filter("id = %@", celeb.id).first ?? RatingsModel(id: celeb.id)
                    let today:[String: AnyObject] = ["id": celeb.id, "nickName": celeb.nickName, "image": celeb.picture3x, "prevScore": celeb.prevScore, "currentScore": ratings.getCelScore()]
                    userDefaults.setObject(today, forKey: String(index))
                }
            }
            userDefaults.setInteger(celebList.count, forKey: "count")
            observer.sendNext(celebList)
            observer.sendCompleted()
        }
    }
}

