//
//  RatingsViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/1/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material


final class RatingsViewController: ASViewController {
    
    //MARK: Properties
    let ratingsVM: RatingsViewModel
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct, frame: CGRect) {
        self.ratingsVM = RatingsViewModel(celebrityId: celebrityST.id)
        
        super.init(node: ASDisplayNode())
        self.view.frame = frame
        
        self.ratingsVM.getRatingsSignal(ratingType: .Ratings).start()
        self.ratingsVM.getRatingsSignal(ratingType: .UserRatings).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 0, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 1, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 2, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 3, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 4, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 5, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 6, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 7, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 8, newRating: 3).start()
        self.ratingsVM.updateUserRatingSignal(ratingIndex: 9, newRating: 3).start()
        self.ratingsVM.voteSignal().start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = MaterialColor.blue.base
    }
}