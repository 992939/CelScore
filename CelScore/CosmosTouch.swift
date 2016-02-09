//
// Star rating control written in Swift for iOS.
//
// https://github.com/marketplacer/Cosmos
//
// This file was automatically generated by combining multiple Swift source files.
//

import UIKit


struct CosmosTouch {
  /**
  
  Calculates the rating based on the touch location.
  - parameter locationX: The horizontal location of the touch relative to the width of the stars.
  - parameter starsWidth: The width of the stars excluding the text.
  - returns: The rating representing the touch location.
  
  */
  static func touchRating(locationX: CGFloat, starsWidth: CGFloat, settings: CosmosSettings) -> Double {
    let position = locationX / starsWidth
    let totalStars = Double(settings.totalStars)
    let actualRating = totalStars * Double(position)
    var correctedRating = actualRating
    
    if settings.fillMode != .Precise { correctedRating += 0.25 }
    
    correctedRating = CosmosRating.displayedRatingFromPreciseRating(correctedRating, fillMode: settings.fillMode, totalStars: settings.totalStars)
    correctedRating = max(settings.minTouchRating, correctedRating) // Can't be less than min rating
    return correctedRating
  }
}


//MARK: CosmosTouchTarget
struct CosmosTouchTarget {
  static func optimize(bounds: CGRect) -> CGRect {
    let recommendedHitSize: CGFloat = 44
    
    var hitWidthIncrease:CGFloat = recommendedHitSize - bounds.width
    var hitHeightIncrease:CGFloat = recommendedHitSize - bounds.height
    
    if hitWidthIncrease < 0 { hitWidthIncrease = 0 }
    if hitHeightIncrease < 0 { hitHeightIncrease = 0 }
    
    let extendedBounds: CGRect = CGRectInset(bounds, -hitWidthIncrease / 2, -hitHeightIncrease / 2)
    return extendedBounds
  }
}
