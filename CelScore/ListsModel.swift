//
//  ListsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/12/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

public class ListsModel: Object {
    dynamic var id = ""
    dynamic var name : String = ""
    //dynamic var celebList : [String] = Array()
    dynamic var isSynced: Bool = false
    
    override public class func primaryKey() -> String {
        return "id"
    }
}