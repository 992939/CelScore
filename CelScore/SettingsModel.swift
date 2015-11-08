//
//  SettingsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/7/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

public class SettingsModel: Object {
    
    //MARK: Properties
    dynamic var id: String = "1"
    dynamic var defaultListId: String = "0001"
    dynamic var rankSettingIndex: Int = 0
    dynamic var notificationSettingIndex: Int = 0
    dynamic var loginTypeIndex: Int = 0
    dynamic var isSynced: Bool = false

    
    //MARK: Initializers
    override public class func primaryKey() -> String { return "id" }
    
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        self.defaultListId = dictionary["defaultListId"] as! String
        self.rankSettingIndex = dictionary["rankSettingIndex"] as! Int
        self.notificationSettingIndex = dictionary["notificationSettingIndex"] as! Int
        self.loginTypeIndex = dictionary["loginTypeIndex"] as! Int
        self.isSynced = true
    }
}
