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

class CelebrityListViewModel: NSObject {
    
    //MARK: Properties
    var searchText = ""
    var title : String = ""
    var celebrityList = ListsModel()
    
    //MARK: Initializers
    init(searchToken: String) {
        super.init()
        
        searchForCelebritiesSignal(searchToken: searchToken)
        //searchForListsSignal(searchToken: "hip")
            .take(2)
            .observeOn(QueueScheduler.mainQueueScheduler)
            .start { event in
                switch(event) {
                case let .Next(value):
                    loggingPrint("searchForCelebritiesSignal Next: \(value)")
                case let .Error(error):
                    loggingPrint("searchForCelebritiesSignal Error: \(error)")
                case .Completed:
                    loggingPrint("searchForCelebritiesSignal Completed")
                case .Interrupted:
                    loggingPrint("searchForCelebritiesSignal Interrupted")
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
                    loggingPrint("initializeListSignal Next: \(value)")
                case let .Error(error):
                    loggingPrint("initializeListSignal Error: \(error)")
                case .Completed:
                    loggingPrint("initializeListSignal Completed")
                case .Interrupted:
                    loggingPrint("initializeListSignal Interrupted")
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