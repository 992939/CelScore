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
    
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        self.id = dictionary["ratingID"] as! String
        self.updatedAt = dictionary["updatedAt"] as! String
        self.rating1 = dictionary["rating1"] as! Double
        self.rating2 = dictionary["rating2"] as! Double
        self.rating3 = dictionary["rating3"] as! Double
        self.rating4 = dictionary["rating4"] as! Double
        self.rating5 = dictionary["rating5"] as! Double
        self.rating6 = dictionary["rating6"] as! Double
        self.rating7 = dictionary["rating7"] as! Double
        self.rating8 = dictionary["rating8"] as! Double
        self.rating9 = dictionary["rating9"] as! Double
        self.rating10 = dictionary["rating10"] as! Double
        self.isSynced = true
    }
}
