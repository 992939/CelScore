//
//  ListViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import ReactiveCocoa
import RealmSwift


final class ListViewModel: NSObject {
    
    //MARK: Properties
    private(set) var celebrityList = ListsModel()
    enum ListError: ErrorType { case EmptyList, IndexOutOfBounds, NoLists }
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
    func getCount() -> Int { return celebrityList.count }
    
    func getListSignal(listId listId: String) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", listId)
            let list = realm.objects(ListsModel).filter(predicate).first
            guard let celebList = list else { sendError(sink, NSError(domain: "NoList", code: 1, userInfo: nil)); return } //TODO: sendError(sink, .EmptyList);
            self.celebrityList = celebList.copy() as! ListsModel
            sendNext(sink, celebList)
            sendCompleted(sink)
        }
    }
    
    func updateListSignal(listId listId: String) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            var predicate = NSPredicate(format: "id = %@", listId)
            let list = realm.objects(ListsModel).filter(predicate).first
            guard let celebList: ListsModel = list else { sendError(sink, NSError(domain: "NoList", code: 1, userInfo: nil)); return } //TODO
            predicate = NSPredicate(format: "isFollowed = true")
            let followed = realm.objects(CelebrityModel).filter(predicate)

            guard followed.count > 0 else { return }
            var following = celebList.celebList.enumerate().filter({ (item: (index: Int, celebId: CelebId)) -> Bool in
                return followed.enumerate().contains({ (_, celebrity: CelebrityModel) -> Bool in return celebrity.id == item.celebId.id })
            })
            guard following.count > 0 else { return }
            let notFollowing = celebList.celebList.enumerate().filter({ (item: (index: Int, element: CelebId)) -> Bool in
                let isFollowing = followed.enumerate().contains({ (index: Int, celebrity: CelebrityModel) -> Bool in return celebrity.id == item.element.id })
                //if !isFollowing { following.append(item) }
                return !isFollowing
            })
            
            print("following: \(following.count) and not \(notFollowing.count)")
            
            let listModel = ListsModel()
            for (_, celeb) in following.enumerate() {
                let celebId = CelebId()
                celebId.id = celeb.element.id
                listModel.celebList.append(celebId)
            }
            for (_, celeb) in notFollowing.enumerate() {
                let celebId = CelebId()
                celebId.id = celeb.element.id
                listModel.celebList.append(celebId)
            }
            self.celebrityList.celebList = listModel.celebList
            sendNext(sink, self.celebrityList)
            sendCompleted(sink)
        }
    }
    
    func searchSignal(searchToken searchToken: String) -> SignalProducer<AnyObject, NoError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "nickName contains[c] %@", searchToken)
            let list = realm.objects(CelebrityModel).filter(predicate)
            guard list.count > 0 else { return }
            
            let listModel =  ListsModel()
            listModel.id = "0099"
            listModel.name = "SearchList"
            for (_, celeb) in list.enumerate() {
                let celebId = CelebId()
                celebId.id = celeb.id
                listModel.celebList.append(celebId)
            }
            listModel.count = list.count
            self.celebrityList = listModel.copy() as! ListsModel
            sendNext(sink, listModel)
            sendCompleted(sink)
        }
    }
    
    func getCelebrityStructSignal(index index: Int) -> SignalProducer<CelebrityStruct, ListError> {
        return SignalProducer { sink, _ in
            guard index < self.getCount() else { sendError(sink, .IndexOutOfBounds); return }
            let celebId: CelebId = self.celebrityList.celebList[index]
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", celebId.id)
            let celebrity = realm.objects(CelebrityModel).filter(predicate).first
            guard let celeb = celebrity else { sendError(sink, .EmptyList); return }
            sendNext(sink, CelebrityStruct(id: celeb.id, imageURL:celeb.picture3x, nickname:celeb.nickName, height: celeb.height, netWorth: celeb.netWorth, prevScore: celeb.prevScore, isFollowed:celeb.isFollowed))
            sendCompleted(sink)
        }
    }
}