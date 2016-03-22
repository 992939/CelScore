//
//  RatingsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 7/5/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift


public class RatingsModel: Object, CollectionType, NSCopying {
    
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
    dynamic var variance1: Double = 0
    dynamic var variance2: Double = 0
    dynamic var variance3: Double = 0
    dynamic var variance4: Double = 0
    dynamic var variance5: Double = 0
    dynamic var variance6: Double = 0
    dynamic var variance7: Double = 0
    dynamic var variance8: Double = 0
    dynamic var variance9: Double = 0
    dynamic var variance10: Double = 0
    dynamic var totalVotes: Int = 0
    dynamic var isSynced: Bool = true
    
    public var startIndex: Int { get { return 0 }}
    public var endIndex: Int { get { return 10 }}
    
    public typealias Index = Int
    public typealias KeyIndex = (key: String, value: Int)
    public typealias Generator = AnyGenerator<String>
    
    //MARK: Initializers
    override public class func primaryKey() -> String { return "id" }
    public convenience init(id: String) { self.init(); self.id = id }
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        self.id = dictionary["ratingID"] as! String
        self.updatedAt = dictionary["updatedAt"] as! String
        self.totalVotes = dictionary["totalVote"] as! Int
        self.variance1 = dictionary["variance1"] as! Double
        self.variance2 = dictionary["variance2"] as! Double
        self.variance3 = dictionary["variance3"] as! Double
        self.variance4 = dictionary["variance4"] as! Double
        self.variance5 = dictionary["variance5"] as! Double
        self.variance6 = dictionary["variance6"] as! Double
        self.variance7 = dictionary["variance7"] as! Double
        self.variance8 = dictionary["variance8"] as! Double
        self.variance9 = dictionary["variance9"] as! Double
        self.variance10 = dictionary["variance10"] as! Double
        for ratings in self.generate() { self[ratings] = dictionary[ratings] as! Double }
        self.isSynced = true
    }
    
    //MARK: Methods
    public func getCelScore() -> Double {
        let score: Double = self.map{ self[$0] as! Double }.reduce(0, combine: { $0 + $1 })
        return (score/10).roundToPlaces(2)
    }
    
    public func getAvgVariance() -> Double {
        let avgVariance: Double = (self.variance1 + self.variance2 + self.variance3 + self.variance4 + self.variance5
        + self.variance6 + self.variance7 + self.variance8 + self.variance9 + self.variance10)/10
        return avgVariance.roundToPlaces(2)
    }
    
    public subscript(i: Int) -> String {
        switch i {
        case 0: return ("rating1")
        case 1: return ("rating2")
        case 2: return ("rating3")
        case 3: return ("rating4")
        case 4: return ("rating5")
        case 5: return ("rating6")
        case 6: return ("rating7")
        case 7: return ("rating8")
        case 8: return ("rating9")
        case 9: return ("rating10")
        default: return ""
        }
    }
    
    public func generate() -> Generator {
        var i = 0
        return AnyGenerator {
            switch i++ {
            case 0: return ("rating1")
            case 1: return ("rating2")
            case 2: return ("rating3")
            case 3: return ("rating4")
            case 4: return ("rating5")
            case 5: return ("rating6")
            case 6: return ("rating7")
            case 7: return ("rating8")
            case 8: return ("rating9")
            case 9: return ("rating10")
            default: return nil
            }
        }
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = RatingsModel(id: self.id)
        for ratings in self.generate() { copy[ratings] = self[ratings] }
        copy.updatedAt = self.updatedAt
        copy.totalVotes = self.totalVotes
        copy.isSynced = self.isSynced
        copy.variance1 = self.variance1
        copy.variance2 = self.variance2
        copy.variance3 = self.variance3
        copy.variance4 = self.variance4
        copy.variance5 = self.variance5
        copy.variance6 = self.variance6
        copy.variance7 = self.variance7
        copy.variance8 = self.variance8
        copy.variance9 = self.variance9
        copy.variance10 = self.variance10
        return copy
    }
}


final class UserRatingsModel: RatingsModel {
    
    //MARK: Initializers
    internal convenience init(id: String, joinedString: String) {
        self.init()
        self.id = id
        let ratingArray = joinedString.componentsSeparatedByString("/").flatMap { Double($0) }
        for (index, ratings) in self.generate().enumerate() { self[ratings] = ratingArray[index] }
        self.isSynced = true
    }
    
    //MARK: Methods
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = UserRatingsModel(id: self.id)
        for ratings in self.generate() { copy[ratings] = self[ratings] }
        copy.updatedAt = self.updatedAt
        copy.isSynced = self.isSynced
        return copy
    }
    
    func interpolation() -> String {
        let allValues: [String] = self.generate().flatMap{ String(self[$0]!) }
        return allValues.joinWithSeparator("/")
    }
}
