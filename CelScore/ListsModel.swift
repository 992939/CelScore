//
//  ListsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/12/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON


final class CelebId: Object, NSCopying {
    
    //MARK: Properties
    dynamic var id: String = ""
    
    //MARK: Methods
    func copyWithZone(zone: NSZone) -> AnyObject { let copy = CelebId(); copy.id = self.id; return copy }
}

extension CelebId: Equatable {}

func == (lhs: CelebId, rhs: CelebId) -> Bool { return lhs.id == rhs.id }

final class ListsModel: Object, NSCopying {
    
    //MARK: Properties
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var numberOfSearchByLocalUser: Int = 0
    dynamic var isSynced: Bool = true
    var celebList = List<CelebId>()
    
    //MARK: Initializer
    convenience init(json: JSON) {
        self.init()
        self.id = json["listID"].string!
        self.name = json["name"].string!
        let items = json["list"].array!
        
        for (index, _) in items.enumerate() {
            let celebId = CelebId()
            celebId.id = items[index].string!
            self.celebList.append(celebId)
        }
        self.isSynced = true
    }
    
    //MARK: Methods
    override class func primaryKey() -> String { return "id" }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = ListsModel()
        copy.id = self.id
        copy.name = self.name
        copy.numberOfSearchByLocalUser = self.numberOfSearchByLocalUser
        copy.isSynced = self.isSynced
        let objectList = List<CelebId>()
        for object in self.celebList.enumerate() {
            objectList.append(object.element.copy() as! CelebId)
        }
        copy.celebList = objectList
        return copy
    }
}
