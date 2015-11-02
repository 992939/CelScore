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

enum CelebrityError: ErrorType {
    case NotFound
}

final class CelebrityViewModel: NSObject {
    
    //MARK: Properties
    var celebrity: CelebrityModel?
    var ratingsVM: RatingsViewModel?
    
    enum PeriodSetting: NSTimeInterval { case Every_Minute = 60.0, Daily = 86400.0 }
    enum Sex: Int { case Woman = 0, Man }
    enum Horoscope : Int { case Aries = 1, Taurus, Gemini, Cancer, Leo, Virgo, Libra, Scorpio, Sagittarius, Capricorn , Aquarius, Pisces }
    enum Rank { case A_List, B_List, Other }
    enum Status { case Single, Married, Divorced, Engaged }
    
    
    //MARK: Initializers
    init(celebrityId: String) {
        super.init()
        
        getCelebrityFromLocalStoreSignal(celebId: celebrityId)
            .take(2)
            .startOn(QueueScheduler.mainQueueScheduler)
            .start { event in
                switch(event) {
                case let .Next(value):
                    self.celebrity = value
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
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", celebId)
            let celebrity = realm.objects(CelebrityModel).filter(predicate).first
            guard let celeb = celebrity else {
                sendError(sink, .NotFound)
                return
            }
            sendNext(sink, celeb)
            sendCompleted(sink)
        }
    }
}


