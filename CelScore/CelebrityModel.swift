//
//  CelebrityModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/10/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

extension String {
    func toBool() -> Bool{
        if self == "false" {
            return false
        }else{
            return true
        }
    }
}

public class CelebrityModel: Object {
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
    
    override public class func primaryKey() -> String {
        return "id"
    }
    
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        print(dictionary)
        self.id = dictionary["celebrityID"] as! String
        self.firstName = dictionary["firstName"]!.stringValue
        self.lastName = dictionary["lastName"]!.stringValue
        self.middleName = dictionary["middleName"]!.stringValue
        self.nickName = dictionary["nickname"]!.stringValue
        self.birthdate = dictionary["birthdate"]!.stringValue
        self.netWorth = dictionary["netWorth"]!.stringValue
        self.picture2x = dictionary["picture2x"]!.stringValue
        self.picture3x = dictionary["picture3x"]!.stringValue
        self.rank = dictionary["rank"]!.stringValue
        self.status = dictionary["status"]!.stringValue
        self.twitter = dictionary["twitter"]!.stringValue
        self.sex = dictionary["sex"]!.stringValue.toBool()
        self.isSynced = true
    }
}