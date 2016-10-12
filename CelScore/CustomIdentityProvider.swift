//
//  CustomIdentityProvider.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 6/10/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import Foundation

class CustomIdentityProvider: NSObject, AWSIdentityProviderManager {
    
    //MARK: Property
    var tokens : [NSString : NSString]?
    
    //MARK: Initializer
    init(tokens: [NSString : NSString]) { self.tokens = tokens }
    
    //MARK: Method
    public func logins() -> AWSTask<NSDictionary> {
        return AWSTask(result: tokens! as NSDictionary)
    }
}
