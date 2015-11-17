//
//  RatingsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 7/5/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

public class RatingsModel: Object, SequenceType, NSCopying {
    
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
    public typealias Generator = AnyGenerator<String>
    
    
    //MARK: Initializers
    override public class func primaryKey() -> String { return "id" }
    
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        self.id = dictionary["ratingID"] as! String
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
        self.updatedAt = dictionary["updatedAt"] as! String
        self.totalVotes = dictionary["totalVote"] as! Int
        self.isSynced = true
    }
    
    public convenience init(id: String) {
        self.init()
        self.id = id
    }
    
    
    //MARK: Methods
    public func generate() -> Generator {
        var i = 0
        return anyGenerator {
            switch i++ {
            case 0: return "rating1"
            case 1: return "rating2"
            case 2: return "rating3"
            case 3: return "rating4"
            case 4: return "rating5"
            case 5: return "rating6"
            case 6: return "rating7"
            case 7: return "rating8"
            case 8: return "rating9"
            case 9: return "rating10"
            default: return nil
            }
        }
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = RatingsModel(id: self.id)
        for rating in copy { copy[rating] = self[rating] }
        copy.updatedAt = self.updatedAt
        copy.totalVotes = self.totalVotes
        copy.isSynced = self.isSynced
        return copy
    }
}

class UserRatingsModel: RatingsModel {
    
    //MARK: Initializers
    internal convenience init(id: String, joinedString: String) {
        self.init()
        
        self.id = id
        let ratingArray = joinedString.componentsSeparatedByString("/").flatMap { Double($0) }
        for (index, rating) in self.enumerate() { self[rating] = ratingArray[index] }
        self.totalVotes = Int(ratingArray[10])
        self.isSynced = true
    }
    
    
    //MARK: Methods
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = UserRatingsModel(id: self.id)
        for rating in copy { copy[rating] = self[rating] }
        copy.updatedAt = self.updatedAt
        copy.totalVotes = self.totalVotes
        copy.isSynced = self.isSynced
        return copy
    }
    
    func interpolation() -> String { return self.joinWithSeparator("/") + String(self.totalVotes) }
}
