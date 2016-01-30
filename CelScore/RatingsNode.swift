//
//  RatingsNode.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/26/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit


final class RatingsNode: ASCellNode {
    
    //MARK: Properties
    let ratingsVM: RatingsViewModel
    
    //MARK: Initializer
    init(celebrityST: CelebrityStruct) {
        self.ratingsVM = RatingsViewModel(celebrityId: celebrityST.id)
        
        super.init()
        
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
    
    //MARK: Method
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsetsMake(Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding),
            child: ASStackLayoutSpec()),
            background: nil)
    }
}
