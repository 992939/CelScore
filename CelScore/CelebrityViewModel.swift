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


final class CelebrityViewModel: NSObject {
    
    //MARK: Properties
    var celebrity: CelebrityModel?
    enum PeriodSetting: NSTimeInterval { case Every_Minute = 60.0, Daily = 86400.0 }
    enum Sex: Int { case Woman = 0, Man }
    enum Horoscope : Int { case Aries = 1, Taurus, Gemini, Cancer, Leo, Virgo, Libra, Scorpio, Sagittarius, Capricorn , Aquarius, Pisces }
    enum Rank { case A_List, B_List, Other }
    enum Status { case Single, Married, Divorced, Engaged }
    enum CelebrityError: ErrorType { case NotFound }
    
    
    //MARK: Initializers
    init(celebrityId: String) {
        super.init()
        
        getFromLocalStoreSignal(id: celebrityId)
            .take(2)
            .startOn(QueueScheduler.mainQueueScheduler)
            .start { event in
                switch(event) {
                case let .Next(value):
                    self.celebrity = value as? CelebrityModel
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
    func getFromLocalStoreSignal(id id: String) -> SignalProducer<Object!, CelebrityError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", id)
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter(predicate).first!
            guard let object = celebrity else {
                sendError(sink, .NotFound)
                return
            }
            sendNext(sink, object)
            sendCompleted(sink)
        }
    }
    
    func followCebritySignal(id id: String) -> SignalProducer<Object!, CelebrityError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", id)
            let celebrity: CelebrityModel? = realm.objects(CelebrityModel).filter(predicate).first!
            guard let object = celebrity else {
                sendError(sink, .NotFound)
                return
            }
            object.isFollowed = true
            object.isSynced = false
            realm.add(object, update: true)
            try! realm.commitWrite()
            
            sendNext(sink, object)
            sendCompleted(sink)
        }
    }

}


