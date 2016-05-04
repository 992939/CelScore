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


final class CelebId: Object { dynamic var id: String = "" }

func == (lhs: CelebId, rhs: CelebId) -> Bool { return lhs.id == rhs.id }

final class ListsModel: Object {
    
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
    
    //MARK: Method
    override class func primaryKey() -> String { return "id" }
}
