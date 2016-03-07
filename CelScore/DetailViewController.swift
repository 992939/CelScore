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


final class DetailViewController: ASViewController, SMSegmentViewDelegate, DetailSubViewDelegate, AFDropdownNotificationDelegate {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let infoVC: InfoViewController
    let ratingsVC: RatingsViewController
    let celscoreVC: CelScoreViewController
    let voteButton: MaterialButton
    let notification: AFDropdownNotification
    let socialButton: MenuView
    private(set) var socialMessage: String = ""
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.infoVC = InfoViewController(celebrityST: self.celebST)
        self.ratingsVC = RatingsViewController(celebrityST: self.celebST)
        self.celscoreVC = CelScoreViewController(celebrityST: self.celebST)
        self.voteButton = MaterialButton()
        self.socialButton = MenuView()
        self.notification = AFDropdownNotification()
        super.init(node: ASDisplayNode())
        CelebrityViewModel().updateUserActivitySignal(id: celebrityST.id).startWithNext { activity in self.userActivity = activity }
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
        self.notification.notificationDelegate = self
        
        let navigationBarView: NavigationBarView = getNavigationView()
        let topView: MaterialView = getTopView()
        let segmentView: SMSegmentView = getSegmentView()
        self.setUpVoteButton()
        Constants.setUpSocialButton(self.socialButton, controller: self, origin: CGPoint(x: 25, y: Constants.kTopViewRect.bottom - 22), buttonColor: Constants.kDarkShade)
        self.socialButton.menu.enabled = false
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        first?.setImage(UIImage(named: "ic_add_black"), forState: .Normal)
        first?.setImage(UIImage(named: "ic_add_black"), forState: .Highlighted)
        
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
    
    func backAction() { self.dismissViewControllerAnimated(true, completion: nil) }
    
    func voteAction() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings)
            .filter({ (ratings: RatingsModel) -> Bool in return ratings.filter{ (ratings[$0] as! Int) == 0 }.isEmpty })
            .observeOn(QueueScheduler.mainQueueScheduler)
            .flatMap(FlattenStrategy.Latest) { (_) -> SignalProducer<RatingsModel, RatingsError> in
                return RatingsViewModel().voteSignal(ratingsId: self.celebST.id)
            }
            .startWithNext({ (userRatings:RatingsModel) in
                let isPositive = userRatings.getCelScore() < 3 ? false : true
                self.ratingsVC.animateStarsToGold(positive: isPositive)
            })
    }
    
    //MARK: socialButton delegate
    func handleMenu(open: Bool = false) {
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        if open {
            self.socialButton.menu.enabled = true
            first?.backgroundColor = Constants.kDarkGreenShade
            first?.pulseScale = true
            first?.pulse()
            first?.animate(MaterialAnimation.rotate(rotation: 1))
            self.socialButton.menu.open()
            let image = UIImage(named: "ic_close_white")?.imageWithRenderingMode(.AlwaysTemplate)
            first?.setImage(image, forState: .Normal)
            first?.setImage(image, forState: .Highlighted)
        } else if self.socialButton.menu.opened {
            first?.animate(MaterialAnimation.rotate(rotation: 1))
            self.socialButton.menu.close()
            self.socialButton.menu.enabled = false
            first?.backgroundColor = Constants.kDarkShade
            first?.setImage(UIImage(named: "ic_add_black"), forState: .Normal)
            first?.setImage(UIImage(named: "ic_add_black"), forState: .Highlighted)
        }
    }
    
    func socialButton(button: UIButton) {
        SettingsViewModel().isLoggedInSignal()
            .on(next: { _ in
                CelScoreViewModel().shareVoteOnSignal(socialNetwork: (button.tag == 1 ? .Facebook: .Twitter), message: self.socialMessage)
                    .on(next: { socialVC in self.presentViewController(socialVC, animated: true, completion: nil) })
                    .start()
            })
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
                            .map({ _ in return UserViewModel().getUserInfoFromFacebookSignal().start() })
                            .map({ _ in return UserViewModel().getFromCognitoSignal(dataSetType: .UserRatings).start() })
                            .map({ _ in return UserViewModel().getFromCognitoSignal(dataSetType: .UserSettings).start() })
                            .map({ _ in return self.handleMenu(true) })
                            .start()
                    })
                } else {
                    //TWITTER
                }
            })
            .start()
    }
    
    //MARK: SMSegmentViewDelegate
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int, previousIndex: Int) {
        let infoView: UIView
        switch index {
        case 1: infoView = self.infoVC.view
        case 2: infoView = self.ratingsVC.view
        default: infoView = self.celscoreVC.view
        }
        infoView.hidden = false
        infoView.frame = Constants.kBottomViewRect
        
        let removingView: UIView
        switch previousIndex {
        case 1: removingView = self.infoVC.view
        case 2: removingView = self.ratingsVC.view
        default: removingView = self.celscoreVC.view
        }
        
        self.handleMenu()
        
        self.voteButton.enabled = false
        self.voteButton.setImage(UIImage(named: "justice_black"), forState: .Normal)
        self.voteButton.setImage(UIImage(named: "justice_black"), forState: .Highlighted)
        self.voteButton.backgroundColor = Constants.kDarkShade
        if index == 2 {
            RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id)
                .filter({ hasUserRatings in return hasUserRatings })
                .promoteErrors(RatingsError)
                .flatMap(.Latest) { (_) -> SignalProducer<RatingsModel, RatingsError> in
                    return RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings)
                }
                .startWithNext({ userRatings in
                    self.voteButton.backgroundColor = userRatings.getCelScore() < 3.0 ? Constants.kDarkGreenShade : Constants.kWineShade
                    self.voteButton.enabled = true
                    self.voteButton.setImage(UIImage(named: "justice"), forState: .Normal)
                    self.voteButton.setImage(UIImage(named: "justice"), forState: .Highlighted)
                })
        }
    
        if index == 0 || (index == 1 && previousIndex == 2 ){
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                removingView.left = infoView.width + 35
                infoView.slideLeft()
                }, completion: { completed -> Void in removingView.hidden = true
            })
        } else {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                removingView.left = -infoView.width
                infoView.slideRight()
                }, completion: { completed -> Void in removingView.hidden = true
            })
        }
    }
    
    //MARK: RatingsViewDelegate
    func enableVoteButton(positive: Bool) {
        UIView.animateWithDuration(0.3, animations: {
            self.voteButton.enabled = true
            self.voteButton.setImage(UIImage(named: "justice"), forState: .Normal)
            self.voteButton.setImage(UIImage(named: "justice"), forState: .Highlighted)
            self.voteButton.backgroundColor = positive == true ? Constants.kDarkGreenShade : Constants.kWineShade },
            completion: { _ in MaterialAnimation.delay(2) {
                self.voteButton.pulseScale = true
                self.voteButton.pulse() }
        })
    }
    
    func sendFortuneCookie() {
        CelScoreViewModel().getFortuneCookieSignal(cookieType: .Positive)
            .on(next: { text in
                self.notification.titleText = "Revolutionary Road Sign"
                self.notification.subtitleText = text
                self.notification.image = UIImage(named: "road")
                self.notification.dismissOnTap = true
                self.notification.presentInView(self.view, withGravityAnimation: true)
            })
            .delay(5.0, onScheduler: QueueScheduler.mainQueueScheduler)
            .on(completed: { self.notification.dismissWithGravityAnimation(true) })
            .start()
    }

    func socialSharing(message: String) {
        self.handleMenu(true)
        self.socialMessage = message
    }
    
    //MARK: AFDropdownNotificationDelegate
    func dropdownNotificationBottomButtonTapped() {}
    func dropdownNotificationTopButtonTapped() {}
    
    //MARK: ViewDidLoad Helpers
    func getNavigationView() -> NavigationBarView {
        let backButton: FlatButton = FlatButton()
        backButton.pulseColor = MaterialColor.white
        backButton.pulseScale = false
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Normal)
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Highlighted)
        backButton.addTarget(self, action: Selector("backAction"), forControlEvents: .TouchUpInside)
        
        let nameLabel = Constants.setupLabel(title: self.celebST.nickname, frame: CGRect(x: 0, y: 28, width: Constants.kScreenWidth, height: 30))
        nameLabel.textAlignment = .Center
        self.view.addSubview(nameLabel)
        
        let navigationBarView = NavigationBarView(frame: Constants.kNavigationBarRect)
        navigationBarView.leftControls = [backButton]
        navigationBarView.depth = .Depth3
        navigationBarView.backgroundColor = Constants.kMainShade
        navigationBarView.contentMode = .ScaleAspectFit
        return navigationBarView
    }
    
    func getTopView() -> MaterialView {
        let topView = MaterialView(frame: Constants.kTopViewRect)
        let profilePicNode = ASNetworkImageNode(webImage: ())
        profilePicNode.URL = NSURL(string: self.celebST.imageURL)
        let picWidth: CGFloat = 200.0
        profilePicNode.frame = CGRect(x: topView.bounds.centerX - picWidth/2, y: (topView.height - picWidth) / 2, width: picWidth, height: picWidth)
        profilePicNode.contentMode = .ScaleAspectFit
        profilePicNode.clipsToBounds = true
        profilePicNode.borderWidth = 8
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id).startWithNext({ hasRatings in
            profilePicNode.borderColor = hasRatings ? Constants.kStarRatingShade.CGColor : MaterialColor.white.CGColor
        })
        profilePicNode.cornerRadius = picWidth/2
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
        segmentView.addSegmentWithTitle(nil, onSelectionImage: UIImage(named: "celscore_white"), offSelectionImage: UIImage(named: "celscore_black"))
        segmentView.addSegmentWithTitle(nil, onSelectionImage: UIImage(named: "info_white"), offSelectionImage: UIImage(named: "info_black"))
        segmentView.addSegmentWithTitle(nil, onSelectionImage: UIImage(named: "star_icon"), offSelectionImage: UIImage(named: "star_black"))
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
        self.voteButton.enabled = false
        self.voteButton.setImage(UIImage(named: "justice_black"), forState: .Normal)
        self.voteButton.setImage(UIImage(named: "justice_black"), forState: .Highlighted)
        self.voteButton.backgroundColor = Constants.kDarkShade
        self.voteButton.addTarget(self, action: Selector("voteAction"), forControlEvents: .TouchUpInside)
    }
}




