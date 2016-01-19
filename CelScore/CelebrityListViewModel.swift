//
//  CelebrityListViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import ReactiveCocoa
import RealmSwift


class CelebrityListViewModel: NSObject {
    
    //MARK: Properties
    final private(set) var celebrityList = ListsModel()
    final var name: String { return self.celebrityList.name }
    final var count: Int { return self.celebrityList.count }
    enum ListError: ErrorType { case EmptyList, IndexOutOfBounds, NoLists }
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
    final func getListSignal(listId listId: String) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", listId)
            let list = realm.objects(ListsModel).filter(predicate).first
            guard let celebList = list else { sendError(sink, NSError(domain: "NoUserRatings", code: 1, userInfo: nil)); return } //TODO: sendError(sink, .EmptyList);
            self.celebrityList = celebList.copy() as! ListsModel
            sendNext(sink, celebList)
            sendCompleted(sink)
        }
    }
    
    final func getCelebrityStructSignal(index index: Int) -> SignalProducer<CelebrityStruct, ListError> {
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
    
    final func getListsFromLocalStoreSignal() -> SignalProducer<AnyObject, ListError> {
        return SignalProducer { sink, _ in
            let realm = try! Realm()
            let list = realm.objects(ListsModel)
            guard list.count > 0 else { sendError(sink, .NoLists); return }
            sendNext(sink, list)
            sendCompleted(sink)
        }
    }
}