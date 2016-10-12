//
//  CustomIdentityProvider.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 6/10/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import Foundation

class CustomIdentityProvider: NSObject, AWSIdentityProviderManager {
    /**
     Each entry in logins represents a single login with an identity provider. The key is the domain of the login provider (e.g. 'graph.facebook.com') and the value is the OAuth/OpenId Connect token that results from an authentication with that login provider.
     */
    public func logins() -> AWSTask<NSDictionary> {

    }

    
    //MARK: Property
    var tokens : [NSString : NSString]?
    
    //MARK: Initializer
    init(tokens: [NSString : NSString]) { self.tokens = tokens }
    
    //MARK: Method
    //@objc func logins() -> AWSTask<AnyObject> { return AWSTask(result: tokens) }
}
