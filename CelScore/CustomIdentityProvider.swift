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
    @objc func logins() -> AWSTask { return AWSTask(result: tokens) }
}