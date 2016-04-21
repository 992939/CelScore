//
//  ListViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import ReactiveCocoa
import RealmSwift
import Result


struct ListViewModel {
    
    func getListSignal(listId listId: String) -> SignalProducer<ListsModel, ListError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(ListsModel).filter("id = %@", listId).first
            guard let celebList = list else { observer.sendFailed(.EmptyList); return }
            observer.sendNext(celebList)
            observer.sendCompleted()
        }
    }
    
    func searchSignal(searchToken searchToken: String) -> SignalProducer<ListsModel, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(CelebrityModel).filter("nickName contains[c] %@", searchToken)
            guard list.count > 0 else { observer.sendCompleted(); return }
            
            realm.beginWrite()
            let listModel = ListsModel()
            listModel.id = Constants.kSearchListId
            listModel.name = "SearchList"
            for (_, celeb) in list.enumerate() {
                let celebId = CelebId()
                celebId.id = celeb.id
                listModel.celebList.append(celebId)
            }
            realm.add(listModel, update: true)
            try! realm.commitWrite()
            
            observer.sendNext(listModel)
            observer.sendCompleted()
        }
    }
    
    func updateListSignal(listId listId: String) -> SignalProducer<ListsModel, ListError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(ListsModel).filter("id = %@", listId).first
            guard let celebList: ListsModel = list else { observer.sendFailed(.EmptyList); return }
            let followed = realm.objects(CelebrityModel).filter("isFollowed = true")
            
            guard followed.count > 0 else { observer.sendCompleted(); return }
            var notFollowing: [(index: Int, celebId: CelebId)] = []
            let following = celebList.celebList.enumerate().filter({ (item: (index: Int, celebId: CelebId)) -> Bool in
                let isFollowing = followed.enumerate().contains({ (_, celebrity: CelebrityModel) -> Bool in return celebrity.id == item.celebId.id })
                if !isFollowing { notFollowing.append(item) }
                return isFollowing
            })
            
            let listModel = ListsModel()
            for (_, celeb) in following.enumerate() {
                let celebId = CelebId()
                celebId.id = celeb.element.id
                listModel.celebList.append(celebId)
            }
            for (_, celeb) in notFollowing.enumerate() {
                let celebId = CelebId()
                celebId.id = celeb.celebId.id
                listModel.celebList.append(celebId)
            }
            observer.sendNext(listModel)
            observer.sendCompleted()
        }
    }
    
    func updateAllListsSignal() -> SignalProducer<ListsModel, ListError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            
            ListInfo.getAllIDs().forEach({ (listId:String) in
                let list = realm.objects(ListsModel).filter("id = %@", listId).first
                guard let celebList: ListsModel = list else { observer.sendFailed(.EmptyList); return }
                let followed = realm.objects(CelebrityModel).filter("isFollowed = true")
                
                guard followed.count > 0 else { observer.sendCompleted(); return }
                var notFollowing: [(index: Int, celebId: CelebId)] = []
                let following = celebList.celebList.enumerate().filter({ (item: (index: Int, celebId: CelebId)) -> Bool in
                    let isFollowing = followed.enumerate().contains({ (_, celebrity: CelebrityModel) -> Bool in return celebrity.id == item.celebId.id })
                    if !isFollowing { notFollowing.append(item) }
                    return isFollowing
                })
                
                let listModel = ListsModel()
                for (_, celeb) in following.enumerate() {
                    let celebId = CelebId()
                    celebId.id = celeb.element.id
                    listModel.celebList.append(celebId)
                }
                for (_, celeb) in notFollowing.enumerate() {
                    let celebId = CelebId()
                    celebId.id = celeb.celebId.id
                    listModel.celebList.append(celebId)
                }
                observer.sendNext(listModel)
            })
            observer.sendCompleted()
        }
    }
    
    func getCelebrityStructSignal(listId listId: String, index: Int) -> SignalProducer<CelebrityStruct, ListError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let list = realm.objects(ListsModel).filter("id = %@", listId).first
            guard let celebList: ListsModel = list else { observer.sendFailed(.EmptyList); return }
            let celebId: CelebId = celebList.celebList[index]
            let celeb = realm.objects(CelebrityModel).filter("id = %@", celebId.id).first
            guard celeb?.id.isEmpty == false else { observer.sendFailed(.EmptyList); return }
            observer.sendNext(CelebrityStruct(id: celeb!.id, imageURL:celeb!.picture3x, nickname:celeb!.nickName, prevScore: celeb!.prevScore, sex: celeb!.sex, isFollowed:celeb!.isFollowed))
            observer.sendCompleted()
        }
    }
}