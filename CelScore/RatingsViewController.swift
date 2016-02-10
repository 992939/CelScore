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
    let celebST: CelebrityStruct
    let pulseView: MaterialView
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct, frame: CGRect) {
        self.celebST = celebrityST
        self.pulseView = MaterialView(frame: frame)
        super.init(node: ASDisplayNode())
        self.view.frame = frame
        self.view.tag = Constants.kDetailViewTag
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let maxHeight = self.pulseView.height - 2 * Constants.kCellPadding
        let maxWidth = self.pulseView.width - 2 * Constants.kCellPadding
        
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .Ratings)
            .on(next: { ratings in
                for (index, quality) in Qualities.getAll().enumerate() {
                    let qualityView = MaterialPulseView(frame: CGRect(x: Constants.kCellPadding, y: CGFloat(index) * (maxHeight / 10) + Constants.kCellPadding, width: maxWidth, height: 30))
                    let qualityLabel = UILabel()
                    qualityLabel.text = quality
                    qualityLabel.frame = CGRect(x: Constants.kCellPadding, y: 3, width: 120, height: 25)
                    qualityView.depth = .Depth1
                    qualityView.backgroundColor = MaterialColor.white
                    qualityView.pulseScale = false
                    
                    let cosmosView = CosmosView(frame: CGRect(x: maxWidth - 140, y: 3, width: 140, height: 25))
                    cosmosView.tag = index
                    switch quality {
                    case Qualities.Talent.name(): cosmosView.rating = ratings.rating1
                    case Qualities.Originality.name(): cosmosView.rating = ratings.rating2
                    case Qualities.Authenticity.name(): cosmosView.rating = ratings.rating3
                    case Qualities.Generosity.name(): cosmosView.rating = ratings.rating4
                    case Qualities.RoleModel.name(): cosmosView.rating = ratings.rating5
                    case Qualities.HardWork.name(): cosmosView.rating = ratings.rating6
                    case Qualities.Smarts.name(): cosmosView.rating = ratings.rating7
                    case Qualities.Elegance.name(): cosmosView.rating = ratings.rating8
                    case Qualities.Charisma.name(): cosmosView.rating = ratings.rating9
                    case Qualities.SexAppeal.name(): cosmosView.rating = ratings.rating10
                    default: cosmosView.rating = 3 }
                    cosmosView.settings.starSize = 22
                    cosmosView.settings.starMargin = 5
                    cosmosView.settings.previousRating = Int(cosmosView.rating)
                    cosmosView.settings.updateOnTouch = true
                    cosmosView.settings.colorFilled = MaterialColor.yellow.darken1
                    cosmosView.settings.borderColorEmpty = MaterialColor.yellow.darken3
                    cosmosView.didTouchCosmos = { rating in
                        cosmosView.settings.userRatingMode = true
                        RatingsViewModel().updateUserRatingSignal(ratingsId: self.celebST.id, ratingIndex: cosmosView.tag, newRating: Int(rating)).start()
                    }
                    
                    qualityView.addSubview(qualityLabel)
                    qualityView.addSubview(cosmosView)
                    self.pulseView.addSubview(qualityView)
                }
            })
            .start()
        
        self.pulseView.backgroundColor = MaterialColor.clear
        self.view = self.pulseView
    }
}