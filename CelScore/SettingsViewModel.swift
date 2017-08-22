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
    func calculateUserAverageCelScoreSignal() -> SignalProducer <CGFloat, NoError> {
        return SignalProducer  { observer, disposable in
            let realm = try! Realm()
            let userRatings = realm.objects(UserRatingsModel.self)
            guard userRatings.count >= 10 else { observer.send(value: 5); return }
            let celscores: [Double] = userRatings.map({ (ratings:UserRatingsModel) -> Double in return ratings.getCelScore() })
            let average = celscores.reduce(0, { $0 + $1 }) / Double(celscores.count) * 20
            observer.send(value: CGFloat(average) / 100)
            observer.sendCompleted()
        }
    }
    
    func calculateAverageRoyaltySignal() -> SignalProducer<CGFloat, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let ratings = realm.objects(RatingsModel.self)
            guard ratings.count > 0 else { observer.send(value: 60); return observer.sendCompleted() }
            let royalties: [Double] = ratings.map{ (ratingModel: RatingsModel) -> Double in return ratingModel.getCelScore() }
            let average = royalties.reduce(0, { $0 + $1 }) / Double(ratings.count)
            observer.send(value: CGFloat(average.roundToPlaces(places: 1) / 100))
            observer.sendCompleted()
        }
    }
    
    func calculatePrevAverageRoyaltySignal(day: PrevDay) -> SignalProducer<CGFloat, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebs = realm.objects(CelebrityModel.self)
            guard celebs.count > 0 else { observer.send(value: 60); return observer.sendCompleted() }
            let royalties: [Double] = celebs.map{ (celebModel: CelebrityModel) -> Double in
                switch day {
                case .Yesterday: return celebModel.prevScore
                case .LastWeek: return celebModel.prevWeek
                case .LastMonth: return celebModel.prevMonth
                }
            }
            let average = royalties.reduce(0, { $0 + $1 }) / Double(celebs.count)
            observer.send(value: CGFloat(average.roundToPlaces(places: 1) / 100))
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
            case .onCountdown: observer.send(value: settings.onCountdown as AnyObject)
            case .firstInterest: observer.send(value: settings.isFirstInterest as AnyObject)
            case .firstVoteDisable: observer.send(value: settings.isFirstVoteDisabled as AnyObject)
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
            case .onCountdown: settings.onCountdown = value as! Bool
            case .firstInterest: settings.isFirstInterest = false
            case .firstVoteDisable: settings.isFirstVoteDisabled = false
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

