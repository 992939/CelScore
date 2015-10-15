//
//  RatingsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 7/5/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

public class RatingsModel: Object {
    dynamic var id = ""
    dynamic var updatedAt = ""
    dynamic var rating1 : Double = 0
    dynamic var rating2 : Double = 0
    dynamic var rating3 : Double = 0
    dynamic var rating4 : Double = 0
    dynamic var rating5 : Double = 0
    dynamic var rating6 : Double = 0
    dynamic var rating7 : Double = 0
    dynamic var rating8 : Double = 0
    dynamic var rating9 : Double = 0
    dynamic var rating10 : Double = 0
    dynamic var isSynced: Bool = false
    
    override public class func primaryKey() -> String {
        return "id"
    }
    
    public init(dictionary: Dictionary<String, AnyObject>) {
        super.init(value: dictionary)
        
//        self.id = dictionary["celebrityID"]!.stringValue
//        self.firstName = dictionary["firstName"]!
//        self.lastName = dictionary["lastName"]!.stringValue
//        self.middleName = dictionary["middleName"]!.stringValue
//        self.nickName = dictionary["nickname"]!.stringValue
//        self.birthdate = dictionary["birthdate"]!.stringValue
//        self.netWorth = dictionary["netWorth"]!.stringValue
//        self.picture2x = dictionary["picture2x"]!.stringValue
//        self.picture3x = dictionary["picture3x"]!.stringValue
//        self.rank = dictionary["rank"]!.stringValue
//        self.status = dictionary["status"]!.stringValue
//        self.twitter = dictionary["twitter"]!.stringValue
//        self.sex = dictionary["sex"]!.bool!
//        self.isSynced = true
    }

    required public init() {
        super.init()
    }
}
