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
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.pulseView = MaterialView(frame: Constants.kBottomViewRect)
        super.init(node: ASDisplayNode())
        self.view.tag = Constants.kDetailViewTag
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .Ratings)
            .on(next: { ratings in
                for (index, quality) in Qualities.getAll().enumerate() {
                    
                    let qualityView = MaterialPulseView(frame: CGRect(x: Constants.kPadding, y: CGFloat(index) * (Constants.kBottomHeight / 10) + Constants.kPadding, width: Constants.kBottomWidth, height: 30))
                    qualityView.tag = index+1
                    qualityView.depth = .Depth1
                    qualityView.backgroundColor = MaterialColor.white
                    qualityView.pulseScale = false
                    
                    let qualityLabel = UILabel()
                    qualityLabel.text = quality
                    qualityLabel.frame = CGRect(x: Constants.kPadding, y: 3, width: 120, height: 25)
                    
                    let cosmosView = CosmosView(frame: CGRect(x: Constants.kBottomWidth - 140, y: 3, width: 140, height: 25))
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
    
    func animateStarsToGold() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .Ratings)
            .on(next: { ratings in
                let viewArray: [MaterialPulseView] = self.view.subviews.sort({ $0.tag < $1.tag }) as! [MaterialPulseView]
                for (index, subview) in viewArray.enumerate() {
                    subview.pulseScale = true
                    subview.pulse()
                    let stars = subview.subviews.filter({ $0 is CosmosView })
                    let cosmos: CosmosView = stars.first as! CosmosView
                    cosmos.settings.userRatingMode = false
                    cosmos.rating = ratings[ratings[index]] as! Double
                    cosmos.update()
                }
            })
            .start()
    }
}