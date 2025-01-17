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
import ObjectMapper


final class CelebrityModel: Object, StaticMappable {
    
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
    dynamic var listType: Int = 0
    dynamic var index: Int = 0
    dynamic var y_index: Int = 0
    dynamic var w_index: Int = 0
    dynamic var m_index: Int = 0
    dynamic var sex: Bool = false
    dynamic var isSynced: Bool = true
    dynamic var isFollowed: Bool = false
    dynamic var isTrending: Bool = false
    
    
    //MARK: Initializer
    static func objectForMapping(map: Map) -> BaseMappable? {
        return CelebrityModel()
    }
    
    func mapping(map: Map) {
        self.id <- map["celebrityID"]
        self.firstName <- map["firstName"]
        self.lastName <- map["lastName"]
        self.middleName <- map["middleName"] // == "n/a" ? "∅"
        self.nickName <- map["nickname"]
        self.googleName <- map["google"]
        self.kingName <- map["kingName"]
        self.height <- map["height"]
        self.birthdate <- map["birthdate"]
        self.netWorth <- map["netWorth"]
        self.picture3x <- map["picture3x"]
        self.trend <- map["trend"]
        self.from <- map["from"]
        self.rank <- map["rank"]
        self.status <- map["status"]
        self.twitter <- map["twitter"]
        self.daysOnThrone <- map["daysOnThrone"]
        self.index <- map["index"]
        self.y_index <- map["y_index"]
        self.w_index <- map["w_index"]
        self.m_index <- map["m_index"]
        self.listType <- map["list_type"]
        self.prevScore <- map["prevScore"]
        self.prevWeek <- map["prevWeek"]
        self.prevMonth <- map["prevMonth"]
        self.sex <- map["sex"]
        self.isTrending <- map["trending"]
        self.isSynced = true
        
        let realm = try! Realm()
        let celebrity: CelebrityModel? = realm.objects(CelebrityModel.self).filter("id = %@", self.id).first
        if let object = celebrity { self.isFollowed = object.isFollowed }
    }
    
    //MARK: Method
    override class func primaryKey() -> String { return "id" }

    func getCelebName() -> String {
        var celebName = index == 1 ? kingName : nickName
        if daysOnThrone >= 100 {
            let title: Int = daysOnThrone / 100
            celebName = String("\(kingName) \(title.toRoman())")
        }
        return celebName
    }
    
    func getDays() -> String {
        if daysOnThrone >= 100 { return String(daysOnThrone % 100) }
        return String(daysOnThrone)
    }
}
