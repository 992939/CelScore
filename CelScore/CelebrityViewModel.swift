//
//  CelebrityViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
//import ReactiveCocoa
//import Parse

class CelebrityViewModel : NSObject {
    
    //MARK: Properties
    var celebrityId, firstName, middleName, lastName, nickName, born, from, netWorth, height : String?
    var currentScore, previousScore: Double?
    var ratings: PFObject?
    var initCelebrityViewModelSignal : RACSignal?
    
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
    
    init(celebrity: PFObject)
    {
        
        super.init()
        
        initCelebrityViewModelSignal = updateCelebrityViewModelSignal(celebrity: celebrity, frequency: periodSetting.Every_Minute.rawValue)
    }
    
    //MARK: Methods
    func fetchValuesSignal(celebrity: PFObject) -> RACSignal
    {
        let signal = RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            celebrity.fetchFromLocalDatastoreInBackgroundWithBlock({ (object: PFObject?, error :NSError?) -> Void in
                if error == nil
                {
                    self.celebrityId = object?.valueForKey("objectId") as? String
                    self.firstName = object?.valueForKey("firstName") as? String
                    self.middleName = object?.valueForKey("middleName") as? String
                    self.lastName = object?.valueForKey("lastName") as? String
                    self.nickName = object?.valueForKey("nickName") as? String
                    self.born = object?.valueForKey("born") as? String
                    self.from = object?.valueForKey("from") as? String
                    self.netWorth = object?.valueForKey("netWorth") as? String
                    self.height = object?.valueForKey("height") as? String
                    self.currentScore = object?.valueForKey("currentScore") as? Double
                    self.previousScore = object?.valueForKey("previousScore") as? Double
                    self.ratings = object?.valueForKey("celebrity_ratings") as? PFObject

                    subscriber.sendNext(object)
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
    
    func updateCelebrityViewModelSignal(celebrity celebrity: PFObject, frequency: NSTimeInterval) -> RACSignal {
        let scheduler : RACScheduler = RACScheduler(priority: RACSchedulerPriorityDefault)
        let recurringSignal = RACSignal.interval(frequency, onScheduler: scheduler).startWith(NSDate())
        
        return recurringSignal.flattenMap({ (text: AnyObject!) -> RACStream! in
            return self.fetchValuesSignal(celebrity)
        })
    }
    
    
}


