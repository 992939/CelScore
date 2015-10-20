//
//  ListsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/12/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

private class CelebId: Object {
    dynamic var id = ""
}

public final class ListsModel: Object {
    dynamic var id = ""
    dynamic var name : String = ""
    dynamic var numberOfSearchByLocalUser: Double = 0
    dynamic var count: Int = 0
    private let celebList = List<CelebId>()
    dynamic var isSynced: Bool = false
    
    override public class func primaryKey() -> String {
        return "id"
    }
    
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        self.id = dictionary["listID"] as! String
        self.name = dictionary["name"] as! String
        print(dictionary["list"])
        let items = dictionary["list"] as! NSArray
        
        for (index, _) in items.enumerate() {
            let celebId = CelebId()
            celebId.id = items[index] as! String
            self.celebList.append(celebId)
        }
        self.count = self.celebList.count
        self.isSynced = true
    }
}