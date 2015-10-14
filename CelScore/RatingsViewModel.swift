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
    let celebrityId: String?
    
    //MARK: Initializers
    init(rating: NSObject, celebrityId: String)
    {
        self.celebrityId = celebrityId
        
        super.init()
        
        ratings = RatingsModel()
        ratings!.id = celebrityId
    }
    
    func updateUserRatingsInRealmSignal() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            let realm = try! Realm()
            realm.beginWrite()
            self.ratings?.isSynced = false
            realm.add(self.ratings!)
            try! realm.commitWrite()
            return nil
        })
    }
    
    func retrieveUserRatingsFromRealmSignal() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            let realm = try! Realm()
            realm.beginWrite()
            let predicate = NSPredicate(format: "id = %@", self.celebrityId!)
            _ = realm.objects(RatingsModel).filter(predicate)
            try! realm.commitWrite()
            return nil
        })
    }
}