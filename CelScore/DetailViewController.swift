//
//  DetailViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/2/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material
import Social
import ReactiveCocoa
import ReactiveSwift
import Result
import SafariServices
import PMAlertController
import WebKit


final class DetailViewController: UIViewController, DetailSubViewable, Sociable, Labelable, CAAnimationDelegate, GDWebViewControllerDelegate {
    
    //MARK: Properties
    fileprivate let infoVC: InfoViewController
    fileprivate let ratingsVC: RatingsViewController
    fileprivate let celscoreVC: CelScoreViewController
    fileprivate let voteButton: Button
    fileprivate let celebST: CelebrityStruct
    fileprivate let socialButton: FABMenu
    fileprivate var previousIndex: Int = 1
    internal let profilePicNode: ASNetworkImageNode
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.infoVC = InfoViewController(celebrityST: self.celebST)
        self.ratingsVC = RatingsViewController(celebrityST: self.celebST)
        self.celscoreVC = CelScoreViewController(celebrityST: self.celebST)
        self.voteButton = Button()
        self.socialButton = FABMenu(frame: CGRect(x: -100, y: Constants.kTopViewRect.bottom - 35, width: Constants.kFabDiameter, height: Constants.kFabDiameter))
        self.profilePicNode = ASNetworkImageNode()
        super.init(nibName: nil, bundle: nil)
        
        CelebrityViewModel().updateUserActivitySignal(id: self.celebST.id)
            .on(value: { activity in self.userActivity = activity })
            .start(on: QueueScheduler())
            .start()
        
        RatingsViewModel().cleanUpRatingsSignal(ratingsId: self.celebST.id).start()
    }
    
    //MARK: Methods
    override var prefersStatusBarHidden : Bool { return true }
    override func updateUserActivityState(_ activity: NSUserActivity) { activity.becomeCurrent() }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showingButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ratingsVC.delegate = self
        self.infoVC.delegate = self
        self.celscoreVC.delegate = self
        
        let navigationBarView: Toolbar = getNavigationView()
        let topView: View = getTopView()
        let segmentView: SMSegmentView = getSegmentView()
        self.setUpVoteButton()
        
        self.setUpSocialButton(menu: self.socialButton, buttonColor: Constants.kGreyBackground)
        self.socialButton.fabButton?.setImage(R.image.ic_add_black()!, for: .normal)
        self.socialButton.fabButton?.setImage(R.image.ic_add_black()!, for: .highlighted)

        let statusView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 20))
        statusView.backgroundColor = Color.red.darken2
        
        //self.profilePicNode.url = URL(string: celebST.imageURL)
        self.profilePicNode.defaultImage = R.image.jamie_blue()!
        //self.profilePicNode.defaultImage = R.image.uncle_sam()!
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
        self.view.addSubview(self.voteButton)
        self.view.addSubview(self.profilePicNode.view)
        self.view.addSubview(self.infoVC.view)
        self.view.addSubview(self.ratingsVC.view)
        self.view.addSubview(self.celscoreVC.view)
        self.view.backgroundColor = Constants.kBlueShade
    }
    
    func showingButtons() {
        self.socialButton.animate(
            .translate(x: Constants.kPadding + 110, y: 0, z: 0),
            .spin(z: 1.0))
        
        self.voteButton.animate(
            .spin(z: 1.0),
            .translate(x: -(Constants.kFabDiameter + 100), y: 0, z: 0))
    }
    
    func hideButtons() {
        self.socialButton.animate(
            .spin(z: 1.0),
            .translate(x: -(Constants.kPadding + 110), y: 0, z: 0))
        
        self.voteButton.animate(
            .spin(z: 1.0),
            .translate(x: Constants.kFabDiameter + 100, y: 0, z: 0))
    }
    
    func backAction() {
        self.hideButtons()
        RatingsViewModel().cleanUpRatingsSignal(ratingsId: self.celebST.id).start()
        Motion.delay(0.15){ self.dismiss(animated: true, completion: nil) }
    }
    
    func voteAction() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .userRatings)
            .filter({ (ratings: RatingsModel) -> Bool in return ratings.filter{ (ratings[$0] as! Int) == 0 }.isEmpty })
            .flatMap(.latest) { (ratings: RatingsModel) -> SignalProducer<RatingsModel, RatingsError> in
                return RatingsViewModel().voteSignal(ratingsId: self.celebST.id) }
            .observe(on: UIScheduler())
            .flatMap(.latest) { (ratings: RatingsModel) -> SignalProducer<String, NoError> in
                return RatingsViewModel().getVoteMessage(celeb: self.celebST) }
            .map { voteMessage in
                self.ratingsVC.animateStarsToGold()
                Motion.delay(2.0, execute: {
                    let alertVC = PMAlertController(title: "Star Qualities Ballot", description: voteMessage, image: R.image.big_blue_ballot()!, style: .alert)
                    alertVC.alertTitle.textColor = Constants.kBlueText
                    alertVC.addAction(PMAlertAction(title: Constants.kAlertAction, style: .default, action: { _ in
                        self.voteButton.setImage(R.image.goldstar()!, for: .normal)
                        self.voteButton.setImage(R.image.goldstar()!, for: .highlighted)
                        self.enableVoteButton()
                    }))
                    alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
                    alertVC.view.isOpaque = false
                    self.present(alertVC, animated: true, completion: nil)
                })
            }
            .start()
    }
    
    func updateAction() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .userRatings)
            .filter({ (ratings: RatingsModel) -> Bool in return ratings.filter{ (ratings[$0] as! Int) == 0 }.isEmpty })
            .on(value: { (userRatings:RatingsModel) in
                self.updateVoteButton(positive: userRatings.getCelScore() < Constants.kRoyalty ? false : true)
                self.ratingsVC.displayUserRatings(userRatings)
            }).start()
    }
    
    func trollAction() {
        Motion.delay(0.5) {
            SettingsViewModel().calculateUserAverageCelScoreSignal()
                .filter({ (score:CGFloat) -> Bool in return score < Constants.kTrollingWarning })
                .flatMap(.latest) { (score:CGFloat) -> SignalProducer<AnyObject, NoError> in
                    return SettingsViewModel().getSettingSignal(settingType: .firstTrollWarning) }
                .map { first in let firstTime = first as! Bool
                    guard firstTime else { return }
                    TAOverlay.show(withLabel: OverlayInfo.firstTrollWarning.message(), image: OverlayInfo.firstTrollWarning.logo(), options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false as AnyObject, settingType: .firstTrollWarning).start() })
                    }
                .start()
        }
    }
    
    //MARK: SFSafariViewControllerDelegate
    func openSafari() {
        CelebrityViewModel().getCelebritySignal(id: self.celebST.id)
            .on(value: { celeb in
            
//                let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
//                webView.uiDelegate = self
//                self.prese = webView
//
//                let searchTerm = celeb.googleName.replacingOccurrences(of: " ", with: "+")
//                let myURL = URL(string: String("https://www.google.com/search?q=\(searchTerm)"))
//                let myRequest = URLRequest(url: myURL!)
//                webView.load(myRequest)
                
//                let safariVC = SFSafariViewController(url: NSURL(string: searchString!)! as URL)
//                let statusView = UIView(frame: Constants.kStatusViewRect)
//                statusView.backgroundColor = Color.red.darken2
//                safariVC.view.addSubview(statusView)
//                self.present(safariVC, animated: true, completion: nil)
//                safariVC.preferredBarTintColor = Constants.kRedShade
//                safariVC.preferredControlTintColor = Color.white
//                safariVC.delegate = self
            }).start()
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Sociable
    func fabMenuWillOpen(fabMenu: FABMenu) { self.openHandleMenu() }
    func fabMenuWillClose(fabMenu: FABMenu) { self.closeHandleMenu() }
    
    func handleMenu(open: Bool = false) {
        if open { self.openHandleMenu() }
        else if self.socialButton.isOpened { self.closeHandleMenu() }
    }

    func openHandleMenu() {
        self.socialButton.fabButton?.layer.animate(MotionAnimation.spin(z: 0.25))
        self.socialButton.fabButton?.pulseAnimation = .centerWithBacking
        self.socialButton.open()
    }
    
    func closeHandleMenu() {
        self.socialButton.fabButton?.setImage(R.image.ic_add_black()!, for: .normal)
        self.socialButton.fabButton?.setImage(R.image.ic_add_black()!, for: .highlighted)
        self.socialButton.fabButton?.layer.animate(MotionAnimation.spin(z: 0.5))
        self.socialButton.close()
    }
    
    func socialButton(button: UIButton) {
        SettingsViewModel().loggedInAsSignal()
            .on(failed: { _ in self.socialButtonTapped(buttonTag: button.tag, hideButton: false) })
            .flatMap(.latest) { (_) -> SignalProducer<Double, NoError> in
                return RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id) }
            .on(value: { score in
                CelScoreViewModel()
                    .shareVoteOnSignal(socialLogin: (button.tag == 1 ? .facebook: .twitter),
                        message: "\(self.celebST.nickName) is \(String(format: "%.1f", score))% Hollywood Royalty. #CNN")
                    .startWithValues { socialVC in
                    let isFacebookAvailable: Bool = SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)
                    let isTwitterAvailable: Bool = SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
                    guard (button.tag == 1 ? isFacebookAvailable : isTwitterAvailable) == true else {
                        TAOverlay.show(withLabel: SocialLogin(rawValue: button.tag)!.serviceUnavailable(),
                                       image: OverlayInfo.loginError.logo(), options: OverlayInfo.getOptions())
                        return }
                    self.present(socialVC, animated: true, completion: { Motion.delay(2.0) { self.socialButton.close() }})
                }})
            .start()
    }
    
    func socialRefresh() {
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .userRatings)
            .on(failed: { _ in self.ratingsVC.displayRatings() })
            .on(value: { userRatings in
                self.ratingsVC.displayRatings(userRatings)
                let voteImage = userRatings.getCelScore() > 0 ? R.image.goldstar()! : R.image.blackstar()!
                self.voteButton.setImage(voteImage, for: .normal)
                self.voteButton.setImage(voteImage, for: .highlighted)
            }).start()
    }
    
    func enableVoteButton() {
        self.voteButton.isEnabled = true
        self.voteButton.pulseAnimation = .centerWithBacking
        self.voteButton.backgroundColor = Constants.kGreyBackground
        self.voteButton.removeTarget(self, action: #selector(self.voteAction), for: .touchUpInside)
        self.voteButton.addTarget(self, action: #selector(self.updateAction), for: .touchUpInside)
        
        Motion.delay(1) {
            self.voteButton.pulseAnimation = .centerWithBacking
            self.voteButton.pulse()
        }
    }

    func disableVoteButton(_ image: UIImage) {
        self.voteButton.isEnabled = false
        self.voteButton.setImage(image, for: .normal)
        self.voteButton.setImage(image, for: .highlighted)
        self.voteButton.removeTarget(self, action: nil, for: .touchUpInside)
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id)
            .on(value: { hasRatings in
                let voteImage = hasRatings ? R.image.goldstar()! : R.image.blackstar()!
                self.voteButton.setImage(voteImage, for: .normal)
                self.voteButton.setImage(voteImage, for: .highlighted)
            })
            .start()
    }

    //MARK: SMSegmentViewDelegate
    func segmentView(_ segmentView: SMSegmentView) {
        let infoView: UIView = self.getSubView(atIndex: segmentView.selectedSegmentIndex)
        infoView.isHidden = false
        infoView.frame = Constants.kBottomViewRect
        let removingView = self.getSubView(atIndex: previousIndex)
        
        if segmentView.selectedSegmentIndex == 0 || (segmentView.selectedSegmentIndex == 1 && self.previousIndex == 2 ){ self.slide(right: false, newView: infoView, oldView: removingView) }
        else { self.slide(right: true, newView: infoView, oldView: removingView) }
        if self.socialButton.isOpened { self.closeHandleMenu() }
        
        if segmentView.selectedSegmentIndex == 2 {
            self.enableVoteButton()
            RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .userRatings)
                .flatMapError { _ in SignalProducer.empty }
                .startWithValues({ userRatings in
                guard userRatings.getCelScore() > 0 else { return }
                if self.ratingsVC.isUserRatingMode() {
                    let isPositive = userRatings.getCelScore() < Constants.kRoyalty ? false : true
                    self.updateVoteButton(positive: isPositive)
                    }
                })
        } else { self.disableVoteButton(R.image.blackstar()!) }
        self.previousIndex = segmentView.selectedSegmentIndex
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
    func updateVoteButton(positive: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.voteButton.setImage(R.image.whitestar()!, for: .normal)
            self.voteButton.setImage(R.image.whitestar()!, for: .highlighted)
            self.voteButton.removeTarget(self, action: #selector(self.updateAction), for: .touchUpInside)
            self.voteButton.addTarget(self, action: #selector(self.voteAction), for: .touchUpInside)
            self.voteButton.backgroundColor = positive == true ? Constants.kBlueShade : Constants.kRedShade },
            completion: { _ in Motion.delay(2) {
                self.voteButton.pulseAnimation = .centerWithBacking
                self.voteButton.pulseColor = .white
                self.voteButton.pulse()
                }
        })
    }
    
    //MARK: ViewDidLoad Helpers
    func getNavigationView() -> Toolbar {
        let backButton: FlatButton = FlatButton()
        backButton.pulseColor = Color.white
        backButton.setTitle("BACK", for: .normal)
        backButton.setTitleColor(Color.clear, for: .normal)
        backButton.pulseAnimation = .none
        backButton.setImage(R.image.arrow_white()!, for: .normal)
        backButton.setImage(R.image.arrow_white()!, for: .highlighted)
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        let infoButton: FlatButton = FlatButton()
        infoButton.pulseColor = Color.white
        infoButton.pulseAnimation = .none
        let bell_image = self.celebST.isTrending ? R.image.bell_ring()! : R.image.bell()!
        infoButton.setImage(bell_image, for: .normal)
        infoButton.setImage(bell_image, for: .highlighted)
        infoButton.addTarget(self, action: #selector(self.openSafari), for: .touchUpInside)
        if self.celebST.isTrending {
            Motion.delay(1) {
                infoButton.pulseAnimation = .centerWithBacking
                infoButton.pulse()
            }
        }

        let navigationBarView: Toolbar = Toolbar()
        navigationBarView.frame = Constants.kDetailNavigationBarRect
        let celebTitle = self.celebST.index == 1 ? celebST.kingName : celebST.nickName
        navigationBarView.title = String("\(self.celebST.index). \(celebTitle)")
        navigationBarView.titleLabel.textColor = UIColor.white
        navigationBarView.titleLabel.font = UIFont.boldSystemFont(ofSize: UIDevice.getFontSize() + 1)
        navigationBarView.titleLabel.adjustsFontSizeToFitWidth = true
        navigationBarView.leftViews = [backButton]
        navigationBarView.rightViews = [infoButton]
        navigationBarView.depthPreset = .depth3
        navigationBarView.backgroundColor = Constants.kRedShade
        return navigationBarView
    }
    
    func getTopView() -> View {
        let topView: View = View(frame: Constants.kTopViewRect)
        topView.depthPreset = .depth2
        topView.layer.cornerRadius = Constants.kCornerRadius
        topView.backgroundColor = Constants.kBlueShade
        topView.isOpaque = true
        topView.image = R.image.topView()
        return topView
    }
    
    func getSegmentView() -> SMSegmentView {
        let appearance = SMSegmentAppearance()
        appearance.segmentOnSelectionColour = Constants.kRedShade
        appearance.segmentOffSelectionColour = Constants.kGreyBackground
        appearance.titleOnSelectionFont = UIFont.systemFont(ofSize: 0)
        appearance.titleOffSelectionFont = UIFont.systemFont(ofSize: 0)
        appearance.contentVerticalMargin = 5.0
        
        let segmentView: SMSegmentView = SMSegmentView(frame: Constants.kSegmentViewRect,
                                                       dividerColour: Constants.kBlueShade,
                                                       dividerWidth: 4.0,
                                                       segmentAppearance: appearance)
        
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.white_crown()!, offSelectionImage: R.image.small_crown()!)
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.white_avatar()!, offSelectionImage: R.image.small_avatar()!)
        segmentView.addSegmentWithTitle(nil, onSelectionImage: R.image.star_icon()!, offSelectionImage: R.image.star_black()!)
        segmentView.addTarget(self, action: #selector(self.segmentView(_:)), for: .valueChanged)
        segmentView.selectedSegmentIndex = 0
        segmentView.layer.cornerRadius = 6.0
        segmentView.layer.shadowColor = Color.black.cgColor
        segmentView.layer.shadowOffset = CGSize(width: 0.5, height: 1.5)
        segmentView.layer.shadowOpacity = 0.7
        return segmentView
    }
    
    func setUpVoteButton() {
        let diameter: CGFloat = Constants.kFabDiameter
        self.voteButton.frame = CGRect(x: Constants.kMaxWidth + 100, y: Constants.kTopViewRect.bottom - 35, width: diameter, height: diameter)
        self.voteButton.shapePreset = .circle
        self.voteButton.depthPreset = .depth2
        self.voteButton.pulseAnimation = .center
        self.voteButton.backgroundColor = Constants.kGreyBackground
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id).startWithValues({ hasRatings in
            let voteImage = hasRatings ? R.image.goldstar()! : R.image.blackstar()!
            self.voteButton.setImage(voteImage, for: .normal)
            self.voteButton.setImage(voteImage, for: .highlighted)
        })
    }
}




