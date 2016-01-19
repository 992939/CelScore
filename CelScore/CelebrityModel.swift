//
//  CelebrityModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/10/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift


public struct CelebrityStruct {
    let id: String
    let imageURL: String
    let nickname: String
    let height: String
    let netWorth: String
    let prevScore: Double
    let isFollowed: Bool
}

extension CelebrityStruct: Equatable {}

public func == (lhs: CelebrityStruct, rhs: CelebrityStruct) -> Bool { return lhs.nickname == rhs.nickname && lhs.id == rhs.id }


public final class CelebrityModel: Object, NSCopying {
    
    //MARK: Properties
    dynamic var id: String = ""
    dynamic var birthdate: String = ""
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var middleName: String = ""
    dynamic var nickName: String = ""
    dynamic var height: String = ""
    dynamic var netWorth: String = ""
    dynamic var status: String = ""
    dynamic var twitter: String = ""
    dynamic var rank: String = ""
    dynamic var picture2x: String = ""
    dynamic var picture3x: String = ""
    dynamic var prevScore: Double = 0
    dynamic var sex: Bool = false
    dynamic var isSynced: Bool = true
    dynamic var isFollowed: Bool = false
    
    //MARK: Initializer
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        self.id = dictionary["celebrityID"] as! String
        self.firstName = dictionary["firstName"] as! String
        self.lastName = dictionary["lastName"] as! String
        self.middleName = dictionary["middleName"] as! String
        self.nickName = dictionary["nickname"] as! String
        self.height = dictionary["height"] as! String
        self.birthdate = dictionary["birthdate"] as! String
        self.netWorth = dictionary["netWorth"] as! String
        self.picture2x = dictionary["picture2x"] as! String
        self.picture3x = dictionary["picture3x"] as! String
        self.rank = dictionary["rank"] as! String
        self.status = dictionary["status"] as! String
        self.twitter = dictionary["twitter"] as! String
        self.prevScore = dictionary["prevScore"] as! Double
        self.sex = dictionary["sex"] as! Bool
        self.isSynced = true
    }
    
    //MARK: Methods
    override public class func primaryKey() -> String { return "id" }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = CelebrityModel()
        copy.id = self.id
        copy.birthdate = self.birthdate
        copy.firstName = self.firstName
        copy.lastName = self.lastName
        copy.middleName = self.middleName
        copy.nickName = self.nickName
        copy.height = self.height
        copy.netWorth = self.netWorth
        copy.status = self.status
        copy.twitter = self.twitter
        copy.rank = self.rank
        copy.picture2x = self.picture2x
        copy.picture3x = self.picture3x
        copy.prevScore = self.prevScore
        copy.sex = self.sex
        copy.isFollowed = self.isFollowed
        copy.isSynced = self.isSynced
        return copy
    }
}



