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
    let celebrityId: String
    enum Sex: Int { case Woman = 0, Man }
    enum Rank { case A_List, B_List, Other }
    enum PersonalStatus { case Single, Married, Divorced, Engaged }
    enum FollowStatus: Int { case NotFollowing = 0, Following }
    enum CelebrityError: ErrorType { case NotFound }
    
    //MARK: Initializer
    init(celebrityId: String) {
        self.celebrityId = celebrityId
        super.init()
    }
    
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
    
    func followCebritySignal(id id: String, followStatus: FollowStatus) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", id)
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter(predicate).first!
            guard let object = celebrity else { sendError(sink, .NotFound); return }
            if followStatus == .Following { object.isFollowed = true }
            else { object.isFollowed = false }
            //TODO: update Notification Center
            object.isSynced = false
            realm.add(object, update: true)
            try! realm.commitWrite()
            sendNext(sink, object)
            sendCompleted(sink)
        }
    }
}


