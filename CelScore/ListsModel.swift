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
import ObjectMapper
import ObjectMapper_RealmSwift


final class CelebId: Object, Mappable {
    dynamic var id: String = ""
    
    //MARK: Initializer
    required convenience init?(map: Map) { self.init(map: map) }
    
    func mapping(map: Map) {
        self.id <- map["listID"]
    }
}


final class ListsModel: Object, Mappable {
    
    //MARK: Properties
    dynamic var id: String = ""
    dynamic var name: String = ""
    dynamic var isSynced: Bool = true
    var celebList = List<CelebId>()
    
    //MARK: Initializer
    required convenience init?(map: Map) { self.init(map: map) }
    
    func mapping(map: Map) {
        self.id <- map["listID"]
        self.name <- map["name"]
        self.celebList <- map["list"]
        
//        for (index, _) in items.enumerated() {
//            let celebId = CelebId()
//            celebId.id = items[index].string!
//            self.celebList.append(celebId)
//        }
        self.isSynced = true
    }
    
    //MARK: Method
    override class func primaryKey() -> String { return "id" }
}
