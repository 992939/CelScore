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
import ObjectMapper_Realm


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
        self.isSynced = true
    }
    
    //MARK: Method
    override class func primaryKey() -> String { return "id" }
}


final class ListsService: NSObject, Mappable {
    var items: [ListsModel]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        items <- map["Items"]
    }
}
