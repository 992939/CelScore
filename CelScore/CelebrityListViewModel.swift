//
//  CelebrityListViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
//import ReactiveCocoa
//import Parse

class CelebrityListViewModel: NSObject {
    
    //MARK: Properties
    dynamic var searchText = ""
    var executeSearch: RACCommand!
    var connectionErrors: RACSignal!
    var title : String = "Default"
    var count : Int = 0
    var celebrityList : [AnyObject] = []
    
    //MARK: Initializers
    init(searchToken: String) {
        
        super.init()
        
        let validSearchSignal = RACObserve(self, "searchText").mapAs {
            (text: NSString) -> NSNumber in
            return text.length > 3
            }.distinctUntilChanged()
        
        let executeSearch = RACCommand(enabled: validSearchSignal) {
            (any:AnyObject!) -> RACSignal in
            return self.searchForCelebritiesSignal(searchToken: self.searchText)
        }
    }
    
    init(listName: String) {
        
        super.init()
        
        initializeListSignal(listName: listName)
            .deliverOn(RACScheduler.mainThreadScheduler())
            .subscribeNext({ (d:AnyObject!) -> Void in
            println("dataSourceSignal success")
            }, error :{ (_) -> Void in
                println("dataSourceSignal error")
        })

//        if let currentList = list
//        {
//            updateListSignal(listName: listName)
//        } else
//        {
//            initializeListSignal(listName: listName)
//        }
    }
    
    //MARK: Methods
    func initializeListSignal(#listName: String) -> RACSignal {
        let scheduler = RACScheduler(priority: RACSchedulerPriorityBackground)
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            var query = PFQuery(className: "List")
            query.fromLocalDatastore()
            query.whereKey("name", equalTo: listName)
            let objects: PFObject? = query.getFirstObject()
            if let object = objects
            {
                self.celebrityList = object.objectForKey("celebrities") as! Array
                self.celebrityList = self.celebrityList.map({ CelebrityViewModel(celebrity: $0 as! PFObject)})
                
                subscriber.sendNext(object)
                subscriber.sendCompleted()
            } else
            {
                subscriber.sendError(NSError())
            }
            return nil
        }).subscribeOn(scheduler).deliverOn(RACScheduler.mainThreadScheduler())
    }
    
    
    func updateListSignal(#listName: String) -> RACSignal {
        let signal = RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            //
            return nil
        })
        return signal
    }
    
    func searchForCelebritiesSignal(#searchToken: String) -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            var query = PFQuery(className: "Celebrity")
            query.fromLocalDatastore()
            query.whereKey("nickName", matchesRegex: searchToken, modifiers: "i")
            query.findObjectsInBackgroundWithBlock({ ( objects: [AnyObject]?, error :NSError?) -> Void in
                print("OBJECTS ARE \(objects)")
                if let object = objects
                {
                    self.celebrityList = object as Array
                    self.celebrityList = self.celebrityList.map({ CelebrityViewModel(celebrity: $0 as! PFObject)})
                    
                    subscriber.sendNext(object)
                    subscriber.sendCompleted()
                } else
                {
                    subscriber.sendError(NSError())
                }
            })
            return nil
        })
    }
}