//
//  RatingsModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 7/5/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation

struct RatingsModel {
    let rating1, rating2, rating3, rating4, rating5, rating6, rating7, rating8, rating9, rating10 : Double
    
    typealias allRatings = (Double, Double, Double, Double, Double, Double, Double, Double, Double, Double)
    
    init (ratings : allRatings)
    {
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
