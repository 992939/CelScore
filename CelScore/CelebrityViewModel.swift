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
            realm.beginWrite()
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter("id = %@", id).first!
            guard let object = celebrity else { observer.sendFailed(.NotFound); return }
            object.isFollowed = isFollowing
            realm.add(object, update: true)
            try! realm.commitWrite()
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    func drawStarsBackgroundSignal(diameter diameter:CGFloat) -> SignalProducer<UIView, NoError> {
        return SignalProducer { observer, disposable in
            var sky: Array<CGSize> = []
            let numberOfStars: Int = Int(arc4random_uniform(UInt32(15))) + 15
            for _ in 1...numberOfStars {
                let size = Int(arc4random_uniform(UInt32(3))) + 1
                let rect: CGSize?
                switch size {
                case 1: rect = CGSize(width: 10, height: 10)
                case 2: rect = CGSize(width: 30, height: 30)
                default: rect = CGSize(width: 60, height: 60)
                }
                
                sky.append(rect!)
            }
            let numberOfFrontStars: Int = Int(arc4random_uniform(UInt32(7))) + 3
            let numberOfSecondStars: Int = (numberOfStars - numberOfFrontStars) / 2
            print("front: \(numberOfFrontStars) second: \(numberOfSecondStars) total: \(numberOfStars) sky: \(sky)")
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


