//
//  CelScoreViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
//import ReactiveCocoa
//import Parse

class CelScoreViewModel: NSObject {
    
    //MARK: Properties
    dynamic var displayedCelebrityListVM : CelebrityListViewModel
    dynamic var searchedCelebrityListVM : CelebrityListViewModel

    enum periodSetting: NSTimeInterval {
        case Every_Minute = 60.0
        case Daily = 86400.0
    }
    
    //MARK: Initializers
    override init() {
        
        displayedCelebrityListVM = CelebrityListViewModel(listName: "#CelScore")
        searchedCelebrityListVM = CelebrityListViewModel(searchToken: "")

        super.init()
    }
    
    //MARK: Methods
    func checkNetworkConnectivitySignal() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            if IJReachability.isConnectedToNetwork() {
                println("Connected!.")
                subscriber.sendNext(1)
                subscriber.sendCompleted()
            } else
            {
                println("Not connected!")
                subscriber.sendError(NSError())
            }
            return nil
            
        })
    }
    
    func updateLocalDataStoreSignal(#classTypeName: String) -> RACSignal {
        let signal = RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            var query = PFQuery(className: classTypeName)
            
            if classTypeName == "Celebrity" {
                query.orderByAscending("currentScore")
                query.includeKey("celebrity_ratings")
            }

            query.findObjectsInBackgroundWithBlock({ (text: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    subscriber.sendNext(text)
                    subscriber.sendCompleted()
                } else
                {
                    subscriber.sendError(error)
                }
            })
            return nil
        })
        return signal
    }
    
    func recurringUpdateDataStoreSignal(#classTypeName: String, frequency: NSTimeInterval) -> RACSignal {
        let scheduler : RACScheduler =  RACScheduler(priority: RACSchedulerPriorityDefault)
        let recurringSignal = RACSignal.interval(frequency, onScheduler: scheduler).startWith(NSDate())
        
        return recurringSignal.flattenMap({ (text: AnyObject!) -> RACStream! in
            return self.updateLocalDataStoreSignal(classTypeName: classTypeName)
            })
    }
    
    func getAllCelebritiesInfoSignal(#classTypeName: String) -> RACSignal {
        let signal = RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            var query = PFQuery(className: classTypeName)
            query.fromLocalDatastore()
            query.findObjectsInBackgroundWithBlock({ (text: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    subscriber.sendNext(text)
                    subscriber.sendCompleted()
                } else
                {
                    subscriber.sendError(NSError())
                }
            })
            return nil
        })
        return signal
    }
    
    func updateAllCelebritiesCelScore() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            var query = PFQuery(className: "Celebrity")
            query.includeKey("celebrity_ratings")
            query.findObjectsInBackgroundWithBlock({ (celebrityArray: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    for celebrity in celebrityArray! {
                        var ratings: PFObject = celebrity["celebrity_ratings"] as! PFObject
                        ratings.removeObjectForKey("voteNumber")
                        let ratingKeys = ratings.allKeys()
                        let ratingValues = ratingKeys.map({ratings[$0 as! String]! as! Double})
                        let sumOfRatings = ratingValues.reduce(0){ return $0 + $1}
                        let newCelScore : Double = sumOfRatings / 10
                        
                        celebrity.setObject(newCelScore, forKey: "currentScore")
                    }
                    subscriber.sendNext(celebrityArray)
                    subscriber.sendCompleted()
                } else
                {
                    subscriber.sendError(NSError())
                    println("error over here!")
                }
            })
            return nil
        })
    }
    
    func recurringUpdateCelebritiesCelScoreSignal(#frequency: NSTimeInterval) -> RACSignal {
        let scheduler : RACScheduler =  RACScheduler(priority: RACSchedulerPriorityDefault)
        let recurringSignal = RACSignal.interval(frequency, onScheduler: scheduler).startWith(NSDate())
        
        return recurringSignal.flattenMap({ (text: AnyObject!) -> RACStream! in
            return self.updateAllCelebritiesCelScore()
        })
    }
}
