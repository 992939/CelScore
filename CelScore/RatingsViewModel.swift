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
    }
}