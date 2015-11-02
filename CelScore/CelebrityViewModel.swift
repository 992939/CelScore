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

final class CelebrityViewModel : NSObject {
    
    //MARK: Properties
    var celebrityInfo: CelebrityModel?
    var calculatedCelScore, previousScore: Double?
    var ratings: RatingsViewModel?
    
    enum PeriodSetting: NSTimeInterval { case Every_Minute = 60.0, case Daily = 86400.0 }
    
    enum Rank { case A_List, case B_List, case Other }
    
    enum Status { case Single, case Married, case Divorced, case Engaged }
    
    enum Sex : Bool { case Man = true, case Woman = false }
    
    enum Horoscope : Int { case Aries = 1, case Taurus, case Gemini, case Cancer, case Leo, case Virgo, case Libra, case Scorpio ,case Sagittarius, case Capricorn ,case Aquarius, case Pisces }
    
    
    init(celebrityId: String) {
        super.init()
        
        getCelebrityFromLocalStoreSignal(celebId: celebrityId)
            .take(2)
            .startOn(QueueScheduler.mainQueueScheduler)
            .start { event in
                switch(event) {
                case let .Next(value):
                    self.celebrityInfo = value!
                case let .Error(error):
                    print("getCelebrityWithIdFromLocalStoreSignal Error: \(error)")
                case .Completed:
                    print("getCelebrityWithIdFromLocalStoreSignal Completed")
                case .Interrupted:
                    print("getCelebrityWithIdFromLocalStoreSignal Interrupted")
                }
        }
    }
    
    //MARK: Methods
    func getCelebrityFromLocalStoreSignal(celebId celebId: String) -> SignalProducer<CelebrityModel!, CelebrityError>
    {
        return SignalProducer {
            sink, _ in
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", celebId)
            let celebrity = realm.objects(CelebrityModel).filter(predicate).first
            guard let celeb = celebrity else {
                sendError(sink, CelebrityError.NoFound)
                return
            }
            
            sendNext(sink, celeb)
            sendCompleted(sink)
        }
    }
}


