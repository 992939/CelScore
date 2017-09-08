//
//  RatingsViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/1/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material
import SwiftyTimer
import ReactiveCocoa
import ReactiveSwift
import Result


final class RatingsViewController: ASViewController<ASDisplayNode>, Labelable {
    
    //MARK: Properties
    fileprivate let celebST: CelebrityStruct
    fileprivate let pulseView: View
    internal var delegate: DetailSubViewable?
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.pulseView = View(frame: Constants.kBottomViewRect)
        super.init(node: ASDisplayNode())
        self.view.isHidden = true
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pulseView.backgroundColor = Color.clear
        self.setupStars()
        self.view = self.pulseView
    }
    
    func setupStars() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .ratings)
            .flatMapError { error -> SignalProducer<RatingsModel, NoError> in return .empty }
            .startWithValues({ ratings in
                for (index, quality) in Qualities.getAll(isMale: self.celebST.sex).enumerated() {
                    let barHeight = UIDevice.getPulseBarHeight()
                    let qualityView = PulseView(frame: CGRect(x: 0, y: CGFloat(index) * (Constants.kBottomHeight / 10) + Constants.kPadding, width: Constants.kMaxWidth, height: barHeight))
                    qualityView.tag = index+1
                    qualityView.depthPreset = .depth2
                    qualityView.layer.cornerRadius = 5.0
                    qualityView.backgroundColor = Constants.kGreyBackground
                    if ratings.totalVotes > 1 && ratings.getMax() == ratings[index] { qualityView.backgroundColor = Color.blue.lighten4 }
                    else if ratings.totalVotes > 1 && ratings.getMin() == ratings[index] { qualityView.backgroundColor = Color.red.lighten4 }
                    qualityView.pulseAnimation = .centerWithBacking
                    let qualityLabel : UILabel = self.setupLabel(title: quality, frame: CGRect(x: Constants.kPadding, y: 3, width: 120, height: barHeight - 5))
                    qualityLabel.backgroundColor = UIColor.clear
                    let cosmosView = CosmosView(frame: CGRect(x: Constants.kMaxWidth - UIDevice.getStarsWidth() + 5, y: 3, width: UIDevice.getStarsWidth(), height: barHeight - 5))
                    cosmosView.tag = index
                    switch quality {
                    case Qualities.talent.name(): cosmosView.rating = ratings.rating1
                    case Qualities.originality.name(): cosmosView.rating = ratings.rating2
                    case Qualities.authenticity.name(): cosmosView.rating = ratings.rating3
                    case Qualities.generosity.name(): cosmosView.rating = ratings.rating4
                    case Qualities.roleModel.name(): cosmosView.rating = ratings.rating5
                    case Qualities.hardWork.name(): cosmosView.rating = ratings.rating6
                    case Qualities.smarts.name(): cosmosView.rating = ratings.rating7
                    case Qualities.elegance.name(): cosmosView.rating = ratings.rating8
                    case Qualities.charisma.name() : cosmosView.rating = ratings.rating9
                    case Qualities.sexAppeal.name(): cosmosView.rating = ratings.rating10
                    default: cosmosView.rating = 3 }
                    cosmosView.settings.starSize = Double(barHeight) - 8
                    cosmosView.settings.starMargin = 5
                    cosmosView.settings.previousRating = Int(cosmosView.rating)
                    cosmosView.settings.updateOnTouch = false
                    cosmosView.settings.userRatingMode = false

                    SettingsViewModel().loggedInAsSignal()
                        .on(value: { _ in cosmosView.settings.updateOnTouch = true })
                        .flatMap(.latest){ (_) -> SignalProducer<Bool, NoError> in
                            return RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id) }
                        .flatMapError { error -> SignalProducer<Bool, NoError> in return .empty }
                        .map { hasRatings in
                            cosmosView.settings.colorFilled = hasRatings ? Constants.kStarGoldShade : Constants.kStarGreyShade
                            cosmosView.settings.borderColorEmpty = Constants.kStarGreyShade
                            cosmosView.settings.updateOnTouch = hasRatings ? false : true }
                        .start()
                    
                    cosmosView.didTouchCosmos = { (rating:Double) in
                        SettingsViewModel().loggedInAsSignal()
                            .observe(on: UIScheduler())
                            .on(failed: { _ in self.requestLogin() })
                            .flatMapError { _ in SignalProducer.empty }
                            .flatMap(.latest){ (_) -> SignalProducer<Bool, NoError> in
                                return RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id) }
                            .filter{ hasUserRatings in
                                if hasUserRatings == false {
                                    cosmosView.settings.userRatingMode = true
                                    cosmosView.settings.updateOnTouch = true
                                    cosmosView.update()
                                }
                                return cosmosView.settings.userRatingMode == true }
                            .flatMapError { _ in SignalProducer.empty }
                            .flatMap(.latest) { (_) -> SignalProducer<RatingsModel, RatingsError> in
                                return RatingsViewModel().updateUserRatingSignal(ratingsId: self.celebST.id, ratingIndex: cosmosView.tag, newRating: Int(rating))}
                            .map { userRatings in
                                cosmosView.settings.updateOnTouch = true
                                cosmosView.settings.userRatingMode = true
                                let unrated = userRatings.filter{ (userRatings[$0] as! Int) == 0 }
                                if unrated.isEmpty { self.delegate!.updateVoteButton(positive: userRatings.getCelScore() < 80 ? false : true) }}
                            .start()
                    }
                    qualityView.addSubview(qualityLabel)
                    qualityView.addSubview(cosmosView)
                    self.pulseView.addSubview(qualityView)
                }
            })
    }
    
    func requestLogin() {
        Motion.delay(0.5) { TAOverlay.show(withLabel: OverlayInfo.firstVoteDisable.message(), image: OverlayInfo.firstVoteDisable.logo(), options: OverlayInfo.getOptions()) }
        TAOverlay.setCompletionBlock({ _ in self.delegate!.handleMenu(open: true) })
    }
    
    func isUserRatingMode() -> Bool {
        let materialView: PulseView = self.view.subviews.first as! PulseView
        let stars = materialView.subviews.filter({ $0 is CosmosView })
        let cosmos: CosmosView = stars.first as! CosmosView
        return cosmos.settings.userRatingMode
    }
    
    func animateStarsToGold() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .ratings)
            .on(value: { ratings in
                let viewArray: [PulseView] = self.view.subviews.sorted(by: { $0.tag < $1.tag }) as! [PulseView]
                for (index, subview) in viewArray.enumerated() {
                    Timer.after(100.ms * Double(index)){ timer in
                        subview.pulse()
                        let stars = subview.subviews.filter({ $0 is CosmosView })
                        let cosmos: CosmosView = stars.first as! CosmosView
                        cosmos.settings.colorFilled = Constants.kStarGoldShade
                        cosmos.settings.borderColorEmpty = Constants.kStarGreyShade
                        cosmos.settings.userRatingMode = false
                        cosmos.settings.updateOnTouch = false
                        cosmos.rating = ratings[ratings[index]] as! Double
                        cosmos.update()
                    }
                }
            }).start()
    }
    
    func displayRatings(_ userRatings: RatingsModel = RatingsModel()) {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .ratings)
            .on(value: { ratings in
                let viewArray: [PulseView] = self.view.subviews.sorted(by: { $0.tag < $1.tag }) as! [PulseView]
                for (index, subview) in viewArray.enumerated() {
                    let stars = subview.subviews.filter({ $0 is CosmosView })
                    let cosmos: CosmosView = stars.first as! CosmosView
                    cosmos.settings.colorFilled = userRatings.getCelScore() > 0 ? Constants.kStarGoldShade : Constants.kStarGreyShade
                    cosmos.settings.borderColorEmpty = Constants.kStarGreyShade
                    cosmos.settings.updateOnTouch = userRatings.getCelScore() > 0 ? false : true
                    cosmos.settings.userRatingMode = false
                    cosmos.rating = ratings[ratings[index]] as! Double
                    cosmos.update()
                }
            }).start()
    }
    
    func displayUserRatings(_ userRatings: RatingsModel) {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .ratings)
            .on(value: { ratings in
                let viewArray: [PulseView] = self.view.subviews.sorted(by: { $0.tag < $1.tag }) as! [PulseView]
                for (index, subview) in viewArray.enumerated() {
                    Timer.after(100.ms * Double(index)){ timer in
                        subview.pulse()
                        let stars = subview.subviews.filter({ $0 is CosmosView })
                        let cosmos: CosmosView = stars.first as! CosmosView
                        cosmos.settings.updateOnTouch = true
                        cosmos.settings.userRatingMode = true
                        cosmos.settings.borderColorEmpty = Constants.kStarGreyShade
                        cosmos.rating = userRatings[userRatings[index]] as! Double
                        cosmos.update()
                    }
                }
            }).start()
    }
}
