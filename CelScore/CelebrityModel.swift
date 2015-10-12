//
//  CelebrityModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/10/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation

class CelebrityModel: RLMObject {
    dynamic var id = ""
    dynamic var birthdate : String = ""
    dynamic var firstName : String = ""
    dynamic var lastName : String = ""
    dynamic var middleName : String = ""
    dynamic var nickName : String = ""
    dynamic var netWorth : String = ""
    dynamic var status : String = ""
    dynamic var twitter : String = ""
    dynamic var rank : String = ""
    dynamic var picture2x : String = ""
    dynamic var picture3x : String = ""
    dynamic var sex : Bool = false
    dynamic var isSynced: Bool = false
    
    override init() {
        super.init()
    }
    
    override init(value: AnyObject) {
        super.init(value: value)
        
        self.id = value.valueForKey("celebrityID") as! String
        self.birthdate = value.valueForKey("birthdate") as! String
        self.firstName = value.valueForKey("firstName") as! String
        self.lastName = value.valueForKey("lastName") as! String
        self.middleName = value.valueForKey("middleName") as! String
        self.nickName = value.valueForKey("nickname") as! String
        self.netWorth = value.valueForKey("netWorth") as! String
        self.status = value.valueForKey("status") as! String
        self.twitter = value.valueForKey("twitter") as! String
        self.rank = value.valueForKey("rank") as! String
        self.picture2x = value.valueForKey("picture2x") as! String
        self.picture3x = value.valueForKey("picture3x") as! String
        self.sex = value.valueForKey("sex") as! Bool
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
}