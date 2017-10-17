//
//  RatingsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 7/5/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import ObjectMapper
import ObjectMapper_Realm


class RatingsModel: Object, Collection, StaticMappable {

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
    dynamic var isSynced: Bool = true
    
    var startIndex: Int { get { return 0 }}
    var endIndex: Int { get { return 10 }}
    
    typealias Index = Int
    typealias KeyIndex = (key: String, value: Int)
    typealias Iterator = AnyIterator<String>

    
    //MARK: Methods
    static func objectForMapping(map: Map) -> BaseMappable? {
        return RatingsModel()
    }
    
    func mapping(map: Map) {
        self.id <- map["ratingID"]
        self.updatedAt <- map["updatedAt"]
        self.totalVotes <- map["totalVote"]
        self.rating1 <- map["rating1"]
        self.rating2 <- map["rating2"]
        self.rating3 <- map["rating3"]
        self.rating4 <- map["rating4"]
        self.rating5 <- map["rating5"]
        self.rating6 <- map["rating6"]
        self.rating7 <- map["rating7"]
        self.rating8 <- map["rating8"]
        self.rating9 <- map["rating9"]
        self.rating10 <- map["rating10"]
        self.isSynced = true
    }
    
    override class func primaryKey() -> String { return "id" }
    
    public func index(after i: Int) -> Int {
        guard i < 9 else { return 0 }
        return i + 1
    }

    func getCelScore() -> Double {
        let total: Double = (self.rating1 + self.rating2 + self.rating3 + self.rating4 + self.rating5
            + self.rating6 + self.rating7 + self.rating8 + self.rating9 + self.rating10) * 2
        return total.roundToPlaces(places: 2)
    }
    
    func getMax() -> String {
        var max_element = "rating1"
        for (_, rating) in self.makeIterator().enumerated() {
            let element =  self[rating] as! Double
            let max = self[max_element] as! Double
            if element > max { max_element = rating }
        }
        return max_element
    }
    
    func getMin() -> String {
        var min_element = "rating1"
        for (_, rating) in self.makeIterator().enumerated() {
            let element =  self[rating] as! Double
            let min = self[min_element] as! Double
            if element < min { min_element = rating }
        }
        return min_element
    }
    
    subscript(i: Int) -> String {
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
    
    func makeIterator() -> Iterator {
        var i = 0
        return AnyIterator {
            switch i {
            case 0: i += 1; return ("rating1")
            case 1: i += 1; return ("rating2")
            case 2: i += 1; return ("rating3")
            case 3: i += 1; return ("rating4")
            case 4: i += 1; return ("rating5")
            case 5: i += 1; return ("rating6")
            case 6: i += 1; return ("rating7")
            case 7: i += 1; return ("rating8")
            case 8: i += 1; return ("rating9")
            case 9: i += 1; return ("rating10")
            default: return nil
            }
        }
    }
}


final class UserRatingsModel: RatingsModel {
    
    //MARK: Initializers
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
    internal convenience init(id: String, joinedString: String) {
        self.init()
        self.id = id
        let ratingArray = joinedString.components(separatedBy: "/").flatMap { Double($0) }
        for (index, ratings) in self.makeIterator().enumerated() { self[ratings] = ratingArray[index] }
        self.isSynced = true
    }
    
    //MARK: Method
    func interpolation() -> String {
        let allValues: [String] = self.makeIterator().flatMap{ String(describing: self[$0]!) }
        return allValues.joined(separator: "/")
    }
}


final class RatingsService: NSObject, Mappable {
    var items: [RatingsModel]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        items <- map["Items"]
    }
}
