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
import Timepiece
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
            let profile = CelebrityStruct(id: celeb.id, imageURL:celeb.picture3x, nickname:celeb.nickName, prevScore: celeb.prevScore, sex: celeb.sex, isFollowed:celeb.isFollowed)
            profile.userActivity.addUserInfoEntries(from: profile.userActivityUserInfo)
            profile.userActivity.becomeCurrent()
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
    
    func countFollowedCelebritiesSignal() -> SignalProducer<Int, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebList = realm.objects(CelebrityModel.self).filter("isFollowed = true")
            observer.send(value: celebList.count)
            observer.sendCompleted()
        }
    }
    
    func removeCelebsNotInPublicOpinionSignal() -> SignalProducer<Int, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(ListsModel.self).filter("id = %@", ListInfo.publicOpinion.getId()).first
            guard let listModel = list else { return observer.sendCompleted() }
            guard listModel.celebList.count > 0 else { return observer.sendCompleted() }
            let celebIDsOnPublicOpinionList: [String] = listModel.celebList.map({ celeb in return celeb.id })
            
            let celebList = realm.objects(CelebrityModel.self)
            let celebIDsList: [String] = celebList.map({ celeb in return celeb.id })
            guard celebIDsList.count > 0 else { return observer.sendCompleted() }
            
            let set1 = Set(celebIDsList)
            let set2 = Set(celebIDsOnPublicOpinionList)
            let removables: Set = set1.subtracting(set2)
            realm.beginWrite()
            removables.forEach({ id in
                let removable = realm.objects(CelebrityModel.self).filter("id = %@", id).first
                realm.delete(removable!)
            })
            try! realm.commitWrite()
            observer.send(value: removables.count)
            observer.sendCompleted()
        }
    }
}


