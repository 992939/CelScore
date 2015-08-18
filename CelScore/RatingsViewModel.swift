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
    var notificationToken: RLMNotificationToken?
    let celebrityId: String?
    
    //MARK: Initializers
    init(rating: PFObject, celebrityId: String)
    {
        self.celebrityId = celebrityId
        
        super.init()
        
        ratings = RatingsModel(value: rating)
        ratings!.id = celebrityId
    }
    
    func storeUserRatingsInRealmSignal() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            let realm = RLMRealm.defaultRealm()
            self.notificationToken = RLMRealm.defaultRealm().addNotificationBlock({ (text: String, realm) -> Void in
                println("REALM NOTIFICATION \(text)")
            })
            
            realm.beginWriteTransaction()
            realm.addOrUpdateObject(self.ratings!)
            realm.commitWriteTransaction()
            RLMRealm.defaultRealm().removeNotification(self.notificationToken!)
            
            return nil
        })
    }
    
    func retrieveUserRatingsFromRealmSignal() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            let realm = RLMRealm.defaultRealm()
            self.notificationToken = RLMRealm.defaultRealm().addNotificationBlock({ (text: String, realm) -> Void in
                println("REALM NOTIFICATION \(text)")
            })
            
            realm.beginWriteTransaction()
            let predicate = NSPredicate(format: "id = %@", self.celebrityId!)
            var userRatings = RatingsModel.objectsInRealm(realm, withPredicate: predicate).objectAtIndex(0) as! RatingsModel
            realm.commitWriteTransaction()
            RLMRealm.defaultRealm().removeNotification(self.notificationToken!)
            
            return nil
        })
    }
}