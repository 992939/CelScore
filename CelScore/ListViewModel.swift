//
//  ListViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import ReactiveCocoa
import ReactiveSwift
import RealmSwift
import Result


struct ListViewModel {
    
    func getListSignal(listId: Int) -> SignalProducer<[CelebrityModel], NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            var list = realm.objects(CelebrityModel.self)
            if listId > 0 {
                let filter = listId == 4 ? String("isTrending = true") : String("listType = \(listId)")
                list = list.filter(filter!)
            }
            guard list.count > 0 else { return }
            let followed = list.filter("isFollowed = true").sorted(byKeyPath: "index", ascending: true)
            let notFollowed = list.filter("isFollowed = false").sorted(byKeyPath: "index", ascending: true)
            let combined = Array(followed) + Array(notFollowed)
            observer.send(value: combined)
            observer.sendCompleted()
        }
    }
    
    func searchSignal(searchToken: String) -> SignalProducer<[CelebrityModel], NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(CelebrityModel.self).filter("nickName contains[c] %@", searchToken)
            guard list.count > 0 else { return observer.sendCompleted() }
            observer.send(value: Array(list))
            observer.sendCompleted()
        }
    }
}





