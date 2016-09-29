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
    
    func getCelebritySignal(id: String) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity = realm.objects(CelebrityModel).filter("id = %@", id).first
            guard let object = celebrity else { return observer.sendFailed(.NotFound) }
            observer.sendNext(object)
            observer.sendCompleted()
        }
    }
    
    func updateUserActivitySignal(id: String) -> SignalProducer<NSUserActivity, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity = realm.objects(CelebrityModel).filter("id = %@", id).first
            guard let celeb = celebrity else { return observer.sendFailed(.NotFound) }

            let profile = CelebrityStruct(id: celeb.id, imageURL:celeb.picture3x, nickname:celeb.nickName, prevScore: celeb.prevScore, sex: celeb.sex, isFollowed:celeb.isFollowed)
            profile.userActivity.addUserInfoEntriesFromDictionary(profile.userActivityUserInfo)
            profile.userActivity.becomeCurrent()
            observer.sendNext(profile.userActivity)
            observer.sendCompleted()
        }
    }
    
    func followCebritySignal(id: String, isFollowing: Bool) -> SignalProducer<CelebrityModel, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebrity = realm.objects(CelebrityModel).filter("id = %@", id).first
            guard let object = celebrity else { return observer.sendFailed(.NotFound) }
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
    
    func removeCelebsNotInPublicOpinionSignal() -> SignalProducer<Int, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(ListsModel).filter("id = %@", ListInfo.PublicOpinion.getId()).first
            guard let listModel = list else { return observer.sendCompleted() }
            guard listModel.celebList.count > 0 else { return observer.sendCompleted() }
            let celebIDsOnPublicOpinionList: [String] = listModel.celebList.map({ celeb in return celeb.id })
            
            let celebList = realm.objects(CelebrityModel)
            let celebIDsList: [String] = celebList.map({ celeb in return celeb.id })
            guard celebIDsList.count > 0 else { return observer.sendCompleted() }
            
            let set1 = Set(celebIDsList)
            let set2 = Set(celebIDsOnPublicOpinionList)
            let removables = set1.subtract(set2)
            realm.beginWrite()
            removables.forEach({ id in
                let removable = realm.objects(CelebrityModel).filter("id = %@", id).first
                realm.delete(removable!)
            })
            try! realm.commitWrite()
            observer.sendNext(removables.count)
            observer.sendCompleted()
        }
    }
}


