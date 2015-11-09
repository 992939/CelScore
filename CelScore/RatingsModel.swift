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
    
    //MARK: Properties
    dynamic var id: String = ""
    dynamic var updatedAt: String = ""
    dynamic var rating1: Double = 0
    dynamic var rating2: Double = 0
    dynamic var rating3: Double = 0
    dynamic var rating4: Double = 0
    dynamic var rating5: Double = 0
    dynamic var rating6: Double = 0
    dynamic var rating7: Double = 0
    dynamic var rating8: Double = 0
    dynamic var rating9: Double = 0
    dynamic var rating10: Double = 0
    dynamic var totalVotes: Int = 0
    dynamic var isSynced: Bool = false
    
    
    //MARK: Initializers
    override public class func primaryKey() -> String { return "id" }
    
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
        self.totalVotes = dictionary["totalVote"] as! Int
        self.isSynced = true
    }
    
    public convenience init(id: String) {
        self.init()
        self.id = id
    }
}

class UserRatingsModel: RatingsModel {
    
    //MARK: Initializers
    internal convenience init(id: String, string: String) {
        self.init()
        
        self.id = id
        self.isSynced = true
        let ratingArray = string.componentsSeparatedByString("/").flatMap { Double($0) }
        self.rating1 = ratingArray[0]
        self.rating2 = ratingArray[1]
        self.rating3 = ratingArray[2]
        self.rating4 = ratingArray[3]
        self.rating5 = ratingArray[4]
        self.rating6 = ratingArray[5]
        self.rating7 = ratingArray[6]
        self.rating8 = ratingArray[7]
        self.rating9 = ratingArray[8]
        self.rating10 = ratingArray[9]
        self.totalVotes = Int(ratingArray[10])
    }
    
    
    //MARK: Methods
    func interpolation() -> String {
        return "\(self.rating1)/\(self.rating2)/\(self.rating3)/\(self.rating4)/\(self.rating5)/\(self.rating6)/\(self.rating7)/\(self.rating8)/\(self.rating9)/\(self.rating10)/\(self.totalVotes)"
    }
}
