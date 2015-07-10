//
//  RatingsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 7/5/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation

class RatingsModel: RLMObject {
    var rating1 : Double = 0
    var rating2 : Double = 0
    var rating3 : Double = 0
    var rating4 : Double = 0
    var rating5 : Double = 0
    var rating6 : Double = 0
    var rating7 : Double = 0
    var rating8 : Double = 0
    var rating9 : Double = 0
    var rating10 : Double = 0
    
    typealias allRatings = (Double, Double, Double, Double, Double, Double, Double, Double, Double, Double)
    
    override init() {
        super.init()
    }
    
    override init(value: AnyObject!) {
        super.init(value: value)
        
                let ratings = allRatings((value.valueForKey("ratingOne") as? Double)!, (value.valueForKey("ratingTwo") as? Double)!, (value.valueForKey("ratingThree") as? Double)!, (value.valueForKey("ratingFour") as? Double)!, (value.valueForKey("ratingFive") as? Double)!, (value.valueForKey("ratingSix") as? Double)!, (value.valueForKey("ratingSeven") as? Double)!, (value.valueForKey("ratingEight") as? Double)!, (value.valueForKey("ratingNine") as? Double)!, (value.valueForKey("ratingTen") as? Double)!)
        
        self.rating1 = ratings.0
        self.rating2 = ratings.1
        self.rating3 = ratings.2
        self.rating4 = ratings.3
        self.rating5 = ratings.4
        self.rating6 = ratings.5
        self.rating7 = ratings.6
        self.rating8 = ratings.7
        self.rating9 = ratings.8
        self.rating10 = ratings.9
    }
}
