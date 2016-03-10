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
            let predicate = NSPredicate(format: "id = %@", id)
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter(predicate).first!.copy() as? CelebrityModel
            guard let object = celebrity else { observer.sendFailed(.NotFound); return }
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    func updateUserActivitySignal(id id: String) -> SignalProducer<NSUserActivity, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", id)
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter(predicate).first!
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
            realm.beginWrite()
            let predicate = NSPredicate(format: "id = %@", id)
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter(predicate).first!
            guard let object = celebrity else { observer.sendFailed(.NotFound); return }
            object.isFollowed = isFollowing
            realm.add(object, update: true)
            try! realm.commitWrite()
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    func drawStarsBackgroundSignal() -> SignalProducer<UIView, NoError> {
        return SignalProducer { observer, disposable in
            var sky: Array<Array<Int>> = []
            let numberOfStars = [1, 2, 3, 4].map { _ in Int(arc4random_uniform(UInt32(4))) + 3 }
            numberOfStars.forEach({ stars in
                var quadrant: Array<Int> = []
                for _ in 1...stars { quadrant.append(Int(arc4random_uniform(UInt32(3))) + 1) }
                
                sky.append(quadrant)
            })
            print("sky \(sky)")
            observer.sendCompleted()
        }
    }
    
    func countFollowedCelebritiesSignal() -> SignalProducer<Int, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "isFollowed = true")
            let celebList = realm.objects(CelebrityModel).filter(predicate)
            observer.sendNext(celebList.count)
            observer.sendCompleted()
        }
    }
}


