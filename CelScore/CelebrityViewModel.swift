//
//  CelebrityViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import RealmSwift
import ReactiveCocoa
import ReactiveSwift
import Result


struct CelebrityViewModel {
    
    func getCelebritySignal(id: String) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity = realm.objects(CelebrityModel.self).filter("id = %@", id).first
            guard let object = celebrity else { return observer.send(error: .notFound) }
            observer.send(value: object)
            observer.sendCompleted()
        }
    }
    
    func updateUserActivitySignal(id: String) -> SignalProducer<NSUserActivity, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity = realm.objects(CelebrityModel.self).filter("id = %@", id).first
            guard let celeb = celebrity else { return observer.send(error: .notFound) }
            let profile = CelebrityStruct(id: celeb.id,
                                          imageURL: celeb.picture3x,
                                          trend: celeb.trend,
                                          nickName: celeb.nickName,
                                          kingName: celeb.kingName,
                                          prevScore: celeb.prevScore,
                                          prevWeek: celeb.prevWeek,
                                          prevMonth: celeb.prevMonth,
                                          index: celeb.index,
                                          y_index: celeb.y_index,
                                          daysOnThrone: celeb.daysOnThrone,
                                          sex: celeb.sex,
                                          isFollowed: celeb.isFollowed,
                                          isTrending: celeb.isTrending)
            profile.userActivity.addUserInfoEntries(from: profile.userActivityUserInfo)
            observer.send(value: profile.userActivity)
            observer.sendCompleted()
        }
    }
    
    func followCebritySignal(id: String, isFollowing: Bool) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity = realm.objects(CelebrityModel.self).filter("id = %@", id).first
            guard let object = celebrity else { return observer.send(error: .notFound) }
            realm.beginWrite()
            object.isFollowed = isFollowing
            realm.add(object, update: true)
            try! realm.commitWrite()
            observer.send(value: object)
            observer.sendCompleted()
        }
    }
    
    func setLastVisitSignal(celebId: String) -> SignalProducer<RatingsModel, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celeb = realm.objects(CelebrityModel.self).filter("id = %@", celebId).first
            guard let object = celeb else { return }
            
            if object.lastVisit.characters.count > 0 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let visit = dateFormatter.date(from: object.lastVisit)!
                let today = dateFormatter.date(from: Date().stringMMddyyyyFormat())!
                let compare = visit.compare(today) == ComparisonResult.orderedAscending
                guard compare else { return }
            }
            realm.beginWrite()
            object.lastVisit = Date().stringMMddyyyyFormat()
            realm.add(object, update: true)
            try! realm.commitWrite()
            realm.refresh()
            
            let ratings = realm.objects(RatingsModel.self).filter("id = %@", celebId).first
            observer.send(value: ratings!)
            observer.sendCompleted()
        }
    }
    
    func getWelcomeRuleMessageSignal() -> SignalProducer<String, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celeb = realm.objects(CelebrityModel.self).filter("index = 1").first
            let message = "Day \(celeb!.daysOnThrone) of \(celeb!.kingName)'s era!"
            observer.send(value: message)
            observer.sendCompleted()
        }
    }
    
    func countFollowedCelebritiesSignal() -> SignalProducer<Int, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebList = realm.objects(CelebrityModel.self).filter("isFollowed = true")
            observer.send(value: celebList.count)
            observer.sendCompleted()
        }
    }
    
    func countCelebritiesSignal() -> SignalProducer<Int, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebList = realm.objects(CelebrityModel.self)
            observer.send(value: celebList.count)
            observer.sendCompleted()
        }
    }
    
    func getCelebrityStructSignal(id: String) -> SignalProducer<CelebrityStruct, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celeb = realm.objects(CelebrityModel.self).filter("id = %@", id).first
            guard celeb?.id.isEmpty == false else { return }
            observer.send(value: CelebrityStruct(id: celeb!.id, imageURL: celeb!.picture3x, trend: celeb!.trend, nickName:celeb!.nickName, kingName: celeb!.kingName, prevScore: celeb!.prevScore, prevWeek: celeb!.prevWeek, prevMonth: celeb!.prevMonth, index: celeb!.index, y_index: celeb!.y_index, daysOnThrone: celeb!.daysOnThrone, sex: celeb!.sex, isFollowed: celeb!.isFollowed, isTrending: celeb!.isTrending))
            observer.sendCompleted()
        }
    }
}


