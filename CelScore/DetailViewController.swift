//
//  DetailViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/2/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material
import SMSegmentView
import AIRTimer
import Social
import PMAlertController
import ReactiveCocoa


struct UserStruct {
    let socialMessage: String
    let isPositive: Bool
    func updateMessage(message: String) -> UserStruct { return UserStruct(socialMessage: message, isPositive: isPositive) }
    func updatePositive(positive: Bool) -> UserStruct { return UserStruct(socialMessage: socialMessage, isPositive: positive) }
}


final class DetailViewController: UIViewController, SMSegmentViewDelegate, DetailSubViewable, Sociable, Labelable {
    
    //MARK: Properties
    private let infoVC: InfoViewController
    private let ratingsVC: RatingsViewController
    private let celscoreVC: CelScoreViewController
    private let voteButton: MaterialButton
    private let celebST: CelebrityStruct
    internal let profilePicNode: ASNetworkImageNode
    internal let socialButton: MenuView
    private var userST = UserStruct(socialMessage: "", isPositive: true)
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.infoVC = InfoViewController(celebrityST: self.celebST)
        self.ratingsVC = RatingsViewController(celebrityST: self.celebST)
        self.celscoreVC = CelScoreViewController(celebrityST: self.celebST)
        self.voteButton = MaterialButton()
        self.socialButton = MenuView()
        self.profilePicNode = ASNetworkImageNode(webImage: ())
        super.init(nibName: nil, bundle: nil)

        SettingsViewModel().isPositiveVoteSignal()
            .on(next: { value in self.userST = self.userST.updatePositive(value) })
            .filter({ (value: Bool) -> Bool in value == false })
            .promoteErrors(NSError)
            .flatMap(.Latest) { (value: Bool) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .FirstNegative) }
            .on(next: { first in let firstTime = first as! Bool
                if firstTime  {
                TAOverlay.showOverlayWithLabel(OverlayInfo.FirstNegative.message(), image: OverlayInfo.FirstNegative.logo(), options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstNegative).start() })
                }})
            .start()
        
        CelebrityViewModel().updateUserActivitySignal(id: self.celebST.id)
            .startOn(QueueScheduler())
            .observeOn(UIScheduler())
            .startWithNext({ activity in self.userActivity = activity })
        
        RatingsViewModel().cleanUpRatingsSignal(ratingsId: self.celebST.id).start()
    }
    
    //MARK: Methods
    override func prefersStatusBarHidden() -> Bool { return true }
    override func updateUserActivityState(activity: NSUserActivity) {}

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingsVC.delegate = self
        self.infoVC.delegate = self
        self.celscoreVC.delegate = self
        
        let navigationBarView: Toolbar = getNavigationView()
        let topView: MaterialView = getTopView()
        let segmentView: SMSegmentView = getSegmentView()
        self.setUpVoteButton()
        self.setUpSocialButton(self.socialButton, controller: self, origin: CGPoint(x: -100, y: Constants.kTopViewRect.bottom - 35), buttonColor: Constants.kStarRatingShade)
        
        self.socialButton.menu.enabled = false
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        SettingsViewModel().getSettingSignal(settingType: .PublicService)
            .observeOn(UIScheduler())
            .startWithNext({ status in
                if (status as! Bool) == true {
                    first?.setImage(R.image.ic_add_black()!, forState: .Normal)
                    first?.setImage(R.image.ic_add_black()!, forState: .Highlighted)
                } else {
                    first?.setImage(R.image.cross()!, forState: .Normal)
                    first?.setImage(R.image.cross()!, forState: .Highlighted)
                }
            })
        
        let statusView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 20))
        statusView.backgroundColor = Constants.kDarkShade
        
        self.profilePicNode.URL = NSURL(string: celebST.imageURL)
        self.profilePicNode.frame = CGRect(x: self.view.centerX - UIDevice.getProfileDiameter()/2,
                                           y: topView.centerY - UIDevice.getProfileDiameter()/2,
                                           width: UIDevice.getProfileDiameter(),
                                           height: UIDevice.getProfileDiameter())
        self.profilePicNode.cornerRadius = UIDevice.getProfileDiameter()/2
        topView.clipsToBounds = false

        self.view.addSubview(statusView)
        self.view.addSubview(navigationBarView)
        self.view.sendSubviewToBack(navigationBarView)
        self.view.addSubview(topView)
        self.view.addSubview(segmentView)
        self.view.addSubview(self.socialButton)
        MaterialLayout.size(self.view, child: self.socialButton, width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        self.view.addSubview(self.voteButton)
        self.view.addSubview(self.profilePicNode.view)
        self.view.addSubview(self.infoVC.view)
        self.view.addSubview(self.ratingsVC.view)
        self.view.addSubview(self.celscoreVC.view)
        self.view.backgroundColor = Constants.kDarkShade
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showingButtons()
    }
    
    func showingButtons() {
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        first!.animate(MaterialAnimation.animationGroup([
            MaterialAnimation.rotate(rotation: 3),
            MaterialAnimation.translateX(Constants.kPadding + 100)
            ]))
        
        self.voteButton.animate(MaterialAnimation.animationGroup([
            MaterialAnimation.rotate(rotation: 3),
            MaterialAnimation.translateX(-(Constants.kFabDiameter + 100))
            ]))
        
        for subview in self.socialButton.menu.views!.enumerate() {
            if subview.element.tag == 1 || subview.element.tag == 2 {
                subview.element.frame.offsetInPlace(dx: Constants.kPadding + 100, dy: 0)
            }
        }
    }
    
    func hideButtons() {
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        first!.animate(MaterialAnimation.animationGroup([
            MaterialAnimation.rotate(rotation: 3),
            MaterialAnimation.translateX(-(Constants.kPadding + 100))
            ]))
        
        self.voteButton.animate(MaterialAnimation.animationGroup([
            MaterialAnimation.rotate(rotation: 3),
            MaterialAnimation.translateX(Constants.kFabDiameter + 100)
            ]))
    }
    
    func backAction() {
        self.hideButtons()
        MaterialAnimation.delay(0.15) {
            RatingsViewModel().cleanUpRatingsSignal(ratingsId: self.celebST.id).startWithCompleted { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func voteAction() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings)
            .filter({ (ratings: RatingsModel) -> Bool in return ratings.filter{ (ratings[$0] as! Int) == 0 }.isEmpty })
            .flatMap(.Latest) { (ratings: RatingsModel) -> SignalProducer<RatingsModel, RatingsError> in
                return RatingsViewModel().voteSignal(ratingsId: self.celebST.id) }
            .observeOn(UIScheduler())
            .on(next: { (userRatings:RatingsModel) in
                self.enableUpdateButton()
                self.rippleEffect(positive: false, gold: true)
                self.ratingsVC.animateStarsToGold(positive: userRatings.getCelScore() < 3 ? false : true)
                MaterialAnimation.delay(2.5) {
                    self.voteButton.backgroundColor = Constants.kStarRatingShade
                    self.voteButton.setImage(R.image.heart_black()!, forState: .Normal)
                    self.voteButton.setImage(R.image.heart_black()!, forState: .Highlighted)
                }})
            .delay(2.1, onScheduler: QueueScheduler.mainQueueScheduler)
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .ConsensusBuilding)}
            .filter({ (value: AnyObject) -> Bool in let isConsensus = value as! Bool
                if isConsensus == false {
                    TAOverlay.showOverlayWithLabel("Thank you for voting!", image: R.image.mic_green(), options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in self.trollAction() })
                }
                return isConsensus })
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (value: AnyObject) -> SignalProducer<String, RatingsError> in
                return RatingsViewModel().consensusBuildingSignal(ratingsId: self.celebST.id)}
            .on(next: { message in
                TAOverlay.showOverlayWithLabel(message, image: R.image.sphere_green(), options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in self.trollAction() })
            })
            .start()
    }
    
    func trollAction() {
        MaterialAnimation.delay(0.5) {
            SettingsViewModel().calculateUserAverageCelScoreSignal()
                .filter({ (score:CGFloat) -> Bool in return score < Constants.kTrollingWarning })
                .flatMapError { _ in SignalProducer.empty }
                .flatMap(.Latest) { (score:CGFloat) -> SignalProducer<AnyObject, NSError> in
                    return SettingsViewModel().getSettingSignal(settingType: .FirstTrollWarning) }
                .on(next: { first in let firstTime = first as! Bool
                    if firstTime {
                        TAOverlay.showOverlayWithLabel(OverlayInfo.FirstTrollWarning.message(), image: OverlayInfo.FirstTrollWarning.logo(), options: OverlayInfo.getOptions())
                        TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstTrollWarning).start() })
                    }})
                .start()
        }
    }
    
    func updateAction() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings)
            .observeOn(UIScheduler())
            .startWithNext({ (userRatings:RatingsModel) in
                self.rippleEffect(positive: false, gold: true)
                self.enableVoteButton(positive: userRatings.getCelScore() < 3.0 ? false : true)
                self.ratingsVC.displayUserRatings(userRatings)
            })
    }
    
    func imageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: UIDevice.getProfileDiameter() + 20, height: Constants.kTopViewRect.height), false, 2)
        UIGraphicsGetImageFromCurrentImageContext()
        let newX: CGFloat = UIDevice.getScreenshotPosition()
        self.view.drawViewHierarchyInRect(CGRect(x: -newX, y: -Constants.kNavigationBarRect.height, width: self.view.width, height: self.view.height), afterScreenUpdates: true)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenShot
    }
    
    //MARK: Sociable
    func handleMenu(open: Bool = false) {
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        if open {
            self.socialButton.menu.enabled = true
            first?.backgroundColor = self.userST.isPositive ? Constants.kDarkGreenShade : Constants.kWineShade
            first?.pulseAnimation = .CenterWithBacking
            first?.pulse()
            first?.animate(MaterialAnimation.rotate(rotation: 1))
            self.socialButton.menu.open()
            let image = R.image.ic_close_white()?.imageWithRenderingMode(.AlwaysTemplate)
            first?.setImage(image, forState: .Normal)
            first?.setImage(image, forState: .Highlighted)
        } else if self.socialButton.menu.opened {
            first?.animate(MaterialAnimation.rotate(rotation: 1))
            self.socialButton.menu.close()
            self.socialButton.menu.enabled = false
            first?.backgroundColor = Constants.kStarRatingShade
            SettingsViewModel().getSettingSignal(settingType: .PublicService)
                .observeOn(UIScheduler())
                .startWithNext({ status in
                    if (status as! Bool) == true {
                        first?.setImage(R.image.ic_add_black()!, forState: .Normal)
                        first?.setImage(R.image.ic_add_black()!, forState: .Highlighted)
                    } else {
                        first?.setImage(R.image.cross()!, forState: .Normal)
                        first?.setImage(R.image.cross()!, forState: .Highlighted)
                    }
                })
        }
    }
    
    func socialButton(button: UIButton) {
        SettingsViewModel().loggedInAsSignal()
            .on(next: { _ in
                let screenshot: UIImage = self.imageFromView(self.profilePicNode.view.snapshotViewAfterScreenUpdates(true))
                CelScoreViewModel().shareVoteOnSignal(socialLogin: (button.tag == 1 ? .Facebook: .Twitter), message: self.userST.socialMessage, screenshot: screenshot).startWithNext { socialVC in
                    let isFacebookAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
                    let isTwitterAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
                    guard (button.tag == 1 ? isFacebookAvailable : isTwitterAvailable) == true else {
                        TAOverlay.showOverlayWithLabel(SocialLogin(rawValue: button.tag)!.serviceUnavailable(),
                            image: OverlayInfo.LoginError.logo(), options: OverlayInfo.getOptions())
                        return }
                    self.presentViewController(socialVC, animated: true, completion: { MaterialAnimation.delay(2.0) { self.handleMenu() }})
                }})
            .on(failed: { _ in self.socialButtonTapped(buttonTag: button.tag, from: self, hideButton: false) })
            .start()
    }
    
    func socialRefresh() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings)
            .observeOn(UIScheduler())
            .on(next: { userRatings in
                self.ratingsVC.displayGoldRatings(userRatings)
                guard userRatings.getCelScore() > 0 else { return }
                self.enableUpdateButton()
                self.voteButton.backgroundColor = Constants.kStarRatingShade
                self.voteButton.setImage(R.image.heart_black()!, forState: .Normal)
                self.voteButton.setImage(R.image.heart_black()!, forState: .Highlighted)
            })
            .on(failed: { _ in self.ratingsVC.displayGoldRatings() })
            .start()
    }
    
    func sendNetworkAlert() {
        self.dismissHUD()
        let alertVC = PMAlertController(title: "ooops!", description: OverlayInfo.TimeoutError.message(), image: OverlayInfo.TimeoutError.logo(), style: .Alert)
        alertVC.addAction(PMAlertAction(title: "Ok", style: .Cancel, action: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
        alertVC.addAction(PMAlertAction(title: "Contact Us", style: .Default, action: { _ in self.dismissViewControllerAnimated(true, completion: nil) }))
        
        alertVC.view.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.7)
        alertVC.view.opaque = false
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func enableUpdateButton() {
        self.voteButton.enabled = true
        self.voteButton.pulseAnimation = .CenterWithBacking
        self.voteButton.backgroundColor = Constants.kStarRatingShade
        self.voteButton.setImage(R.image.heart_black()!, forState: .Normal)
        self.voteButton.setImage(R.image.heart_black()!, forState: .Highlighted)
        self.voteButton.removeTarget(self, action: #selector(DetailViewController.voteAction), forControlEvents: .TouchUpInside)
        self.voteButton.addTarget(self, action: #selector(DetailViewController.updateAction), forControlEvents: .TouchUpInside)
    }
    
    func disableButton(button button: MaterialButton, image: UIImage) {
        button.enabled = false
        button.backgroundColor = Constants.kDarkShade
        button.setImage(image, forState: .Normal)
        button.setImage(image, forState: .Highlighted)
    }
    
    //MARK: SMSegmentViewDelegate
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int, previousIndex: Int) {
        let infoView: UIView = self.getSubView(atIndex: index)
        infoView.hidden = false
        infoView.frame = Constants.kBottomViewRect
        let removingView = self.getSubView(atIndex: previousIndex)
        
        if index == 0 || (index == 1 && previousIndex == 2 ){ self.slide(right: false, newView: infoView, oldView: removingView) }
        else { self.slide(right: true, newView: infoView, oldView: removingView) }
        self.handleMenu()
        
        if index == 2 {
            RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings).startWithNext({ userRatings in
                guard userRatings.getCelScore() > 0 else { return }
                if self.ratingsVC.isUserRatingMode() { self.enableVoteButton(positive: userRatings.getCelScore() < 3.0 ? false : true) }
                else { self.enableUpdateButton() }
            })
        } else { self.disableButton(button: self.voteButton, image: self.userST.isPositive ? R.image.heart_green()! : R.image.heart_purple()!) }
    }
    
    func slide(right right: Bool, newView: UIView, oldView: UIView) {
        UIView.animateWithDuration(1.0, animations: { _ in
            if right { oldView.left = -newView.width; newView.slide(right: true, duration: 1.0, completionDelegate: self) }
            else { oldView.left = newView.width + 45; newView.slide(right: false, duration: 1.0, completionDelegate: self) }
        })
    }
    
    func getSubView(atIndex index: Int) -> UIView {
        let subview: UIView
        switch index {
        case 1: subview = self.infoVC.view
        case 2: subview = self.ratingsVC.view
        default: subview = self.celscoreVC.view
        }
        return subview
    }
    
    //MARK: RatingsViewDelegate
    func rippleEffect(positive positive: Bool, gold: Bool = false) {
        if gold { self.profilePicNode.view.rippleColor = Constants.kStarRatingShade }
        else { self.profilePicNode.view.rippleColor = positive ? Constants.kLightGreenShade : Constants.kWineShade }
        self.profilePicNode.view.rippleTrailColor = MaterialColor.clear
        self.profilePicNode.view.dya_ripple(self.profilePicNode.view.bounds.center)
    }
    
    func enableVoteButton(positive positive: Bool) {
        UIView.animateWithDuration(0.3, animations: {
            self.voteButton.enabled = true
            self.voteButton.setImage(R.image.heart_white()!, forState: .Normal)
            self.voteButton.setImage(R.image.heart_white()!, forState: .Highlighted)
            self.voteButton.removeTarget(self, action: #selector(DetailViewController.updateAction), forControlEvents: .TouchUpInside)
            self.voteButton.addTarget(self, action: #selector(DetailViewController.voteAction), forControlEvents: .TouchUpInside)
            self.voteButton.backgroundColor = positive == true ? Constants.kDarkGreenShade : Constants.kWineShade },
            completion: { _ in MaterialAnimation.delay(2) {
                self.voteButton.pulseAnimation = .CenterWithBacking
                self.voteButton.pulse() }
        })
    }

    func socialSharing(message message: String) {
        self.handleMenu(true)
        self.userST = self.userST.updateMessage(message)
    }
    
    //MARK: ViewDidLoad Helpers
    func getNavigationView() -> Toolbar {
        let backButton: FlatButton = FlatButton()
        backButton.pulseColor = MaterialColor.white
        backButton.pulseAnimation = .None
        backButton.setImage(R.image.arrow_white()!, forState: .Normal)
        backButton.setImage(R.image.arrow_white()!, forState: .Highlighted)
        backButton.addTarget(self, action: #selector(DetailViewController.backAction), forControlEvents: .TouchUpInside)
        
        let nameLabel: UILabel = self.setupLabel(title: self.celebST.nickname, frame: CGRect(x: 40, y: 28, width: Constants.kScreenWidth - 80, height: 30))
        nameLabel.textAlignment = .Center
        self.view.addSubview(nameLabel)
        
        let navigationBarView: Toolbar = Toolbar()
        navigationBarView.frame = Constants.kDetailNavigationBarRect
        navigationBarView.leftControls = [backButton]
        navigationBarView.depth = .Depth3
        navigationBarView.backgroundColor = Constants.kMainShade
        navigationBarView.contentMode = .ScaleAspectFit
        return navigationBarView
    }
    
    func getTopView() -> MaterialView {
        let topView: MaterialView = MaterialView(frame: Constants.kTopViewRect)
        topView.depth = .Depth2
        topView.backgroundColor = Constants.kDarkShade
        topView.opaque = true
        topView.image = R.image.topView()
        return topView
    }
    
    func getSegmentView() -> SMSegmentView {
        let segmentView: SMSegmentView = SMSegmentView(frame: Constants.kSegmentViewRect,
            separatorColour: MaterialColor.black, separatorWidth: 1,
            segmentProperties:[keySegmentTitleFont: UIFont.systemFontOfSize(12),
                keySegmentOnSelectionColour: Constants.kMainShade,
                keySegmentOffSelectionColour: Constants.kDarkShade,
                keyContentVerticalMargin: 5])
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.celscore_white()!, offSelectionImage: R.image.celscore_black()!)
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.info_white()!, offSelectionImage: R.image.info_black()!)
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.star_icon()!, offSelectionImage: R.image.star_black()!)
        segmentView.selectSegmentAtIndex(0)
        segmentView.clipsToBounds = false
        segmentView.layer.shadowColor = MaterialColor.black.CGColor
        segmentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        segmentView.layer.shadowOpacity = 0.3
        segmentView.delegate = self
        return segmentView
    }
    
    func setUpVoteButton() {
        let diameter: CGFloat = Constants.kFabDiameter
        self.voteButton.frame = CGRect(x: Constants.kMaxWidth + 100, y: Constants.kTopViewRect.bottom - 35, width: diameter, height: diameter)
        self.voteButton.shape = .Circle
        self.voteButton.depth = .Depth2
        self.voteButton.pulseAnimation = .None
        self.voteButton.tintColor = MaterialColor.white
        self.disableButton(button: self.voteButton, image: self.userST.isPositive ? R.image.heart_green()! : R.image.heart_purple()!)
    }
}




