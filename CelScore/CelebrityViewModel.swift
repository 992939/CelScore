//
//  CelebrityViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation

class CelebrityViewModel : NSObject {
    
    //MARK: Properties
    var celebrityId, firstName, middleName, lastName, nickName, born, from, netWorth, height : String?
    var currentScore, previousScore: Double?
    var ratings: NSObject?
    var initCelebrityViewModelSignal : SignalProducer<NSObject, NSError>?
    
    lazy var scheduler: QueueScheduler = {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
        return QueueScheduler(queue: queue)
        }()
    
    enum rank {
        case A_List
        case B_List
        case C_List
        case D_List
        case Z_List
    }
    
    enum status {
        case Single
        case Married
        case Shagged_Up
        case Divorced
        case Engaged
        case Pimping
    }
    
    enum sex {
        case Man
        case Woman
    }
    
    enum horoscope {
        case Aries
        case Taurus
        case Gemini
        case Cancer
        case Leo
        case Virgo
        case Libra
        case Scorpio
        case Sagittarius
        case Capricorn
        case Aquarius
        case Pisces
    }
    
    enum periodSetting: NSTimeInterval {
        case Every_Minute = 60.0
        case Daily = 86400.0
    }
    
    init(celebrity: NSObject)
    {
        super.init()
        
        celebrityId = "00001" // celebrity
        
        getCelebrityFromLocalStoreSignal()
    }
    
    //MARK: Methods
    func getCelebrityFromLocalStoreSignal() -> SignalProducer<NSObject, NSError>
    {
        var count = 0
        return SignalProducer {
            sink, _ in

            //celebrity.fetchFromLocalDatastoreInBackgroundWithBlock({ (object: NSObject?, error :NSError?) -> Void in
                if 4 == 4
                {
//                    self.celebrityId = object?.valueForKey("objectId") as? String
//                    self.firstName = object?.valueForKey("firstName") as? String
//                    self.middleName = object?.valueForKey("middleName") as? String
//                    self.lastName = object?.valueForKey("lastName") as? String
//                    self.nickName = object?.valueForKey("nickName") as? String
//                    self.born = object?.valueForKey("born") as? String
//                    self.from = object?.valueForKey("from") as? String
//                    self.netWorth = object?.valueForKey("netWorth") as? String
//                    self.height = object?.valueForKey("height") as? String
//                    self.currentScore = object?.valueForKey("currentScore") as? Double
//                    self.previousScore = object?.valueForKey("previousScore") as? Double
//                    self.ratings = object?.valueForKey("celebrity_ratings") as? PFObject

                    //sendNext(sink, "success")
                    //sendCompleted(sink)
                } else
                {
                    sendError(sink, NSError.init(domain: "com.celscore", code: 1, userInfo: nil))
                }
            }
    }
    
        func updateCelebrityViewModelSignal(celebrity celebrity: NSObject, frequency: NSTimeInterval) -> SignalProducer<NSObject, NSError> {
            scheduler.scheduleAfter(NSDate(), repeatingEvery: 1,withLeeway: 0) { () -> () in
                print("cheebah cheebah")
            }
            
            return self.getCelebrityFromLocalStoreSignal().observeOn(scheduler)
            
//            let recurringSignal = RACSignal.interval(frequency, onScheduler: scheduler).startWith(NSDate())
//    
//            return recurringSignal.flattenMap({ (text: AnyObject!) -> SignalProducer<NSObject, NSError>! in
//                return self.getCelebrityFromLocalStoreSignal()
//            })
        }
}


