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
    var count: Int { return self.celebrityList.count }
    enum ListError: ErrorType { case EmptyList, IndexOutOfBounds, NoLists }
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
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
    
    func getCelebrityStructSignal(index index: Int) -> SignalProducer<CelebrityStruct, ListError> {
        return SignalProducer { sink, _ in
            guard index < self.count else { sendError(sink, .IndexOutOfBounds); return }
            let celebId: CelebId = self.celebrityList.celebList[index]
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", celebId.id)
            let celebrity = realm.objects(CelebrityModel).filter(predicate).first
            guard let celeb = celebrity else { sendError(sink, .EmptyList); return }
            sendNext(sink, CelebrityStruct(id: celeb.id, imageURL:celeb.picture3x, nickname:celeb.nickName, height: celeb.height, netWorth: celeb.netWorth, prevScore: celeb.prevScore, isFollowed:celeb.isFollowed))
            sendCompleted(sink)
        }
    }
    
    func getListsFromLocalStoreSignal() -> SignalProducer<AnyObject, ListError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let list = realm.objects(ListsModel)
            guard list.count > 0 else { sendError(sink, .NoLists); return }
            self.celebrityList = list.copy() as! ListsModel
            sendNext(sink, list)
            sendCompleted(sink)
        }
    }
    
    func searchSignal(searchToken searchToken: String) -> SignalProducer<AnyObject, NoError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "nickName contains[c] %@", searchToken)
            let list = realm.objects(CelebrityModel).filter(predicate)
            guard list.count > 0 else { self.celebrityList = ListsModel(); return }
            
            let listModel =  ListsModel()
            listModel.id = "0099"
            listModel.name = "SearchList"
            for (_, celeb) in list.enumerate() {
                print("indeed!")
                let celebId = CelebId()
                celebId.id = celeb.id
                listModel.celebList.append(celebId)
            }
            listModel.count = list.count
            
            self.celebrityList = listModel.copy() as! ListsModel
            print("in time: \(self.celebrityList.description)")
            sendNext(sink, listModel)
            sendCompleted(sink)
        }
    }
}