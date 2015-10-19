//
//  RatingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

class RatingsViewModel: NSObject {
    
    //MARK: Properties
    var ratings : RatingsModel?
    var userRatings : UserRatingsModel?
    
    //MARK: Initializers
    init(rating: NSObject, celebrityId: String)
    {
        super.init()
        
        self.ratings = RatingsModel()
        self.ratings!.id = celebrityId
        self.userRatings = UserRatingsModel()
        self.userRatings!.id = celebrityId
    }
    
    func updateUserRatingsInRealmSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let realm = try! Realm()
            realm.beginWrite()
            self.userRatings?.isSynced = false
            realm.add(self.userRatings!, update: true)
            try! realm.commitWrite()
        }
    }
    
    func retrieveRatingsFromRealmSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", self.userRatings!.id)
            self.userRatings = realm.objects(UserRatingsModel).filter(predicate).first
        }
    }
    
    func updateRatingsInRealmSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let realm = try! Realm()
            realm.beginWrite()
            self.ratings?.isSynced = false
            realm.add(self.ratings!, update: true)
            try! realm.commitWrite()
        }
    }
    
    func retrieveUserRatingsFromRealmSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %@", self.ratings!.id)
            self.ratings = realm.objects(RatingsModel).filter(predicate).first
        }
    }
}
