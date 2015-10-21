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
    lazy var celebrityList = ListsModel()
    
    //MARK: Initializers
    init(searchToken: String) {
        super.init()
        
        searchText.producer
            .observeOn(QueueScheduler.mainQueueScheduler)
            .filter { $0.characters.count > 3 }
            .throttle(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
            .startWithNext { token in
                if token.hasPrefix("#") {
                    self.searchForListsSignal(searchToken: token)
                } else
                {
                    self.searchForCelebritiesSignal(searchToken: token)
                }
        }
    }
    
    init(listId: String = "0001") {
        super.init()
        
        initializeListSignal(listId: listId)
            .take(2)
            .observeOn(QueueScheduler.mainQueueScheduler)
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("initializeListSignal Next: \(value)")
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
    func initializeListSignal(listId listId: String) -> SignalProducer<AnyObject!, ListError> {
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

    
    func searchForCelebritiesSignal(searchToken searchToken: String) -> SignalProducer<AnyObject!, ListError> {
        return SignalProducer {
            sink, _ in
            
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
    
    
    func searchForListsSignal(searchToken searchToken: String) -> SignalProducer<AnyObject!, ListError> {
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
}