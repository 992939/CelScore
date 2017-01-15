//
//  SettingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/7/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import RealmSwift
import ReactiveCocoa
import ReactiveSwift
import Result


struct SettingsViewModel {
    
    //MARK: Methods
    func calculateUserRatingsPercentageSignal() -> SignalProducer <CGFloat, NoError> {
        return SignalProducer  { observer, disposable in
            let realm = try! Realm()
            let userRatings = realm.objects(UserRatingsModel.self)
            guard userRatings.count > 4 else { return observer.send(value: 0) }
            
            let publicList = realm.objects(ListsModel.self).filter("id = '0001'").first
            guard let list = publicList else { return observer.send(value: 0) }
            
            let userRatingCount = list.celebList.enumerated().filter({ (item: (index: Int, celebId: CelebId)) -> Bool in
                return userRatings.enumerated().contains(where: { (_, rating: RatingsModel) -> Bool in return rating.id == item.celebId.id })
            })
            
            observer.send(value: CGFloat(Double(userRatingCount.count)/Double(list.celebList.count)))
            observer.sendCompleted()
        }
    }
    
    func calculateUserAverageCelScoreSignal() -> SignalProducer <CGFloat, NoError> {
        return SignalProducer  { observer, disposable in
            let realm = try! Realm()
            let userRatings = realm.objects(UserRatingsModel.self)
            guard userRatings.count >= 10 else { observer.send(value: 5); return }
            let celscores: [Double] = userRatings.map({ (ratings:UserRatingsModel) -> Double in return ratings.getCelScore() })
            let average = celscores.reduce(0, { $0 + $1 }) / Double(celscores.count)
            observer.send(value: CGFloat(average))
            observer.sendCompleted()
        }
    }
    
    func calculatePositiveVoteSignal() -> SignalProducer<CGFloat, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(UserRatingsModel.self)
            guard ratings.count > 4 else { observer.send(value: 0); return }
            let positiveRatings = ratings.filter({ (ratingsModel: RatingsModel) -> Bool in
                return ratingsModel.getCelScore() < 3 ? false : true
            })
            observer.send(value: CGFloat(Double(positiveRatings.count)/Double(ratings.count)))
            observer.sendCompleted()
        }
    }
    
    func calculateSocialConsensusSignal() -> SignalProducer<CGFloat, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(RatingsModel.self)
            guard ratings.count > 0 else { observer.send(value: 0); return observer.sendCompleted() }
            let variances: [Double] = ratings.map{ (ratingsModel: RatingsModel) -> Double in return ratingsModel.getAvgVariance() }
            let averageVariance = variances.reduce(0, { $0 + $1 }) / Double(variances.count)
            guard 0..<5 ~= averageVariance else { observer.send(value: 0); return observer.sendCompleted() }
            let consensus: Double = 1 - Double(0.2 * averageVariance)
            observer.send(value: CGFloat(consensus))
            observer.sendCompleted()
        }
    }
    
    func loggedInAsSignal() -> SignalProducer<String, SettingsError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let model = realm.objects(SettingsModel.self).first ?? SettingsModel()
            guard model.userName.characters.count > 0 else { observer.send(error: .noUser); return }
            observer.send(value: model.userName)
            observer.sendCompleted()
        }
    }
    
    func updateUserNameSignal(username: String) -> SignalProducer<SettingsModel, NSError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            realm.beginWrite()
            let model: SettingsModel = realm.objects(SettingsModel.self).first ?? SettingsModel()
            model.userName = username
            realm.add(model, update: true)
            try! realm.commitWrite()
            observer.send(value: model)
            observer.sendCompleted()
        }
    }
    
    func getSettingSignal(settingType: SettingType) -> SignalProducer<AnyObject, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let settings = realm.objects(SettingsModel.self).first ?? SettingsModel()
            switch settingType {
            case .defaultListIndex: observer.send(value: settings.defaultListIndex as AnyObject)
            case .loginTypeIndex: observer.send(value: settings.loginTypeIndex as AnyObject)
            case .publicService: observer.send(value: settings.publicService as AnyObject)
            case .onCountdown: observer.send(value: settings.onCountdown as AnyObject)
            case .firstLaunch: observer.send(value: settings.isFirstLaunch as AnyObject)
            case .firstConsensus: observer.send(value: settings.isFirstConsensus as AnyObject)
            case .firstPublic: observer.send(value: settings.isFirstPublic as AnyObject)
            case .firstFollow: observer.send(value: settings.isFirstFollow as AnyObject)
            case .firstInterest: observer.send(value: settings.isFirstInterest as AnyObject)
            case .firstCompleted: observer.send(value: settings.isFirstCompleted as AnyObject)
            case .first25: observer.send(value: settings.isFirst25 as AnyObject)
            case .first50: observer.send(value: settings.isFirst50 as AnyObject)
            case .first75: observer.send(value: settings.isFirst75 as AnyObject)
            case .firstVoteDisable: observer.send(value: settings.isFirstVoteDisabled as AnyObject)
            case .firstSocialDisable: observer.send(value: settings.isFirstSocialDisabled as AnyObject)
            case .firstTrollWarning: observer.send(value: settings.isFirstTrollWarning as AnyObject)
            }
            observer.sendCompleted()
        }
    }
    
    func updateSettingSignal(value: AnyObject, settingType: SettingType) -> SignalProducer<SettingsModel, NSError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            realm.beginWrite()
            let settings = realm.objects(SettingsModel.self).first ?? SettingsModel()
            switch settingType {
            case .defaultListIndex: settings.defaultListIndex = value as! Int
            case .loginTypeIndex: settings.loginTypeIndex = value as! Int
            case .publicService: settings.publicService = value as! Bool
            case .onCountdown: settings.onCountdown = value as! Bool
            case .firstLaunch: settings.isFirstLaunch = false
            case .firstConsensus: settings.isFirstConsensus = false
            case .firstPublic: settings.isFirstPublic = false
            case .firstFollow: settings.isFirstFollow = false
            case .firstInterest: settings.isFirstInterest = false
            case .firstCompleted: settings.isFirstCompleted = false
            case .first25: settings.isFirst25 = false
            case .first50: settings.isFirst50 = false
            case .first75: settings.isFirst75 = false
            case .firstVoteDisable: settings.isFirstVoteDisabled = false
            case .firstSocialDisable: settings.isFirstSocialDisabled = false
            case .firstTrollWarning: settings.isFirstTrollWarning = false
            }
            settings.isSynced = false
            realm.add(settings, update: true)
            try! realm.commitWrite()
            
            observer.send(value: settings)
            observer.sendCompleted()
        }
    }
    
    func updateTodayWidgetSignal() -> SignalProducer<Results<CelebrityModel>, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebList = realm.objects(CelebrityModel.self).filter("isFollowed = true")
            let userDefaults: UserDefaults = UserDefaults(suiteName:"group.NotificationApp")!
            if celebList.count > 0 {
                for (index, celeb) in celebList.enumerated() {
                    let ratings: RatingsModel = realm.objects(RatingsModel.self).filter("id = %@", celeb.id).first ?? RatingsModel(id: celeb.id)
                    let today:[String: AnyObject] = ["id": celeb.id as AnyObject, "nickName": celeb.nickName as AnyObject, "image": celeb.picture3x as AnyObject, "prevScore": celeb.prevScore as AnyObject, "currentScore": ratings.getCelScore() as AnyObject]
                    userDefaults.set(today, forKey: String(index))
                }
            }
            userDefaults.set(celebList.count, forKey: "count")
            observer.send(value: celebList)
            observer.sendCompleted()
        }
    }
}

