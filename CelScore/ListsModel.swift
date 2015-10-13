//
//  ListsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/12/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation

class ListsModel: RLMObject {
    dynamic var id = ""
    dynamic var name : String = ""
    dynamic var celebList : [String] = Array()
    dynamic var isSynced: Bool = false
    
    override init() {
        super.init()
    }
    
    override init(value: AnyObject) {
        super.init(value: value)
        
        self.id = value.valueForKey("listID") as! String
        self.name = value.valueForKey("name") as! String
        self.celebList = value.valueForKey("list") as! [String]
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
}