//
//  CelebrityViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import RealmSwift
import ReactiveCocoa
import Timepiece
import Result


struct CelebrityViewModel {
    
    func getCelebritySignal(id id: String) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity = realm.objects(CelebrityModel).filter("id = %@", id).first
            guard let object = celebrity else { observer.sendFailed(.NotFound); return }
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    func updateUserActivitySignal(id id: String) -> SignalProducer<NSUserActivity, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity = realm.objects(CelebrityModel).filter("id = %@", id).first
            guard let celeb = celebrity else { observer.sendFailed(.NotFound); return }

            let profile = CelebrityStruct(id: celeb.id, imageURL:celeb.picture3x, nickname:celeb.nickName, prevScore: celeb.prevScore, sex: celeb.sex, isFollowed:celeb.isFollowed)
            profile.userActivity.addUserInfoEntriesFromDictionary(profile.userActivityUserInfo)
            profile.userActivity.becomeCurrent()
            observer.sendNext(profile.userActivity)
            observer.sendCompleted()
        }
    }
    
    func followCebritySignal(id id: String, isFollowing: Bool) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity = realm.objects(CelebrityModel).filter("id = %@", id).first
            guard let object = celebrity else { observer.sendFailed(.NotFound); return }
            realm.beginWrite()
            object.isFollowed = isFollowing
            realm.add(object, update: true)
            try! realm.commitWrite()
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    func countFollowedCelebritiesSignal() -> SignalProducer<Int, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebList = realm.objects(CelebrityModel).filter("isFollowed = true")
            observer.sendNext(celebList.count)
            observer.sendCompleted()
        }
    }
}


