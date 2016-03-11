//
//  CelebrityViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveCocoa
import Timepiece
import Result


final class CelebrityViewModel: NSObject {
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
    func getCelebritySignal(id id: String) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter("id = %@", id).first!.copy() as? CelebrityModel
            guard let object = celebrity else { observer.sendFailed(.NotFound); return }
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    func updateUserActivitySignal(id id: String) -> SignalProducer<NSUserActivity, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter("id = %@", id).first!
            guard let celeb = celebrity else { observer.sendFailed(.NotFound); return }
            let profile = CelebrityStruct(id: celeb.id, imageURL:celeb.picture3x, nickname:celeb.nickName, height: celeb.height, netWorth: celeb.netWorth, prevScore: celeb.prevScore, isFollowed:celeb.isFollowed)
            let activity = profile.userActivity
            activity.addUserInfoEntriesFromDictionary(profile.userActivityUserInfo)
            activity.becomeCurrent()
            observer.sendNext(activity)
            observer.sendCompleted()
        }
    }
    
    func followCebritySignal(id id: String, isFollowing: Bool) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter("id = %@", id).first!
            guard let object = celebrity else { observer.sendFailed(.NotFound); return }
            object.isFollowed = isFollowing
            realm.beginWrite()
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


