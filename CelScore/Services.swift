//
//  Services.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 10/31/17.
//  Copyright © 2017 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import ObjectMapper


final class CelebrityService: NSObject, Mappable {
    var items: [CelebrityModel]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        items <- map["Items"]
    }
}


final class RatingsService: NSObject, Mappable {
    var items: [RatingsModel]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        items <- map["Items"]
    }
}
