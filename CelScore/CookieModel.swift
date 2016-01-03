//
//  CookieModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/2/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

public final class CookieModel: Object, NSCopying {
    
    //MARK: Properties
    dynamic var id: String = ""
    
    
    //MARK: Methods
    public func copyWithZone(zone: NSZone) -> AnyObject { let copy = CookieModel(); copy.id = self.id; return copy }
}