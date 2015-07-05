//
//  RatingsViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation

class RatingsViewModel: NSObject {
    
    //MARK: Properties
    var rating1, rating2, rating3, rating4, rating5, rating6, rating7, rating8, rating9, rating10 : Double
    
    //MARK: Initializers
    init(rating: PFObject) {
        rating1 = 0
        rating2 = 0
        rating3 = 0
        rating4 = 0
        rating5 = 0
        rating6 = 0
        rating7 = 0
        rating8 = 0
        rating9 = 0
        rating10 = 0
        
        super.init()
        
        rating1 = rating.valueForKey("ratingOne") as! Double
        rating2 = rating.valueForKey("ratingTwo") as! Double
        rating3 = rating.valueForKey("ratingThree") as! Double
        rating4 = rating.valueForKey("ratingFour") as! Double
        rating5 = rating.valueForKey("ratingFive") as! Double
        rating6 = rating.valueForKey("ratingSix") as! Double
        rating7 = rating.valueForKey("ratingSeven") as! Double
        rating8 = rating.valueForKey("ratingEight") as! Double
        rating9 = rating.valueForKey("ratingNine") as! Double
        rating10 = rating.valueForKey("ratingTen") as! Double
    }
}