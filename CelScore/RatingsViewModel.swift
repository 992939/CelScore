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
    init(rating: PFObject, celebrityId: String)
    {
        self.celebrityId = celebrityId
        
        super.init()
        
        ratings = RatingsModel(value: rating)
    }
    
    func storeUserRatingsInRealmSignal(#userRatings: PFObject) -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            let realm = RLMRealm()
            realm.addObject(self.ratings)
            
            
            return nil
        })
    }

}