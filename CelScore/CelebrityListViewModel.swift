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
    final let title = MutableProperty("")
    final lazy var celebrityList: ListsModel = ListsModel()
    enum ListError: ErrorType { case Empty, IndexOutOfBounds }
    
    
    //MARK: Initializers
    override init() { super.init() }
    
    
    //MARK: Methods
    final func initializeListSignal(listId listId: String) -> SignalProducer<ListsModel, ListError> {
        return SignalProducer {
            sink, _ in
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", listId)
            let list = realm.objects(ListsModel).filter(predicate).first
            guard let celebList = list else {
                sendError(sink, ListError.Empty)
                return
            }
            
            self.celebrityList = celebList
            sendNext(sink, celebList)
            sendCompleted(sink)
        }
    }
    
    //TODO : replace by computed properties count, idAtIndex & profileAtIndex
    final func getCount() -> Int { return self.celebrityList.count }
    
    final func getIdForCelebAtIndex(index: Int) -> String {
        //TODO add guard to check index is within bounds
        let celebId : CelebId = self.celebrityList.celebList[index]
        return celebId.id
    }
    
    final func getCelebrityProfile(celebId celebId: String) throws -> CelebrityProfile
    {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@", celebId)
        let celebrity = realm.objects(CelebrityModel).filter(predicate).first
        guard let celeb = celebrity else { throw ListError.Empty }
        
        return CelebrityProfile(id: celeb.id, imageURL:celeb.picture3x, nickname:celeb.nickName, prevScore: celeb.prevScore)
    }
}