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
import FBSDKLoginKit
import AIRTimer
import Social


struct UserStruct {
    let socialMessage: String
    let isPositive: Bool
    
    func updateMessage(message: String) -> UserStruct { return UserStruct(socialMessage: message, isPositive: isPositive) }
    func updatePositive(positive: Bool) -> UserStruct { return UserStruct(socialMessage: socialMessage, isPositive: positive) }
}


final class DetailViewController: ASViewController, SMSegmentViewDelegate, DetailSubViewable, Sociable, Labelable {
    
    //MARK: Properties
    private let infoVC: InfoViewController
    private let ratingsVC: RatingsViewController
    private let celscoreVC: CelScoreViewController
    private let voteButton: MaterialButton
    private let socialButton: MenuView
    private let profilePicNode: ASNetworkImageNode
    private let celebST: CelebrityStruct
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
        super.init(node: ASDisplayNode())
        
        SettingsViewModel().isPositiveVoteSignal()
            .on(next: { value in self.userST = self.userST.updatePositive(value) })
            .filter({ (value: Bool) -> Bool in value == false })
            .promoteErrors(NSError)
            .flatMap(.Latest) { (value: Bool) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .FirstNegative) }
            .on(next: { first in let firstTime = first as! Bool
                if firstTime {
                TAOverlay.showOverlayWithLabel(OverlayInfo.FirstNegative.message(), image: OverlayInfo.FirstNegative.logo(), options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstNegative).start() })
                }
            })
            .start()
        
        CelebrityViewModel().updateUserActivitySignal(id: celebrityST.id).startWithNext { activity in self.userActivity = activity }
        RatingsViewModel().cleanUpRatingsSignal(ratingsId: self.celebST.id).start()
    }
    
    //MARK: Methods
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func updateUserActivityState(activity: NSUserActivity) { print(activity) }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingsVC.delegate = self
        self.infoVC.delegate = self
        self.celscoreVC.delegate = self
        
        let navigationBarView: Toolbar = getNavigationView()
        let topView: MaterialView = getTopView()
        let segmentView: SMSegmentView = getSegmentView()
        self.setUpVoteButton()
        self.setUpSocialButton(self.socialButton, controller: self, origin: CGPoint(x: 25, y: Constants.kTopViewRect.bottom - 22), buttonColor: Constants.kDarkShade)
        
        self.socialButton.menu.enabled = false
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        first?.setImage(self.userST.isPositive ? R.image.ic_add_green()! : R.image.ic_add_purple()!, forState: .Normal)
        first?.setImage(self.userST.isPositive ? R.image.ic_add_green()! : R.image.ic_add_purple()!, forState: .Highlighted)
        
        let statusView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 20))
        statusView.backgroundColor = Constants.kDarkShade

        self.view.addSubview(statusView)
        self.view.addSubview(navigationBarView)
        self.view.sendSubviewToBack(navigationBarView)
        self.view.addSubview(topView)
        self.view.addSubview(segmentView)
        self.view.addSubview(self.socialButton)
        MaterialLayout.size(self.view, child: self.socialButton, width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        self.view.addSubview(self.voteButton)
        self.view.addSubview(self.infoVC.view)
        self.view.addSubview(self.ratingsVC.view)
        self.view.addSubview(self.celscoreVC.view)
        self.view.backgroundColor = Constants.kDarkShade
    }
    
    func backAction() {
        RatingsViewModel().cleanUpRatingsSignal(ratingsId: self.celebST.id).startWithNext { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func voteAction() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings)
            .observeOn(UIScheduler())
            .filter({ (ratings: RatingsModel) -> Bool in return ratings.filter{ (ratings[$0] as! Int) == 0 }.isEmpty })
            .flatMap(.Latest) { (ratings: RatingsModel) -> SignalProducer<RatingsModel, RatingsError> in
                return RatingsViewModel().voteSignal(ratingsId: self.celebST.id) }
            .on(next: { (userRatings:RatingsModel) in
                self.enableUpdateButton()
                self.rippleEffect(positive: false, gold: true)
                self.ratingsVC.animateStarsToGold(positive: userRatings.getCelScore() < 3 ? false : true)
                MaterialAnimation.delay(2.0) {
                    self.voteButton.backgroundColor = Constants.kStarRatingShade
                    self.voteButton.setImage(R.image.vote_black()!, forState: .Normal)
                    self.voteButton.setImage(R.image.vote_black()!, forState: .Highlighted)
                    self.voteButton.animate(MaterialAnimation.rotate(angle: 1))
                }})
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .ConsensusBuilding)}
            .filter({ (value: AnyObject) -> Bool in return value as! Bool })
            .delay(2.0, onScheduler: QueueScheduler.mainQueueScheduler)
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (value: AnyObject) -> SignalProducer<String, RatingsError> in
                return RatingsViewModel().consensusBuildingSignal(ratingsId: self.celebST.id)}
            .on(next: { message in TAOverlay.showOverlayWithLabel(message, image: OverlayInfo.FirstConsensus.logo(), options: OverlayInfo.getOptions())})
            .start()
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
    
    //MARK: socialButton delegate
    func handleMenu(open: Bool = false) {
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        if open {
            self.socialButton.menu.enabled = true
            first?.backgroundColor = self.userST.isPositive ? Constants.kDarkGreenShade : Constants.kWineShade
            first?.pulseScale = true
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
            first?.backgroundColor = Constants.kDarkShade
            first?.setImage(self.userST.isPositive ? R.image.ic_add_green()! : R.image.ic_add_purple()!, forState: .Normal)
            first?.setImage(self.userST.isPositive ? R.image.ic_add_green()! : R.image.ic_add_purple()!, forState: .Highlighted)
        }
    }
    
    func socialButton(button: UIButton) {
        SettingsViewModel().loggedInAsSignal()
            .on(next: { _ in
                CelScoreViewModel().shareVoteOnSignal(socialLogin: (button.tag == 1 ? .Facebook: .Twitter), message: self.userST.socialMessage)
                    .on(next: { socialVC in
                        let isFacebookAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
                        let isTwitterAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
                        guard (button.tag == 1 ? isFacebookAvailable : isTwitterAvailable) == true else {
                            TAOverlay.showOverlayWithLabel(SocialLogin(rawValue: button.tag)!.serviceUnavailable(),
                                image: OverlayInfo.LoginError.logo(),
                                options: OverlayInfo.getOptions())
                            return
                        }
                        
                        self.presentViewController(socialVC, animated: true, completion: nil) })
                    .start() })
            .on(failed: { _ in
                if button.tag == 1 {
                    let readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
                    FBSDKLoginManager().logInWithReadPermissions(readPermissions, fromViewController: self, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                        guard error == nil else { print("FBSDKLogin error: \(error)"); return }
                        guard result.isCancelled == false else { return }
                        FBSDKAccessToken.setCurrentAccessToken(result.token)
                        UserViewModel().loginSignal(token: result.token.tokenString, loginType: .Facebook)
                            .observeOn(QueueScheduler.mainQueueScheduler)
                            .retry(Constants.kNetworkRetry)
                            .map({ _ in return UserViewModel().getUserInfoFromSignal(loginType: .Facebook).start() })
                            .map({ _ in return UserViewModel().getFromCognitoSignal(dataSetType: .UserRatings).start() })
                            .map({ _ in return UserViewModel().getFromCognitoSignal(dataSetType: .UserSettings).start() })
                            .map({ _ in return self.handleMenu(true) })
                            .start()
                    })
                } else {
                    //TWITTER LOGIN
                }
            })
            .start()
    }
    
    func enableUpdateButton() {
        self.voteButton.enabled = true
        self.voteButton.pulseScale = true
        self.voteButton.backgroundColor = Constants.kStarRatingShade
        self.voteButton.setImage(R.image.vote_black()!, forState: .Normal)
        self.voteButton.setImage(R.image.vote_black()!, forState: .Highlighted)
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
        let infoView = self.getSubView(atIndex: index)
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
            SettingsViewModel().getSettingSignal(settingType: .FirstStars).startWithNext({ first in let firstTime = first as! Bool
                if firstTime {
                    AIRTimer.after(1.3, handler: { _ in
                        TAOverlay.showOverlayWithLabel(OverlayInfo.FirstStars.message(),
                            image: OverlayInfo.FirstStars.logo(),
                            options: OverlayInfo.getOptions()) })
                    TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstStars).start() })
                }
            })
            
        } else { self.disableButton(button: self.voteButton, image: self.userST.isPositive ? R.image.vote_green()! : R.image.vote_purple()!) }
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
            self.voteButton.setImage(R.image.vote_white()!, forState: .Normal)
            self.voteButton.setImage(R.image.vote_white()!, forState: .Highlighted)
            self.voteButton.removeTarget(self, action: #selector(DetailViewController.updateAction), forControlEvents: .TouchUpInside)
            self.voteButton.addTarget(self, action: #selector(DetailViewController.voteAction), forControlEvents: .TouchUpInside)
            self.voteButton.backgroundColor = positive == true ? Constants.kDarkGreenShade : Constants.kWineShade },
            completion: { _ in MaterialAnimation.delay(2) {
                self.voteButton.pulseScale = true
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
        backButton.pulseScale = false
        backButton.setImage(R.image.dbProfileChevron()!, forState: .Normal)
        backButton.setImage(R.image.dbProfileChevron()!, forState: .Highlighted)
        backButton.addTarget(self, action: #selector(DetailViewController.backAction), forControlEvents: .TouchUpInside)
        
        let nameLabel = self.setupLabel(title: self.celebST.nickname, frame: CGRect(x: 0, y: 28, width: Constants.kScreenWidth, height: 30))
        nameLabel.textAlignment = .Center
        self.view.addSubview(nameLabel)
        
        let navigationBarView = Toolbar(frame: Constants.kNavigationBarRect)
        navigationBarView.leftControls = [backButton]
        navigationBarView.depth = .Depth3
        navigationBarView.backgroundColor = Constants.kMainShade
        navigationBarView.contentMode = .ScaleAspectFit
        return navigationBarView
    }
    
    func getTopView() -> MaterialView {
        let picWidth: CGFloat = 200.0
        let topView = MaterialView(frame: Constants.kTopViewRect)
        self.profilePicNode.URL = NSURL(string: self.celebST.imageURL)
        self.profilePicNode.frame = CGRect(x: topView.bounds.centerX - picWidth/2, y: (topView.height - picWidth) / 2, width: picWidth, height: picWidth)
        self.profilePicNode.contentMode = .ScaleAspectFit
        self.profilePicNode.cornerRadius = picWidth/2
        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id)
            .startWithNext({ score in
                let color = score < self.celebST.prevScore ? Constants.kWineShade : Constants.kLightGreenShade
                self.profilePicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
                    return ASImageNodeRoundBorderModificationBlock(12.0, color.colorWithAlphaComponent(0.9))(originalImage)
                }
            })
        topView.clipsToBounds = false
        let starLayer = Constants.drawStarsBackground(frame: CGRect(x: 0, y: 0, width: Constants.kTopViewRect.width, height: Constants.kTopViewRect.height))
        topView.addSubview(starLayer)
        topView.addSubview(profilePicNode.view)
        topView.depth = .Depth2
        topView.backgroundColor = Constants.kDarkShade
        return topView
    }
    
    func getSegmentView() -> SMSegmentView {
        let segmentView = SMSegmentView(frame: Constants.kSegmentViewRect,
            separatorColour: MaterialColor.black, separatorWidth: 1,
            segmentProperties:[keySegmentTitleFont: UIFont.systemFontOfSize(12),
                keySegmentOnSelectionColour: Constants.kMainShade,
                keySegmentOffSelectionColour: Constants.kDarkShade,
                keyContentVerticalMargin: 5])
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.celscore_white()!, offSelectionImage: self.userST.isPositive ? R.image.celscore_green()! : R.image.celscore_purple()!)
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.info_white()!, offSelectionImage: self.userST.isPositive ? R.image.info_green()! : R.image.info_purple()!)
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.star_icon()!, offSelectionImage: self.userST.isPositive ? R.image.star_green()! : R.image.star_purple()!)
        segmentView.selectSegmentAtIndex(0)
        segmentView.clipsToBounds = false
        segmentView.layer.shadowColor = MaterialColor.black.CGColor
        segmentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        segmentView.layer.shadowOpacity = 0.3
        segmentView.delegate = self
        return segmentView
    }
    
    func setUpVoteButton() {
        self.voteButton.frame = CGRect(x: Constants.kDetailWidth - 30, y: Constants.kTopViewRect.bottom - 22, width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        self.voteButton.shape = .Circle
        self.voteButton.depth = .Depth2
        self.voteButton.pulseScale = false
        self.voteButton.tintColor = MaterialColor.white
        self.disableButton(button: self.voteButton, image: self.userST.isPositive ? R.image.vote_green()! : R.image.vote_purple()!)
    }
}




