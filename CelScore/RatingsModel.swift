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
}
