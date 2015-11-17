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
    dynamic var defaultListId: String = "0001"
    dynamic var loginTypeIndex: Int = 1
    dynamic var isSynced: Bool = true

    
    //MARK: Initializers
    override public class func primaryKey() -> String { return "id" }
    
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        self.defaultListId = dictionary["defaultListId"] as! String
        self.loginTypeIndex = dictionary["loginTypeIndex"] as! Int
        self.isSynced = true
    }
    
    
    //MARK: Methods
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = SettingsModel()
        copy.id = self.id
        copy.defaultListId = self.defaultListId
        copy.loginTypeIndex = self.loginTypeIndex
        copy.isSynced = self.isSynced
        return copy
    }
}
