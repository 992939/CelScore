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
    let nickName: String
    let kingName: String
    let prevScore: Double
    let prevWeek: Double
    let prevMonth: Double
    let index: Int
    let sex: Bool
    let isFollowed: Bool
    let isKing: Bool
}

extension CelebrityStruct: Equatable {}

func == (lhs: CelebrityStruct, rhs: CelebrityStruct) -> Bool { return lhs.nickName == rhs.nickName && lhs.id == rhs.id }


final class CelebrityModel: Object {
    
    //MARK: Properties
    dynamic var id: String = ""
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
    dynamic var from: String = ""
    dynamic var prevScore: Double = 0
    dynamic var prevWeek: Double = 0
    dynamic var prevMonth: Double = 0
    dynamic var daysOnThrone: Int = 0
    dynamic var index: Int = 0
    dynamic var sex: Bool = false
    dynamic var isSynced: Bool = true
    dynamic var isFollowed: Bool = false
    dynamic var isNew: Bool = false
    dynamic var isKing: Bool = false
    
    //MARK: Initializer
    convenience init(json: JSON) {
        self.init()
        
        self.id = json["celebrityID"].string!
        self.firstName = json["firstName"].string!
        self.lastName = json["lastName"].string!
        self.middleName = json["middleName"].string!
        self.nickName = json["nickname"].string!
        self.googleName = json["google"].string!
        self.kingName = json["kingName"].string!
        self.height = json["height"].string!
        self.birthdate = json["birthdate"].string!
        self.netWorth = json["netWorth"].string!
        self.picture3x = json["picture3x"].string!
        self.from = json["from"].string!
        self.rank = json["rank"].string!
        self.status = json["status"].string!
        self.twitter = json["twitter"].string!
        self.daysOnThrone = json["daysOnThrone"].int!
        self.index = json["index"].int!
        self.prevScore = json["prevScore"].double!
        self.prevWeek = json["prevWeek"].double!
        self.prevMonth = json["prevMonth"].double!
        self.sex = json["sex"].bool!
        self.isKing = json["king"].bool!
        self.isSynced = true
        
        let realm = try! Realm()
        let celebrity: CelebrityModel? = realm.objects(CelebrityModel.self).filter("id = %@", self.id).first
        if let object = celebrity { self.isFollowed = object.isFollowed }
        else { self.isNew = true }
        
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



