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
import Social
import ReactiveCocoa
import ReactiveSwift
import MessageUI
import Material


final class DetailViewController: UIViewController, SMSegmentViewDelegate, DetailSubViewable, Sociable, Labelable, MFMailComposeViewControllerDelegate {
    
    //MARK: Properties
    fileprivate let infoVC: InfoViewController
    fileprivate let ratingsVC: RatingsViewController
    fileprivate let celscoreVC: CelScoreViewController
    fileprivate let voteButton: Button
    fileprivate let celebST: CelebrityStruct
    fileprivate let socialButton: View
    fileprivate var socialMessage: String = ""
    internal let profilePicNode: ASNetworkImageNode
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.infoVC = InfoViewController(celebrityST: self.celebST)
        self.ratingsVC = RatingsViewController(celebrityST: self.celebST)
        self.celscoreVC = CelScoreViewController(celebrityST: self.celebST)
        self.voteButton = Button()
        self.socialButton = View()
        self.profilePicNode = ASNetworkImageNode(webImage: ())
        super.init(nibName: nil, bundle: nil)
        
        CelebrityViewModel().updateUserActivitySignal(id: self.celebST.id)
            .startOn(QueueScheduler())
            .observeOn(UIScheduler())
            .startWithNext({ activity in self.userActivity = activity })
        
        RatingsViewModel().cleanUpRatingsSignal(ratingsId: self.celebST.id).start()
    }
    
    //MARK: Methods
    override var prefersStatusBarHidden : Bool { return true }
    override func updateUserActivityState(_ activity: NSUserActivity) {}

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingsVC.delegate = self
        self.infoVC.delegate = self
        self.celscoreVC.delegate = self
        
        let navigationBarView: Toolbar = getNavigationView()
        let topView: View = getTopView()
        let segmentView: SMSegmentView = getSegmentView()
        self.setUpVoteButton()
        self.setUpSocialButton(self.socialButton, controller: self, origin: CGPoint(x: -100, y: Constants.kTopViewRect.bottom - 35), buttonColor: Constants.kStarGoldShade)
        let first: Button? = self.socialButton.menu.views?.first as? Button
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
        
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id).startWithNext({ hasRatings in
            first?.backgroundColor = hasRatings ? Constants.kStarGoldShade : Constants.kGreyBackground
        })
        
        let statusView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 20))
        statusView.backgroundColor = Constants.kBlueShade
        
        self.profilePicNode.url = URL(string: celebST.imageURL)
        self.profilePicNode.frame = CGRect(x: self.view.centerX - UIDevice.getProfileDiameter()/2,
                                           y: topView.centerY - UIDevice.getProfileDiameter()/2,
                                           width: UIDevice.getProfileDiameter(),
                                           height: UIDevice.getProfileDiameter())
        self.profilePicNode.cornerRadius = UIDevice.getProfileDiameter()/2
        topView.clipsToBounds = false

        self.view.addSubview(statusView)
        self.view.addSubview(navigationBarView)
        self.view.sendSubview(toBack: navigationBarView)
        self.view.addSubview(topView)
        self.view.addSubview(segmentView)
        self.view.addSubview(self.socialButton)
        Layout.size(self.view, child: self.socialButton, width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        self.view.addSubview(self.voteButton)
        self.view.addSubview(self.profilePicNode.view)
        self.view.addSubview(self.infoVC.view)
        self.view.addSubview(self.ratingsVC.view)
        self.view.addSubview(self.celscoreVC.view)
        self.view.backgroundColor = Constants.kBlueShade
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showingButtons()
    }
    
    func showingButtons() {
        let first: Button? = self.socialButton.menu.views?.first as? Button
        first!.animate(animation: Animation.animationGroup(animations: [
            Animation.rotate(rotation: 3),
            Animation.translateX(translation: Constants.kPadding + 100)
            ]))
        
        self.voteButton.animate(animation: Animation.animationGroup(animations: [
            Animation.rotate(rotation: 3),
            Animation.translateX(translation: -(Constants.kFabDiameter + 100))
            ]))
        
        for subview in self.socialButton.menu.views!.enumerate() {
            if subview.element.tag == 1 || subview.element.tag == 2 {
                subview.element.frame.offsetInPlace(dx: Constants.kPadding + 100, dy: 0)
            }
        }
    }
    
    func hideButtons() {
        let first: Button? = self.socialButton.menu.views?.first as? Button
        first!.animate(animation: Animation.animationGroup(animations: [
            Animation.rotate(rotation: 3),
            Animation.translateX(translation: -(Constants.kPadding + 100))
            ]))
        
        self.voteButton.animate(animation: Animation.animationGroup(animations: [
            Animation.rotate(rotation: 3),
            Animation.translateX(translation: Constants.kFabDiameter + 100)
            ]))
    }
    
    func backAction() {
        self.hideButtons()
        RatingsViewModel().cleanUpRatingsSignal(ratingsId: self.celebST.id).start()
        Animation.delay(time: 0.15){ self.dismiss(animated: true, completion: nil) }
    }
    
    func infoAction() {
       TAOverlay.show(withLabel: OverlayInfo.infoSource.message(), image: OverlayInfo.infoSource.logo(), options: OverlayInfo.getOptions())
    }
    
    func helpAction() {
        TAOverlay.show(withLabel: OverlayInfo.voteHelp.message(), image: OverlayInfo.voteHelp.logo(), options: OverlayInfo.getOptions())
    }
    
    func voteAction() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings)
            .filter({ (ratings: RatingsModel) -> Bool in return ratings.filter{ (ratings[$0] as! Int) == 0 }.isEmpty })
            .flatMap(.Latest) { (ratings: RatingsModel) -> SignalProducer<RatingsModel, RatingsError> in
                return RatingsViewModel().voteSignal(ratingsId: self.celebST.id) }
            .observeOn(UIScheduler())
            .on(next: { (userRatings:RatingsModel) in
                let first: Button? = self.socialButton.menu.views?.first as? Button
                first?.backgroundColor = Constants.kStarGoldShade
                self.enableUpdateButton()
                self.rippleEffect(positive: false, gold: true)
                self.ratingsVC.animateStarsToGold(positive: userRatings.getCelScore() < 3 ? false : true)
                Animation.delay(2.5) {
                    self.voteButton.backgroundColor = Constants.kStarGoldShade
                    self.voteButton.setImage(R.image.heart_black()!, forState: .Normal)
                    self.voteButton.setImage(R.image.heart_black()!, forState: .Highlighted)
                }})
            .delay(2.1, onScheduler: QueueScheduler.mainQueueScheduler)
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .ConsensusBuilding)}
            .filter({ (value: AnyObject) -> Bool in let isConsensus = value as! Bool
                if isConsensus == false {
                    SettingsViewModel().calculateUserRatingsPercentageSignal().startWithNext { value in
                        if value > 99.0 { TAOverlay.showOverlayWithLabel("Thank you for voting!", image: R.image.mic_yellow(), options: OverlayInfo.getOptions()) }
                        else { TAOverlay.showOverlayWithLabel("Thank you for voting!", image: R.image.mic_red(), options: OverlayInfo.getOptions()) }
                        TAOverlay.setCompletionBlock({ _ in self.trollAction() })
                    }
                }
                return isConsensus })
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (value: AnyObject) -> SignalProducer<String, RatingsError> in
                return RatingsViewModel().consensusBuildingSignal(ratingsId: self.celebST.id)}
            .on(next: { message in
                SettingsViewModel().calculateUserRatingsPercentageSignal().startWithNext { value in
                    if value > 99.0 { TAOverlay.showOverlayWithLabel(message, image: R.image.sphere_yellow(), options: OverlayInfo.getOptions()) }
                    else { TAOverlay.showOverlayWithLabel(message, image: R.image.sphere_blue(), options: OverlayInfo.getOptions()) }
                    TAOverlay.setCompletionBlock({ _ in self.trollAction() })
                }
            })
            .start()
    }
    
    func trollAction() {
        Animation.delay(time: 0.5) {
            SettingsViewModel().calculateUserAverageCelScoreSignal()
                .filter({ (score:CGFloat) -> Bool in
                    if score > Constants.kTrollingWarning { self.progressAction() }
                    return score < Constants.kTrollingWarning })
                .flatMapError { _ in SignalProducer.empty }
                .flatMap(.Latest) { (score:CGFloat) -> SignalProducer<AnyObject, NSError> in
                    return SettingsViewModel().getSettingSignal(settingType: .FirstTrollWarning) }
                .on(next: { first in let firstTime = first as! Bool
                    guard firstTime else { return }
                    TAOverlay.showOverlayWithLabel(OverlayInfo.FirstTrollWarning.message(), image: OverlayInfo.FirstTrollWarning.logo(), options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstTrollWarning).start() })
                    })
                .start()
        }
    }
    
    func progressAction() {
        SettingsViewModel().calculateUserRatingsPercentageSignal().startWithNext({ value in
            switch value * 100.0 {
            case 100.0:
                SettingsViewModel().getSettingSignal(settingType: .FirstCompleted).startWithNext({ first in let firstTime = first as! Bool
                    guard firstTime else { return }
                    TAOverlay.showOverlayWithLabel(OverlayInfo.FirstCompleted.message(), image: OverlayInfo.FirstCompleted.logo(), options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstCompleted).start() })
                })
            case 75.0..<100.0:
                SettingsViewModel().getSettingSignal(settingType: .First75).startWithNext({ first in let firstTime = first as! Bool
                    guard firstTime else { return }
                    TAOverlay.showOverlayWithLabel(OverlayInfo.First75.message(), image: OverlayInfo.First75.logo(), options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .First75).start() })
                })
            case 50.0..<75.0:
                SettingsViewModel().getSettingSignal(settingType: .First50).startWithNext({ first in let firstTime = first as! Bool
                    guard firstTime else { return }
                    TAOverlay.showOverlayWithLabel(OverlayInfo.First50.message(), image: OverlayInfo.First50.logo(), options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .First50).start() })
                })
            case 25.0..<50.0:
                SettingsViewModel().getSettingSignal(settingType: .First25).startWithNext({ first in let firstTime = first as! Bool
                    guard firstTime else { return }
                    TAOverlay.showOverlayWithLabel(OverlayInfo.First25.message(), image: OverlayInfo.First25.logo(), options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .First25).start() })
                })
            default: break
            }
        })
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
    
    func imageFromView(_ view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: UIDevice.getProfileDiameter() + 20, height: Constants.kTopViewRect.height), false, 2)
        UIGraphicsGetImageFromCurrentImageContext()
        let newX: CGFloat = UIDevice.getScreenshotPosition()
        self.view.drawHierarchy(in: CGRect(x: -newX, y: -Constants.kNavigationBarRect.height, width: self.view.width, height: self.view.height), afterScreenUpdates: true)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenShot!
    }
    
    //MARK: Sociable
    func handleMenu(_ open: Bool = false) {
        if open { self.openHandleMenu() }
        else if self.socialButton.menu.opened { self.closeHandleMenu() }
        else { TAOverlay.show(withLabel: OverlayInfo.noSharing.message(), image: OverlayInfo.noSharing.logo(), options: OverlayInfo.getOptions()) }
    }
    
    func openHandleMenu() {
        let first: Button? = self.socialButton.menu.views?.first as? Button
        first?.backgroundColor = Constants.kBlueShade
        first?.pulseAnimation = .centerWithBacking
        first?.animate(animation: Animation.rotate(rotation: 1))
        self.socialButton.menu.open()
        let image = R.image.ic_close_white()?.withRenderingMode(.alwaysTemplate)
        first?.setImage(image, forState: .Normal)
        first?.setImage(image, forState: .Highlighted)
    }
    
    func closeHandleMenu() {
       let first: Button? = self.socialButton.menu.views?.first as? Button
        if self.socialButton.menu.opened { first?.animate(Animation.rotate(rotation: 1)) }
        self.socialButton.menu.close()
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
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id).startWithNext({ hasRatings in
            first?.backgroundColor = hasRatings ? Constants.kStarGoldShade : Constants.kGreyBackground
        })
    }
    
    func socialButton(_ button: UIButton) {
        SettingsViewModel().loggedInAsSignal()
            .on(next: { _ in
                let screenshot: UIImage = self.imageFromView(self.profilePicNode.view.snapshotViewAfterScreenUpdates(true))
                CelScoreViewModel().shareVoteOnSignal(socialLogin: (button.tag == 1 ? .Facebook: .Twitter), message: self.socialMessage, screenshot: screenshot).startWithNext { socialVC in
                    let isFacebookAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
                    let isTwitterAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
                    guard (button.tag == 1 ? isFacebookAvailable : isTwitterAvailable) == true else {
                        TAOverlay.showOverlayWithLabel(SocialLogin(rawValue: button.tag)!.serviceUnavailable(),
                            image: OverlayInfo.LoginError.logo(), options: OverlayInfo.getOptions())
                        return }
                    self.presentViewController(socialVC, animated: true, completion: { Animation.delay(2.0) { self.socialButton.menu.close() }})
                }})
            .on(failed: { _ in self.socialButtonTapped(buttonTag: button.tag, hideButton: false) })
            .start()
    }
    
    func socialRefresh() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings)
            .observeOn(UIScheduler())
            .on(next: { userRatings in
                self.ratingsVC.displayRatings(userRatings)
                guard userRatings.getCelScore() > 0 else { return }
                self.enableUpdateButton()
                self.voteButton.backgroundColor = Constants.kStarGoldShade
                self.voteButton.setImage(R.image.heart_black()!, forState: .Normal)
                self.voteButton.setImage(R.image.heart_black()!, forState: .Highlighted)
            })
            .on(failed: { _ in self.ratingsVC.displayRatings() })
            .start()
    }
    
    func enableUpdateButton() {
        self.voteButton.pulseAnimation = .centerWithBacking
        self.voteButton.backgroundColor = Constants.kStarGoldShade
        self.voteButton.setImage(R.image.heart_black()!, for: .Normal)
        self.voteButton.setImage(R.image.heart_black()!, for: .Highlighted)
        self.voteButton.removeTarget(self, action: #selector(DetailViewController.voteAction), for: .touchUpInside)
        self.voteButton.addTarget(self, action: #selector(DetailViewController.updateAction), for: .touchUpInside)
        
        Animation.delay(time: 1) {
            self.voteButton.pulseAnimation = .centerWithBacking
            self.voteButton.pulse()
        }
    }

    func disableVoteButton(_ image: UIImage) {
        self.voteButton.setImage(image, for: .normal)
        self.voteButton.setImage(image, for: .highlighted)
        self.voteButton.removeTarget(self, action: nil, for: .touchUpInside)
        self.voteButton.addTarget(self, action: #selector(DetailViewController.helpAction), for: .touchUpInside)
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id).startWithNext({ hasRatings in
            self.voteButton.tintColor = hasRatings ? Constants.kStarGoldShade : Constants.kGreyBackground
            self.voteButton.backgroundColor = hasRatings ? Constants.kStarGoldShade : Constants.kGreyBackground
        })
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: SMSegmentViewDelegate
    func segmentView(_ segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int, previousIndex: Int) {
        let infoView: UIView = self.getSubView(atIndex: index)
        infoView.isHidden = false
        infoView.frame = Constants.kBottomViewRect
        let removingView = self.getSubView(atIndex: previousIndex)
        
        if index == 0 || (index == 1 && previousIndex == 2 ){ self.slide(right: false, newView: infoView, oldView: removingView) }
        else { self.slide(right: true, newView: infoView, oldView: removingView) }
        self.closeHandleMenu()
        
        if index == 2 {
            RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings).startWithNext({ userRatings in
                guard userRatings.getCelScore() > 0 else { return }
                if self.ratingsVC.isUserRatingMode() { self.enableVoteButton(positive: userRatings.getCelScore() < 3.0 ? false : true) }
                else { self.enableUpdateButton() }
            })
        } else { disableVoteButton(R.image.heart_black()!) }
    }
    
    func slide(right: Bool, newView: UIView, oldView: UIView) {
        UIView.animate(withDuration: 1.0, animations: { _ in
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
    func rippleEffect(positive: Bool, gold: Bool = false) {
        if gold { self.profilePicNode.view.rippleColor = Constants.kStarGoldShade }
        else { self.profilePicNode.view.rippleColor = positive ? Constants.kBlueText : Constants.kRedText }
        self.profilePicNode.view.rippleTrailColor = Color.clear
        self.profilePicNode.view.dya_ripple(self.profilePicNode.view.bounds.center)
    }
    
    func enableVoteButton(positive: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.voteButton.setImage(R.image.heart_white()!, for: .Normal)
            self.voteButton.setImage(R.image.heart_white()!, for: .Highlighted)
            self.voteButton.removeTarget(self, action: #selector(DetailViewController.updateAction), for: .touchUpInside)
            self.voteButton.addTarget(self, action: #selector(DetailViewController.voteAction), for: .touchUpInside)
            self.voteButton.backgroundColor = positive == true ? Constants.kBlueLight : Constants.kRedLight },
            completion: { _ in Animation.delay(time: 2) {
                self.voteButton.pulseAnimation = .centerWithBacking
                self.voteButton.pulse() }
        })
    }

    func socialSharing(message: String) {
        self.openHandleMenu()
        self.socialMessage = message
    }
    
    //MARK: ViewDidLoad Helpers
    func getNavigationView() -> Toolbar {
        let backButton: FlatButton = FlatButton()
        backButton.pulseColor = Color.white
        backButton.setTitle("BACK", for: .normal)
        backButton.setTitleColor(Color.clear, for: .normal)
        backButton.pulseAnimation = .none
        backButton.accessibilityLabel = "Back Button"
        backButton.isAccessibilityElement = true
        backButton.setImage(R.image.arrow_white()!, for: .Normal)
        backButton.setImage(R.image.arrow_white()!, for: .Highlighted)
        backButton.addTarget(self, action: #selector(DetailViewController.backAction), for: .touchUpInside)
        
        let infoButton: FlatButton = FlatButton()
        infoButton.pulseColor = Color.white
        infoButton.pulseAnimation = .none
        infoButton.accessibilityLabel = "Info Button"
        infoButton.isAccessibilityElement = true
        infoButton.setImage(R.image.info_button()!, for: .Normal)
        infoButton.setImage(R.image.info_button()!, for: .Highlighted)
        infoButton.addTarget(self, action: #selector(DetailViewController.infoAction), for: .touchUpInside)
        
        let nameLabel: UILabel = self.setupLabel(title: "★  " + self.celebST.nickname + "   ★", frame: CGRect(x: 40, y: 28, width: Constants.kScreenWidth - 80, height: 30))
        nameLabel.backgroundColor = Constants.kRedShade
        nameLabel.textColor = Color.white
        nameLabel.textAlignment = .center
        self.view.addSubview(nameLabel)
        
        let navigationBarView: Toolbar = Toolbar()
        navigationBarView.frame = Constants.kDetailNavigationBarRect
        navigationBarView.leftControls = [backButton]
        navigationBarView.rightControls = [infoButton]
        navigationBarView.depth = .depth3
        navigationBarView.backgroundColor = Constants.kRedShade
        return navigationBarView
    }
    
    func getTopView() -> View {
        let topView: View = View(frame: Constants.kTopViewRect)
        topView.depth = .depth2
        topView.backgroundColor = Constants.kBlueShade
        topView.isOpaque = true
        topView.image = R.image.topView()
        return topView
    }
    
    func getSegmentView() -> SMSegmentView {
        let segmentView: SMSegmentView = SMSegmentView(frame: Constants.kSegmentViewRect,
            separatorColour: Color.black, separatorWidth: 1,
            segmentProperties:[keySegmentTitleFont: UIFont.systemFont(ofSize: 0),
                keySegmentOnSelectionColour: Constants.kRedShade,
                keySegmentOffSelectionColour: Constants.kGreyBackground,
                keyContentVerticalMargin: 5 as AnyObject])
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.scale_white()!, offSelectionImage: R.image.scale_black()!)
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.info_white()!, offSelectionImage: R.image.info_black()!)
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.star_icon()!, offSelectionImage: R.image.star_black()!)
        segmentView.selectSegmentAtIndex(0)
        segmentView.clipsToBounds = false
        segmentView.layer.shadowColor = Color.black.CGColor
        segmentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        segmentView.layer.shadowOpacity = 0.3
        segmentView.segments[0].isAccessibilityElement = true
        segmentView.segments[0].accessibilityLabel = "CelScore View"
        segmentView.segments[1].isAccessibilityElement = true
        segmentView.segments[1].accessibilityLabel = "Info View"
        segmentView.segments[2].isAccessibilityElement = true
        segmentView.segments[2].accessibilityLabel = "Vote View"
        segmentView.delegate = self
        return segmentView
    }
    
    func setUpVoteButton() {
        let diameter: CGFloat = Constants.kFabDiameter
        self.voteButton.frame = CGRect(x: Constants.kMaxWidth + 100, y: Constants.kTopViewRect.bottom - 35, width: diameter, height: diameter)
        self.voteButton.shape = .Circle
        self.voteButton.depth = .Depth2
        self.voteButton.pulseAnimation = .none
        self.voteButton.accessibilityLabel = "Vote Button"
        self.disableVoteButton(R.image.heart_black()!)
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id).startWithNext({ hasRatings in
            self.voteButton.tintColor = hasRatings ? Constants.kStarGoldShade : Constants.kGreyBackground
        })
    }
}




