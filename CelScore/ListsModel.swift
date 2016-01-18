//
//  ListsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/12/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

public final class CelebId: Object, NSCopying {
    
    //MARK: Properties
    dynamic var id: String = ""
    
    //MARK: Methods
    public func copyWithZone(zone: NSZone) -> AnyObject { let copy = CelebId(); copy.id = self.id; return copy }
}


public final class ListsModel: Object, NSCopying {
    
    //MARK: Properties
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var numberOfSearchByLocalUser: Double = 0
    dynamic var count: Int = 0
    dynamic var isSynced: Bool = true
    var celebList = List<CelebId>()
    
    //MARK: Initializer
    public convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        self.id = dictionary["listID"] as! String
        self.name = dictionary["name"] as! String
        let items = dictionary["list"] as! NSArray
        
        for (index, _) in items.enumerate() {
            let celebId = CelebId()
            celebId.id = items[index] as! String
            self.celebList.append(celebId)
        }
        self.count = self.celebList.count
        self.isSynced = true
    }
    
    //MARK: Methods
    override public class func primaryKey() -> String { return "id" }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = ListsModel()
        copy.id = self.id
        copy.name = self.name
        copy.numberOfSearchByLocalUser = self.numberOfSearchByLocalUser
        copy.count = self.count
        copy.isSynced = self.isSynced
        let objectList = List<CelebId>()
        for object in self.celebList.enumerate() {
            objectList.append(object.element.copy() as! CelebId)
        }
        copy.celebList = objectList
        return copy
    }
}
