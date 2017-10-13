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
    dynamic var lastVisit: String = ""
    dynamic var userName: String = ""
    dynamic var defaultListIndex: Int = 0
    dynamic var loginTypeIndex: Int = 0
    dynamic var averageRoyalty: Double = 0
    dynamic var onCountdown: Bool = false
    dynamic var isFirstInterest: Bool = true
    dynamic var isFirstTrollWarning: Bool = true
    dynamic var isSynced: Bool = true
    
    //MARK: Initializer
    convenience init(json: JSON) {
        self.init()
        self.userName = json["userName"].string!
        self.lastVisit = json["lastVisit"].string ?? Date().stringMMddyyyyFormat()
        self.defaultListIndex = json["defaultListIndex"].int!
        self.loginTypeIndex = json["loginTypeIndex"].int!
        self.onCountdown = json["onCountdown"].bool!
        self.isFirstInterest = json["isFirstInterest"].bool!
        self.isFirstTrollWarning = json["isFirstTrollWarning"].bool!
        self.isSynced = true
    }
    
    //MARK: Method
    override class func primaryKey() -> String { return "id" }
}
