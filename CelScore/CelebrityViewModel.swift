//
//  CelebrityViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveCocoa

enum CelebrityError : ErrorType {
    case NoFound
}

class CelebrityViewModel : NSObject {
    
    //MARK: Properties
    var celebrityId, firstName, middleName, lastName, nickName, born, from, netWorth, height : String?
    var currentScore, previousScore: Double?
    var ratings: NSObject?
    var initCelebrityViewModelSignal : SignalProducer<NSObject, NSError>?
    
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
    
    init(celebrityId: String)
    {
        super.init()
        
        getCelebrityWithIdFromLocalStoreSignal(celebId: celebrityId)
    }
    
    //MARK: Methods
    func getCelebrityWithIdFromLocalStoreSignal(celebId celebId: String) -> SignalProducer<AnyObject!, CelebrityError>
    {
        return SignalProducer {
            sink, _ in
            
            let realm = try! Realm()
            
            let predicate = NSPredicate(format: "id = %@", celebId)
            let list = realm.objects(CelebrityModel).filter(predicate).first
            
            guard let celebList = list else {
                sendError(sink, CelebrityError.NoFound)
                return
            }
            
//            self.celebrityId = object?.valueForKey("objectId") as? String
//            self.firstName = object?.valueForKey("firstName") as? String
//            self.middleName = object?.valueForKey("middleName") as? String
//            self.lastName = object?.valueForKey("lastName") as? String
//            self.nickName = object?.valueForKey("nickName") as? String
//            self.born = object?.valueForKey("born") as? String
//            self.from = object?.valueForKey("from") as? String
//            self.netWorth = object?.valueForKey("netWorth") as? String
//            self.height = object?.valueForKey("height") as? String
//            self.currentScore = object?.valueForKey("currentScore") as? Double
//            self.previousScore = object?.valueForKey("previousScore") as? Double
//            self.ratings = object?.valueForKey("celebrity_ratings") as? PFObject
            
            sendNext(sink, celebList)
            sendCompleted(sink)
        }
    }
    
//        func updateCelebrityViewModelSignal(frequency: NSTimeInterval) -> SignalProducer<NSObject, NSError> {
//            scheduler.scheduleAfter(NSDate(), repeatingEvery: 5, withLeeway: 0) { () -> () in
//                print("cheebah cheebah")
//            }
//            return self.getCelebrityFromLocalStoreSignal().observeOn(scheduler)
//        }
}


