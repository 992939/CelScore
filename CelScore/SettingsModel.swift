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
    dynamic var defaultListIndex: Int = 0
    dynamic var loginTypeIndex: Int = 1
    dynamic var publicService: Bool = false
    dynamic var fortuneMode: Bool = false
    dynamic var isSynced: Bool = true
    
    //MARK: Initializer
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        self.defaultListIndex = dictionary["defaultListIndex"] as! Int
        self.loginTypeIndex = dictionary["loginTypeIndex"] as! Int
        self.publicService = dictionary["publicService"] as! Bool
        self.fortuneMode = dictionary["fortuneMode"] as! Bool
        self.isSynced = true
    }
    
    //MARK: Methods
    override public class func primaryKey() -> String { return "id" }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = SettingsModel()
        copy.id = self.id
        copy.defaultListIndex = self.defaultListIndex
        copy.loginTypeIndex = self.loginTypeIndex
        copy.publicService = self.publicService
        copy.fortuneMode = self.fortuneMode
        copy.isSynced = self.isSynced
        return copy
    }
}
