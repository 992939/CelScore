//
//  SettingsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/7/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON


class SettingsModel: Object {
    
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
    dynamic var isFirstNegative: Bool = true
    dynamic var isFirstCompleted: Bool = true
    dynamic var isFirstInterest: Bool = true
    dynamic var isFirstVoteDisabled: Bool = true
    dynamic var isFirstSocialDisabled: Bool = true
    dynamic var isFirstTrollWarning: Bool = true
    dynamic var isSynced: Bool = true
    
    //MARK: Initializer
    convenience init(json: JSON) {
        self.init()
        self.userName = json["userName"].string!
        self.defaultListIndex = json["defaultListIndex"].int!
        self.loginTypeIndex = json["loginTypeIndex"].int!
        self.publicService = json["publicService"].bool!
        self.consensusBuilding = json["consensusBuilding"].bool!
        self.isFirstLaunch = json["isFirstLaunch"].bool!
        self.isFirstConsensus = json["isFirstConsensus"].bool!
        self.isFirstPublic = json["isFirstPublic"].bool!
        self.isFirstFollow = json["isFirstFollow"].bool!
        self.isFirstNegative = json["isFirstNegative"].bool!
        self.isFirstCompleted = json["isFirstCompleted"].bool!
        self.isFirstInterest = json["isFirstInterest"].bool!
        self.isFirstVoteDisabled = json["isFirstVoteDisabled"].bool!
        self.isFirstSocialDisabled = json["isFirstSocialDisabled"].bool!
        self.isFirstTrollWarning = json["isFirstTrollWarning"].bool!
        self.isSynced = true
    }
    
    //MARK: Method
    override class func primaryKey() -> String { return "id" }
}
