//
//  CelebrityModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/10/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

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
}