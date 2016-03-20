//
//  SettingsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/7/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift


public class SettingsModel: Object, NSCopying {
    
    //MARK: Properties
    dynamic var id: String = "1"
    dynamic var userName: String = ""
    dynamic var defaultListIndex: Int = 0
    dynamic var loginTypeIndex: Int = 1
    dynamic var publicService: Bool = false
    dynamic var consensusBuilding: Bool = false
    dynamic var isFirstLaunch: Bool = true
    dynamic var isFirstConsensus: Bool = true
    dynamic var isFirstPublic: Bool = true
    dynamic var isFirstFollow: Bool = true
    dynamic var isFirstStars: Bool = true
    dynamic var isFirstNegative: Bool = true
    dynamic var isFirstCompleted: Bool = true
    dynamic var isFirstInterest: Bool = true
    dynamic var isFirstVoteDisabled: Bool = true
    dynamic var isFirstSocialDisabled: Bool = true
    dynamic var isSynced: Bool = true
    
    //MARK: Initializer
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        self.userName = dictionary["userName"] as! String
        self.defaultListIndex = dictionary["defaultListIndex"] as! Int
        self.loginTypeIndex = dictionary["loginTypeIndex"] as! Int
        self.publicService = dictionary["publicService"] as! Bool
        self.consensusBuilding = dictionary["consensusBuilding"] as! Bool
        self.isFirstLaunch = dictionary["isFirstLaunch"] as! Bool
        self.isFirstConsensus = dictionary["isFirstConsensus"] as! Bool
        self.isFirstPublic = dictionary["isFirstPublic"] as! Bool
        self.isFirstFollow = dictionary["isFirstFollow"] as! Bool
        self.isFirstStars = dictionary["isFirstStars"] as! Bool
        self.isFirstNegative = dictionary["isFirstNegative"] as! Bool
        self.isFirstCompleted = dictionary["isFirstCompleted"] as! Bool
        self.isFirstInterest = dictionary["isFirstInterest"] as! Bool
        self.isFirstVoteDisabled = dictionary["isFirstVoteDisabled"] as! Bool
        self.isFirstSocialDisabled = dictionary["isFirstSocialDisabled"] as! Bool
        self.isSynced = true
    }
    
    //MARK: Methods
    override public class func primaryKey() -> String { return "id" }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = SettingsModel()
        copy.id = self.id
        copy.userName = self.userName
        copy.defaultListIndex = self.defaultListIndex
        copy.loginTypeIndex = self.loginTypeIndex
        copy.publicService = self.publicService
        copy.consensusBuilding = self.consensusBuilding
        copy.isFirstLaunch = self.isFirstLaunch
        copy.isFirstConsensus = self.isFirstConsensus
        copy.isFirstPublic = self.isFirstPublic
        copy.isFirstFollow = self.isFirstFollow
        copy.isFirstStars = self.isFirstStars
        copy.isFirstNegative = self.isFirstNegative
        copy.isFirstCompleted = self.isFirstCompleted
        copy.isFirstInterest = self.isFirstInterest
        copy.isFirstVoteDisabled = self.isFirstVoteDisabled
        copy.isFirstSocialDisabled = self.isFirstSocialDisabled
        copy.isSynced = self.isSynced
        return copy
    }
}
