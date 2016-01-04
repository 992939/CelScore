//
//  CookieModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/2/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import RealmSwift

public final class Chip: Object, NSCopying {
    
    //MARK: Properties
    dynamic var index: Int = 0
    
    
    //MARK: Initializers
    public convenience init(index: Int) { self.init(); self.index = index }
    
    
    //MARK: Methods
    public func copyWithZone(zone: NSZone) -> AnyObject { let copy = Chip(); copy.index = self.index; return copy }
}


public final class CookieModel: Object, NSCopying {
    
    //MARK: Properties
    dynamic var id: String = ""
    var list = List<Chip>()
    
    
    //MARK: Initializers
    public convenience init(id: String, chip: Chip) { self.init(); self.id = id; self.list.append(chip) }
    
    //MARK: Methods
    override public class func primaryKey() -> String { return "id" }
    
    
    //MARK: Methods
    public func copyWithZone(zone: NSZone) -> AnyObject { let copy = CookieModel(); copy.id = self.id; copy.list = self.list; return copy }
}