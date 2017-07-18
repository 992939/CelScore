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
    
    func sanitizeListsSignal() -> SignalProducer<Bool, ListError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            ListInfo.getAllIDs().forEach({ (listId:String) in
                let list = realm.objects(ListsModel.self).filter("id = %@", listId).first
                guard let celebList = list else { return }
                
                let current = realm.objects(CelebrityModel.self)
                let notExisting = celebList.celebList.enumerated().filter({ (item: (index: Int, celebId: CelebId)) -> Bool in
                    return !current.enumerated().contains(where: { (_, celebrity: CelebrityModel) -> Bool in return celebrity.id == item.celebId.id }) })
                guard notExisting.count > 0 else { return }
                
                realm.beginWrite()
                for (index, _) in notExisting.enumerated() { celebList.celebList.remove(at: index) }
                realm.add(celebList, update: true)
                try! realm.commitWrite()
            })
            observer.send(value: true)
            observer.sendCompleted()
        }
    }
    
    func updateListSignal(listId: String) -> SignalProducer<Bool, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            
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
    
    func getCelebrityStructSignal(listId: String, index: Int) -> SignalProducer<CelebrityStruct, ListError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(ListsModel.self).filter("id = %@", listId).first
            guard let celebList: ListsModel = list else { return observer.send(error: .emptyList) }
            let celebId: CelebId = celebList.celebList[index]
            let celeb = realm.objects(CelebrityModel.self).filter("id = %@", celebId.id).first
            guard celeb?.id.isEmpty == false else { return observer.send(error: .emptyList) }
            observer.send(value: CelebrityStruct(id: celeb!.id, imageURL: celeb!.isKing ? celeb!.gold3x : celeb!.picture3x, nickName:celeb!.nickName, kingName: celeb!.kingName, prevScore: celeb!.prevScore, prevWeek: celeb!.prevWeek, prevMonth: celeb!.prevMonth, index: celeb!.index, sex: celeb!.sex, isFollowed: celeb!.isFollowed, isKing: celeb!.isKing))
            observer.sendCompleted()
        }
    }
}





