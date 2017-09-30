//
//  CelebrityModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/10/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON


struct CelebrityStruct {
    let id: String
    let imageURL: String
    let trend: String
    let nickName: String
    let kingName: String
    let prevScore: Double
    let prevWeek: Double
    let prevMonth: Double
    let index: Int
    let y_index: Int
    let daysOnThrone: Int
    let sex: Bool
    let isFollowed: Bool
    let isTrending: Bool

    func getCelebName() -> String {
        var celebName = index == 1 ? kingName : nickName
        if daysOnThrone >= 100 {
            let title: Int = daysOnThrone / 100
            celebName = String("\(kingName) \(toRoman(number: title))")
        }
        return celebName
    }
    
    func getDaysOnThrone() -> String {
        var days = daysOnThrone < 1 ? "∅" : String(daysOnThrone)
        if daysOnThrone >= 100 {
            days = String(daysOnThrone % 100)
        }
        return days
    }
    
    func toRoman(number: Int) -> String {
        let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        let arabicValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        var romanValue = ""
        var startingValue = number
        
        for (index, romanChar) in romanValues.enumerated() {
            let arabicValue = arabicValues[index]
            let div = startingValue / arabicValue
            
            if div > 0 {
                for _ in 0..<div { romanValue += romanChar }
                startingValue -= arabicValue * div
            }
        }
        return romanValue
    }
}

extension CelebrityStruct: Equatable {}

func == (lhs: CelebrityStruct, rhs: CelebrityStruct) -> Bool { return lhs.nickName == rhs.nickName && lhs.id == rhs.id }


final class CelebrityModel: Object {
    
    //MARK: Properties
    dynamic var id: String = ""
    dynamic var lastVisit: String = ""
    dynamic var birthdate: String = ""
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var middleName: String = ""
    dynamic var nickName: String = ""
    dynamic var googleName: String = ""
    dynamic var kingName: String = ""
    dynamic var height: String = ""
    dynamic var netWorth: String = ""
    dynamic var status: String = ""
    dynamic var twitter: String = ""
    dynamic var rank: String = ""
    dynamic var picture3x: String = ""
    dynamic var trend: String = "ZZZZ"
    dynamic var from: String = ""
    dynamic var prevScore: Double = 0
    dynamic var prevWeek: Double = 0
    dynamic var prevMonth: Double = 0
    dynamic var daysOnThrone: Int = 0
    dynamic var index: Int = 0
    dynamic var y_index: Int = 0
    dynamic var w_index: Int = 0
    dynamic var m_index: Int = 0
    dynamic var sex: Bool = false
    dynamic var isSynced: Bool = true
    dynamic var isFollowed: Bool = false
    dynamic var isTrending: Bool = false
    
    //MARK: Initializer
    convenience init(json: JSON) {
        self.init()
        
        self.id = json["celebrityID"].string!
        self.firstName = json["firstName"].string!
        self.lastName = json["lastName"].string!
        self.middleName = json["middleName"].string! == "n/a" ? "∅" : json["middleName"].string!
        self.nickName = json["nickname"].string!
        self.googleName = json["google"].string!
        self.kingName = json["kingName"].string!
        self.height = json["height"].string!
        self.birthdate = json["birthdate"].string!
        self.netWorth = json["netWorth"].string!
        self.picture3x = json["picture3x"].string!
        self.trend = json["trend"].string!
        self.from = json["from"].string!
        self.rank = json["rank"].string!
        self.status = json["status"].string!
        self.twitter = json["twitter"].string!
        self.daysOnThrone = json["daysOnThrone"].int!
        self.index = json["index"].int!
        self.y_index = json["y_index"].int!
        self.w_index = json["w_index"].int!
        self.m_index = json["m_index"].int!
        self.prevScore = json["prevScore"].double!
        self.prevWeek = json["prevWeek"].double!
        self.prevMonth = json["prevMonth"].double!
        self.sex = json["sex"].bool!
        self.isTrending = json["trending"].bool!
        self.isSynced = true
        
        let realm = try! Realm()
        let celebrity: CelebrityModel? = realm.objects(CelebrityModel.self).filter("id = %@", self.id).first
        if let object = celebrity { self.isFollowed = object.isFollowed }
        
        let rating = realm.objects(RatingsModel.self).filter("id = %@", self.id).first
        guard rating?.isEmpty == false  else {
            realm.beginWrite()
            let newRating = RatingsModel(id: self.id)
            realm.add(newRating, update: false)
            try! realm.commitWrite()
            return
        }
    }
    
    //MARK: Method
    override class func primaryKey() -> String { return "id" }
}
