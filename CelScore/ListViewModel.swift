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
    
    func getListSignal(listId: String) -> SignalProducer<[CelebrityModel], NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(CelebrityModel.self).filter("listType = %@", 0)
            guard list.count > 0 else { return }
            //let orderedList = list.sorted(by: { (celebA, celebB) -> Bool in })
            observer.send(value: Array(list))
            observer.sendCompleted()
        }
    }
    
    func searchSignal(searchToken: String) -> SignalProducer<Results<CelebrityModel>, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(CelebrityModel.self).filter("nickName contains[c] %@", searchToken)
            guard list.count > 0 else { return observer.sendCompleted() }
            observer.send(value: list)
            observer.sendCompleted()
        }
    }
}





