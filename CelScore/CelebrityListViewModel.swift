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
    case NotFound
    case Empty
}

class CelebrityListViewModel: NSObject {
    
    //MARK: Properties
    dynamic var searchText = ""
    var title : String = ""
    var celebrityList = ListsModel()
    
    //MARK: Initializers
    init(searchToken: String) {
        super.init()
    }
    
    init(listId: String = "0001") {
        
        super.init()
        
        initializeListSignal(listId: listId)
            .take(2)
            .observeOn(QueueScheduler.mainQueueScheduler)
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("Next: \(value)")
                case let .Error(error):
                    print("Error: \(error)")
                case .Completed:
                    print("Completed")
                case .Interrupted:
                    print("Interrupted")
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

    
    func searchForCelebritiesSignal(searchToken searchToken: String) -> SignalProducer<Int, NSError> {
        return SignalProducer {
            sink, _ in
            //let query = PFQuery(className: "Celebrity")
            //query.fromLocalDatastore()
            //query.whereKey("nickName", matchesRegex: searchToken, modifiers: "i")
                if 2 == 4
                {
                    //self.celebrityList = object as Array
                    //self.celebrityList = self.celebrityList.map({ CelebrityViewModel(celebrity: $0 as! PFObject)})
                    
                    sendNext(sink, 2)
                    sendCompleted(sink)
                } else
                {
                    sendError(sink, NSError.init(domain: "com.celscore", code: 1, userInfo: nil))
                }
            }.observeOn(QueueScheduler())
        }
    
    func searchForListsSignal(searchToken searchToken: String) -> SignalProducer<Int, NSError> {
        return SignalProducer {
            sink, _ in
            //let query = PFQuery(className: "List")
            //query.fromLocalDatastore()
            //query.whereKey("name", matchesRegex: searchToken, modifiers: "i")
                if 2 == 4
                {
                    //self.celebrityList = object as Array
                    //self.celebrityList = self.celebrityList.map({ CelebrityViewModel(celebrity: $0 as! PFObject)})
                    
                    sendNext(sink, 2)
                    sendCompleted(sink)
                } else
                {
                    sendError(sink, NSError.init(domain: "com.celscore", code: 1, userInfo: nil))
            }
        }.observeOn(QueueScheduler())
    }
}