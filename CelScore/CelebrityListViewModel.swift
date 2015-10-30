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

enum ListError : ErrorType {
    case SearchTokenTooShort
    case Empty
}

final class CelebrityListViewModel: NSObject {
    
    //MARK: Properties
    let searchText = MutableProperty("")
    let title = MutableProperty("")
    let isSearching = MutableProperty<Bool>(false)
    lazy var celebrityList = ListsModel()
    
    
    //MARK: Initializers
    init(searchToken: String) {
        super.init()
        
        self.searchText.producer
            .promoteErrors(ListError.self)
            .filter { $0.characters.count > 3 }
            .throttle(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
            .on(next: { _ in self.isSearching.value = true })
            .flatMap(.Latest) { (token: String) -> SignalProducer<AnyObject, ListError> in
                return self.searchForCelebritiesSignal(searchToken: token)
            }
            .observeOn(QueueScheduler.mainQueueScheduler).start(Event.sink(error: {
                print("Error \($0)")
                },
                next: {
                    response in
                    print("Search results: \(response)")
                    self.isSearching.value = false
            }))
    }
    
    
    init(listId: String = "0001") {
        super.init()
        
        initializeListSignal(listId: listId)
            .take(2)
            .observeOn(QueueScheduler.mainQueueScheduler)
            .start { event in
                switch(event) {
                case let .Next(value):
                    self.celebrityList = value
                    print("initializeListSignal value: \(value)")
                case let .Error(error):
                    print("initializeListSignal Error: \(error)")
                case .Completed:
                    print("initializeListSignal Completed")
                case .Interrupted:
                    print("initializeListSignal Interrupted")
                }
        }
    }
    
    
    //MARK: Methods
    func initializeListSignal(listId listId: String) -> SignalProducer<ListsModel, ListError> {
        return SignalProducer {
            sink, _ in
            
            let realm = try! Realm()
            
            let predicate = NSPredicate(format: "id = %@", listId)
            let list = realm.objects(ListsModel).filter(predicate).first
            
            guard let celebList = list else {
                sendError(sink, ListError.Empty)
                return
            }
            sendNext(sink, celebList)
            sendCompleted(sink)
        }
    }

    
    func searchForCelebritiesSignal(searchToken searchToken: String) -> SignalProducer<AnyObject, ListError> {
        return SignalProducer {
            sink, disposable in
            
            let realm = try! Realm()
            
            let predicate = NSPredicate(format: "nickName contains[c] %@", searchToken)
            let list = realm.objects(CelebrityModel).filter(predicate)
            
            guard list.count > 0 else {
                sendError(sink, ListError.Empty)
                return
            }
            sendNext(sink, list)
            sendCompleted(sink)
        }
    }
    
    
    func searchForListsSignal(searchToken searchToken: String) -> SignalProducer<AnyObject, ListError> {
        return SignalProducer {
            sink, _ in

            let realm = try! Realm()
            
            let predicate = NSPredicate(format: "name contains[c] %@", searchToken)
            let list = realm.objects(ListsModel).filter(predicate)
            
            guard list.count > 0 else {
                sendError(sink, ListError.Empty)
                return
            }
            sendNext(sink, list)
            sendCompleted(sink)
        }
    }
    
    func getCount() -> Int {
        return self.celebrityList.count
    }
    
    func getIdForCelebAtIndex(index: Int) -> String {
        let celebId : CelebId = self.celebrityList.celebList[index]
        return celebId.id
    }
    
    func getCelebrityProfile(celebId celebId: String) throws -> CelebrityProfile
    {
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "id = %@", celebId)
        let celebrity = realm.objects(CelebrityModel).filter(predicate).first
        
        guard let celeb = celebrity else {
            throw ListError.Empty
        }
        
        return CelebrityProfile(id: celeb.id, imageURL:celeb.picture3x , nickname:celeb.nickName, prevScore: celeb.prevScore)
    }
}