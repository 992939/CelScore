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


final class DetailViewController: ASViewController, SMSegmentViewDelegate, DetailSubViewDelegate, AFDropdownNotificationDelegate {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let infoVC: InfoViewController
    let ratingsVC: RatingsViewController
    let celscoreVC: CelScoreViewController
    let socialButton: MenuView
    let voteButton: MaterialButton
    let notification: AFDropdownNotification
    var socialMessage: String = ""
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.infoVC = InfoViewController(celebrityST: self.celebST)
        self.ratingsVC = RatingsViewController(celebrityST: self.celebST)
        self.celscoreVC = CelScoreViewController(celebrityST: self.celebST)
        self.socialButton = MenuView()
        self.voteButton = MaterialButton()
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
        self.setUpSocialButton()
        self.setUpVoteButton()
        
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
            .on(next: { ratings in
                let unrated = ratings.filter{ (ratings[$0] as! Int) == 0 }
                if unrated.count == 0 {
                    RatingsViewModel().voteSignal(ratingsId: self.celebST.id)
                        .on(next: { userRatings in
                            var celScore: Double = 0
                            for rating in ratings { celScore += ratings[rating] as! Double }
                            let isPositive = celScore < 30 ? false : true
                            self.ratingsVC.animateStarsToGold(positive: isPositive)
                        })
                        .start()
                }
            })
            .start()
    }
    
    //MARK: ViewDidLoad Helpers
    func getNavigationView() -> NavigationBarView {
        let backButton: FlatButton = FlatButton()
        backButton.pulseColor = MaterialColor.white
        backButton.pulseScale = false
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Normal)
        backButton.setImage(UIImage(named: "db-profile-chevron"), forState: .Highlighted)
        backButton.addTarget(self, action: Selector("backAction"), forControlEvents: .TouchUpInside)
        
        let nameLabel = UILabel()
        nameLabel.text = self.celebST.nickname
        nameLabel.textAlignment = .Center
        nameLabel.textColor = MaterialColor.white
        
        let navigationBarView = NavigationBarView(frame: Constants.kNavigationBarRect)
        navigationBarView.leftControls = [backButton]
        navigationBarView.depth = .Depth3
        navigationBarView.titleLabel = nameLabel
        navigationBarView.backgroundColor = Constants.kMainShade
        navigationBarView.contentMode = .ScaleAspectFit
        return navigationBarView
    }
    
    func getTopView() -> MaterialView {
        let topView = MaterialView(frame: Constants.kTopViewRect)
        let profilePicNode = ASNetworkImageNode(webImage: ())
        profilePicNode.URL = NSURL(string: self.celebST.imageURL)
        profilePicNode.contentMode = UIViewContentMode.ScaleAspectFit
        let picWidth: CGFloat = 180.0
        profilePicNode.frame = CGRect(x: topView.bounds.centerX - picWidth/2, y: (topView.height - picWidth) / 2, width: picWidth, height: picWidth)
        profilePicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeRoundBorderModificationBlock(12.0, Constants.kBrightShade)(originalImage)
        }
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
    
    func setUpSocialButton() {
        let btn1: FabButton = FabButton()
        btn1.depth = .Depth2
        btn1.pulseScale = false
        btn1.backgroundColor = Constants.kDarkShade
        btn1.addTarget(self, action: "handleMenu", forControlEvents: .TouchUpInside)
        self.socialButton.addSubview(btn1)
        
        var image = UIImage(named: "score_white")!.imageWithRenderingMode(.AlwaysTemplate)
        let btn2: FabButton = FabButton()
        btn2.tag = 1
        btn2.depth = .Depth1
        btn2.pulseColor = MaterialColor.white
        btn2.backgroundColor = Constants.kMainShade
        btn2.borderWidth = 1
        btn2.setImage(image, forState: .Normal)
        btn2.setImage(image, forState: .Highlighted)
        btn2.addTarget(self, action: "handleButton:", forControlEvents: .TouchUpInside)
        self.socialButton.addSubview(btn2)
        
        image = UIImage(named: "score_white")!.imageWithRenderingMode(.AlwaysTemplate)
        let btn3: FabButton = FabButton()
        btn2.tag = 2
        btn3.depth = .Depth1
        btn3.pulseColor = MaterialColor.white
        btn3.backgroundColor = Constants.kMainShade
        btn3.borderWidth = 1
        btn3.setImage(image, forState: .Normal)
        btn3.setImage(image, forState: .Highlighted)
        btn3.addTarget(self, action: "handleButton:", forControlEvents: .TouchUpInside)
        self.socialButton.addSubview(btn3)
        
        self.socialButton.menu.enabled = false
        self.socialButton.menu.origin = CGPoint(x: 25, y: Constants.kTopViewRect.bottom - 22)
        self.socialButton.menu.baseViewSize = CGSize(width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        self.socialButton.menu.direction = .Up
        self.socialButton.menu.views = [btn1, btn2, btn3]
        self.socialButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func handleMenu() {
        self.socialButton.menu.close()
        self.socialButton.menu.enabled = false
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        first?.backgroundColor = Constants.kDarkShade
        first?.animate(MaterialAnimation.rotate(1))
    }
    
    internal func handleButton(button: UIButton) {
        CelScoreViewModel().shareVoteOnSignal(socialNetwork: (button.tag == 1 ? .Facebook: .Twitter), message: self.socialMessage)
            .on(next: { socialVC in self.presentViewController(socialVC, animated: true, completion: nil) })
            .start()
    }
    
    func setUpVoteButton() {
        self.voteButton.frame = CGRect(x: Constants.kDetailWidth - 30, y: Constants.kTopViewRect.bottom - 22, width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        self.voteButton.shape = .Circle
        self.voteButton.depth = .Depth2
        self.voteButton.pulseScale = false
        self.voteButton.enabled = false
        self.voteButton.backgroundColor = Constants.kDarkShade
        self.voteButton.addTarget(self, action: Selector("voteAction"), forControlEvents: .TouchUpInside)
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
        
        self.voteButton.enabled = false
        self.voteButton.backgroundColor = Constants.kDarkShade
        if index == 2 {
            RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .UserRatings)
                .on(next: { userRatings in
                    var celScore: Double = 0
                    for rating in userRatings { celScore += userRatings[rating] as! Double }
                    self.voteButton.backgroundColor = celScore < 30 ? Constants.kBrightShade : Constants.kWineShade
                    self.voteButton.enabled = true
                })
                .start()
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
            self.voteButton.backgroundColor = positive == true ? Constants.kBrightShade : Constants.kWineShade },
            completion: { _ in MaterialAnimation.delay(2) {
                self.voteButton.pulseScale = true
                self.voteButton.pulse() }
        })
    }
    
    func sendFortuneCookie() {
        CelScoreViewModel().getFortuneCookieSignal(cookieType: .Positive)
            .on(next: { text in
                self.notification.titleText = "Bad Fortune Cookie"
                self.notification.subtitleText = text
                self.notification.image = UIImage(named: "cookie")
                self.notification.dismissOnTap = true
                self.notification.presentInView(self.view, withGravityAnimation: true)
                AIRTimer.after(5.0){ _ in self.notification.dismissWithGravityAnimation(true) }
            })
            .start()
    }

    func socialSharing(message: String) {
        self.socialButton.menu.enabled = true
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        first?.backgroundColor = Constants.kBrightShade
        first?.pulseScale = true
        first?.pulse()
        self.socialButton.menu.open()
        self.socialMessage = message
    }
    
    //MARK: AFDropdownNotificationDelegate
    func dropdownNotificationBottomButtonTapped() {}
    func dropdownNotificationTopButtonTapped() {}
}




