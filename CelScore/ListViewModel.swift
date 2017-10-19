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
    
    func getListSignal(listId: String) -> SignalProducer<ListsModel, ListError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(ListsModel.self).filter("id = %@", listId).first
            guard let celebList = list else { return observer.send(error: .emptyList) }
            observer.send(value: celebList)
            observer.sendCompleted()
        }
    }
    
    func searchSignal(searchToken: String) -> SignalProducer<ListsModel, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(CelebrityModel.self).filter("nickName contains[c] %@", searchToken)
            guard list.count > 0 else { return observer.sendCompleted() }
            
            realm.beginWrite()
            let listModel = ListsModel()
            listModel.id = Constants.kSearchListId
            listModel.name = "SearchList"
            for (_, celeb) in list.enumerated() {
                let celebId = CelebId()
                celebId.id = celeb.id
                listModel.celebList.append(celebId)
            }
            realm.add(listModel, update: true)
            try! realm.commitWrite()
            
            observer.send(value: listModel)
            observer.sendCompleted()
        }
    }
    
    func updateListSignal(listId: String) -> SignalProducer<Bool, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            
            if listId == ListInfo.news.getId() {
                let trending_celebs = realm.objects(CelebrityModel.self).filter("isTrending = true")
                let trending_list = ListsModel()
                
                for (_, celeb) in trending_celebs.enumerated() {
                    let newCelebId = CelebId()
                    newCelebId.id = celeb.id
                    trending_list.celebList.append(newCelebId)
                }
                realm.beginWrite()
                trending_list.id = ListInfo.news.getId()
                trending_list.name = ListInfo.news.name()
                realm.add(trending_list, update: true)
                try! realm.commitWrite()
            }
            
            let listModel = realm.objects(ListsModel.self).filter("id = %@", listId).first
            guard let list = listModel else { return }
            let celebrities = realm.objects(CelebrityModel.self).sorted(byKeyPath: "index", ascending: true)
            let followed = celebrities.filter("isFollowed = true")
            let others = celebrities.filter("isFollowed = false")
            let newList = ListsModel()
            
            for (_, celeb) in followed.enumerated() {
                let newCelebId = CelebId()
                newCelebId.id = celeb.id
                let isInTheList = list.celebList.contains(where: { (celebId: CelebId) -> Bool in return celeb.id == celebId.id })
                if isInTheList { newList.celebList.append(newCelebId) }
            }
            
            for (_, celeb) in others.enumerated() {
                let newCelebId = CelebId()
                newCelebId.id = celeb.id
                let isInTheList = list.celebList.contains(where: { (celebId: CelebId) -> Bool in return celeb.id == celebId.id })
                if isInTheList { newList.celebList.append(newCelebId) }
            }
            
            realm.beginWrite()
            newList.id = list.id
            newList.name = list.name
            realm.add(newList, update: true)
            try! realm.commitWrite()
            
            observer.send(value: true)
            observer.sendCompleted()
        }
    }
}





