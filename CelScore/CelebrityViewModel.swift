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


final class CelebrityViewModel: NSObject {
    
    //MARK: Properties
    enum CelebrityError: ErrorType { case NotFound }
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
    func getCelebritySignal(id id: String) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", id)
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter(predicate).first!.copy() as? CelebrityModel
            guard let object = celebrity else { sendError(sink, .NotFound); return }
            sendNext(sink, object)
            sendCompleted(sink)
        }
    }
    
    func updateUserActivitySignal(id id: String) -> SignalProducer<NSUserActivity, CelebrityError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", id)
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter(predicate).first!
            guard let celeb = celebrity else { sendError(sink, .NotFound); return }
            let profile = CelebrityStruct(id: celeb.id, imageURL:celeb.picture3x, nickname:celeb.nickName, height: celeb.height, netWorth: celeb.netWorth, prevScore: celeb.prevScore, isFollowed:celeb.isFollowed)
            let activity = profile.userActivity
            activity.addUserInfoEntriesFromDictionary(profile.userActivityUserInfo)
            activity.becomeCurrent()
            sendNext(sink, activity)
            sendCompleted(sink)
        }
    }
    
    func followCebritySignal(id id: String, isFollowing: Bool) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            realm.beginWrite()
            let predicate = NSPredicate(format: "id = %@", id)
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter(predicate).first!
            guard let object = celebrity else { sendError(sink, .NotFound); return }
            object.isFollowed = isFollowing
            object.isSynced = false
            realm.add(object, update: true)
            try! realm.commitWrite()
            sendNext(sink, object)
            sendCompleted(sink)
        }
    }
}


