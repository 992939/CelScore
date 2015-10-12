//
//  RatingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation

class RatingsViewModel: NSObject {
    
    //MARK: Properties
    var ratings : RatingsModel?
    let celebrityId: String?
    
    //MARK: Initializers
    init(rating: NSObject, celebrityId: String)
    {
        self.celebrityId = celebrityId
        
        super.init()
        
        ratings = RatingsModel(value: rating)
        ratings!.id = celebrityId
    }
    
    func updateUserRatingsInRealmSignal() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            self.ratings?.isSynced = false
            realm.addOrUpdateObject(self.ratings!)
            try! realm.commitWriteTransaction()
            return nil
        })
    }
    
    func retrieveUserRatingsFromRealmSignal() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            let predicate = NSPredicate(format: "id = %@", self.celebrityId!)
            _ = RatingsModel.objectsInRealm(realm, withPredicate: predicate).objectAtIndex(0) as! RatingsModel
            try! realm.commitWriteTransaction()
            return nil
        })
    }
}