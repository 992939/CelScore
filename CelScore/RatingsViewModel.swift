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
    var rating1, rating2, rating3, rating4, rating5, rating6, rating7, rating8, rating9, rating10 : Double?
    var ratings : RatingsModel?
    typealias allRatings = (Double, Double, Double, Double, Double, Double, Double, Double, Double, Double)
    
    //MARK: Initializers
    init(rating: PFObject) {
        
        super.init()
        
        rating1 = rating.valueForKey("ratingOne") as? Double
        rating2 = rating.valueForKey("ratingTwo") as? Double
        rating3 = rating.valueForKey("ratingThree") as? Double
        rating4 = rating.valueForKey("ratingFour") as? Double
        rating5 = rating.valueForKey("ratingFive") as? Double
        rating6 = rating.valueForKey("ratingSix") as? Double
        rating7 = rating.valueForKey("ratingSeven") as? Double
        rating8 = rating.valueForKey("ratingEight") as? Double
        rating9 = rating.valueForKey("ratingNine") as? Double
        rating10 = rating.valueForKey("ratingTen") as? Double
        
        var ratingsCollection = allRatings(rating1!, rating2!, rating3!, rating4!, rating5!, rating6!, rating7!, rating8!, rating9!, rating10!)
        
        ratings = RatingsModel(ratings: ratingsCollection)
    }
}