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


class RatingsModel: Object, Collection {
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return 1
    }

    
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
    
    var startIndex: Int { get { return 0 }}
    var endIndex: Int { get { return 10 }}
    
    typealias Index = Int
    typealias KeyIndex = (key: String, value: Int)
    typealias Iterator = AnyIterator<String>
    
    //MARK: Initializers
    override class func primaryKey() -> String { return "id" }
    convenience init(id: String) { self.init(); self.id = id }
    convenience init(json: JSON) {
        self.init()
        
        self.id = json["ratingID"].string!
        self.updatedAt = json["updatedAt"].string!
        self.totalVotes = json["totalVote"].int!
        self.variance1 = json["variance1"].double!
        self.variance2 = json["variance2"].double!
        self.variance3 = json["variance3"].double!
        self.variance4 = json["variance4"].double!
        self.variance5 = json["variance5"].double!
        self.variance6 = json["variance6"].double!
        self.variance7 = json["variance7"].double!
        self.variance8 = json["variance8"].double!
        self.variance9 = json["variance9"].double!
        self.variance10 = json["variance10"].double!
        for ratings in self.makeIterator() { self[ratings] = json[ratings].double! }
        self.isSynced = true
    }
    
    //MARK: Methods
    func getCelScore() -> Double {
        let score: Double = self.map{ self[$0] as! Double }.reduce(0, { $0 + $1 })
        return (score/10).roundToPlaces(places: 2)
    }
    
    func getAvgVariance() -> Double {
        let avgVariance: Double = (self.variance1 + self.variance2 + self.variance3 + self.variance4 + self.variance5
        + self.variance6 + self.variance7 + self.variance8 + self.variance9 + self.variance10)/10
        return avgVariance.roundToPlaces(places: 2)
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
