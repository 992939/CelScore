//
//  CelebrityModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/10/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

public final class CelebrityModel: Object {
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
    dynamic var prevScore: Double = 0
    dynamic var sex : Bool = false
    dynamic var isSynced: Bool = false
    
    override public class func primaryKey() -> String {
        return "id"
    }
    
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        self.id = dictionary["celebrityID"] as! String
        self.firstName = dictionary["firstName"] as! String
        self.lastName = dictionary["lastName"] as! String
        self.middleName = dictionary["middleName"] as! String
        self.nickName = dictionary["nickname"] as! String
        self.birthdate = dictionary["birthdate"] as! String
        self.netWorth = dictionary["netWorth"] as! String
        self.picture2x = dictionary["picture2x"] as! String
        self.picture3x = dictionary["picture3x"] as! String
        self.rank = dictionary["rank"] as! String
        self.status = dictionary["status"] as! String
        self.twitter = dictionary["twitter"] as! String
        self.sex = dictionary["sex"] as! Bool
        self.prevScore = dictionary["prevScore"] as! Double
        self.isSynced = true
    }
}