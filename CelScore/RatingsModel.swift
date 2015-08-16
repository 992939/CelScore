//
//  RatingsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 7/5/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation

class RatingsModel: RLMObject {
    dynamic var id = ""
    dynamic var rating1 : Double = 0
    dynamic var rating2 : Double = 0
    dynamic var rating3 : Double = 0
    dynamic var rating4 : Double = 0
    dynamic var rating5 : Double = 0
    dynamic var rating6 : Double = 0
    dynamic var rating7 : Double = 0
    dynamic var rating8 : Double = 0
    dynamic var rating9 : Double = 0
    dynamic var rating10 : Double = 0
    dynamic var isSynced: Bool = false
    
    override init() {
        super.init()
    }
    
    override init(value: AnyObject!) {
        super.init(value: value)
        
        self.rating1 = value.valueForKey("ratingOne") as! Double
        self.rating2 = value.valueForKey("ratingTwo") as! Double
        self.rating3 = value.valueForKey("ratingThree") as! Double
        self.rating4 = value.valueForKey("ratingFour") as! Double
        self.rating5 = value.valueForKey("ratingFive") as! Double
        self.rating6 = value.valueForKey("ratingSix") as! Double
        self.rating7 = value.valueForKey("ratingSeven") as! Double
        self.rating8 = value.valueForKey("ratingEight") as! Double
        self.rating9 = value.valueForKey("ratingNine") as! Double
        self.rating10 = value.valueForKey("ratingTen") as! Double
    }
    
    override class func primaryKey() -> String {
        return "id"
    }
}
