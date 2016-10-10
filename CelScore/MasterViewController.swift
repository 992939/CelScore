//
//  MasterViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ReactiveCocoa
import ReactiveSwift
import Material
import HMSegmentedControl
import RateLimit
import Dwifft
import Result
import PMAlertController
import RevealingSplashView
import FBSDKCoreKit
import MessageUI
import Timepiece
import Accounts


final class MasterViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, UISearchBarDelegate, NavigationDrawerControllerDelegate, Sociable, MFMailComposeViewControllerDelegate {
    
    //MARK: Properties
    fileprivate let segmentedControl: HMSegmentedControl
    fileprivate let searchBar: UISearchBar
    fileprivate let transitionManager: TransitionManager = TransitionManager()
    fileprivate let diffCalculator: TableViewDiffCalculator<CelebId>
    fileprivate let socialButton: MenuController
    internal let celebrityTableView: ASTableView
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.celebrityTableView = ASTableView()
        self.diffCalculator = TableViewDiffCalculator<CelebId>(tableView: self.celebrityTableView)
        self.diffCalculator.insertionAnimation = .fade
        self.diffCalculator.deletionAnimation = .fade
        self.segmentedControl = HMSegmentedControl(sectionTitles: ListInfo.getAllNames())
        self.socialButton = MenuController()
        self.searchBar = UISearchBar()
        super.init(nibName: nil, bundle: nil)
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
    }
    
    //MARK: Methods
    override var prefersStatusBarHidden : Bool { return true }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationDrawerController?.delegate = self
        self.navigationDrawerController?.isEnabled = false
        self.navigationDrawerController?.animationDuration = 0.4
        CelebrityViewModel().removeCelebsNotInPublicOpinionSignal().start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Animation.delay(time: 0.4) {
            if let index = self.celebrityTableView.indexPathForSelectedRow {
                self.celebrityTableView.beginUpdates()
                self.celebrityTableView.reloadRows(at: [index], with: .fade)
                self.celebrityTableView.endUpdates()
            }
            
            SettingsViewModel().loggedInAsSignal().startWithFailed({ _ in
                self.movingSocialButton(onScreen: true) })
        }
    
        SettingsViewModel().loggedInAsSignal()
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues { _ in
            RateLimit.execute(name: "updateRatings", limit: Constants.kUpdateRatings) {
                CelScoreViewModel().getFromAWSSignal(dataType: .ratings)
                    .flatMapError { _ in SignalProducer.empty }
                    .flatMap(.latest) { (_) -> SignalProducer<CGFloat, NoError> in
                        return SettingsViewModel().calculateUserAverageCelScoreSignal() }
                    .filter({ (score:CGFloat) -> Bool in score > Constants.kTrollingThreshold })
                    .flatMapError { _ in SignalProducer.empty }
                    .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NoError> in
                        return SettingsViewModel().getSettingSignal(settingType: .loginTypeIndex) }
                    .observe(on: UIScheduler())
                    .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                        let type = SocialLogin(rawValue:value as! Int)!
                        let token = type == .facebook ? FBSDKAccessToken.current().tokenString : ""
                        if type == .facebook { self.facebookTokenCheck() }
                        else { self.twitterAccessCheck() }
                        return UserViewModel().loginSignal(token: token!, with: type) }
                    .retry(upTo: Constants.kNetworkRetry)
                    .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                        return UserViewModel().updateCognitoSignal(object: "" as AnyObject!, dataSetType: .userRatings) }
                    .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                        return UserViewModel().updateCognitoSignal(object: "" as AnyObject!, dataSetType: .userSettings) }
                    .start()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.celebrityTableView.frame = Constants.kCelebrityTableViewRect
        self.celebrityTableView.asyncDataSource = self
        self.celebrityTableView.asyncDelegate = self
        self.celebrityTableView.separatorStyle = .none
        self.celebrityTableView.backgroundColor = Color.clear
        
        let attr = [NSForegroundColorAttributeName: Color.white, NSFontAttributeName : UIFont.systemFont(ofSize: 14.0)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attr
        self.searchBar.delegate = self
        self.searchBar.searchBarStyle = .minimal
        
        let navigationBarView: Toolbar = self.getNavigationView()
        self.setupSegmentedControl()
        self.setUpSocialButton(self.socialButton, controller: self, origin: CGPoint(x: Constants.kScreenWidth - 65, y: Constants.kScreenHeight), buttonColor: Constants.kRedShade)
        self.view.backgroundColor = Constants.kBlueShade
        self.view.addSubview(navigationBarView)
        self.view.addSubview(self.segmentedControl)
        self.view.addSubview(self.celebrityTableView)
        self.view.addSubview(self.socialButton.menu)
        Layout.size(parent: self.view, child: self.socialButton.menu, size: CGSize(width: Constants.kFabDiameter, height: Constants.kFabDiameter))
        self.setupData()
        
        NotificationCenter.default.reactive.notifications(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil).startWithValues { _ in
            RateLimit.execute(name: "updateFromAWS", limit: Constants.kOneDay) {
                let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
                CelScoreViewModel().getFromAWSSignal(dataType: .celebrity)
                    .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                        return CelScoreViewModel().getFromAWSSignal(dataType: .ratings) }
                    .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                        return CelScoreViewModel().getFromAWSSignal(dataType: .list) }
                    .observe(on: UIScheduler())
                    .flatMapError { _ in SignalProducer.empty }
                    .flatMap(.latest) { (_) -> SignalProducer<Bool, ListError> in
                        return ListViewModel().sanitizeListsSignal() }
                    .flatMap(.latest) { (_) -> SignalProducer<Bool, ListError> in
                        return ListViewModel().updateListSignal(listId: list.getId()) }
                    .flatMap(.latest) { (_) -> SignalProducer<ListsModel, ListError> in
                        return ListViewModel().getListSignal(listId: list.getId()) }
                    .on(starting: { list in self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId }) })
                    .flatMapError { _ in SignalProducer.empty }
                    .flatMap(.Latest) { (_) -> SignalProducer<NewCelebInfo, CelebrityError> in return CelScoreViewModel().getNewCelebsSignal() }
                    .observeOn(UIScheduler())
                    .on(next: { celebInfo in TAOverlay.showOverlayWithLabel(celebInfo.text, image: UIImage(data: NSData(contentsOfURL: NSURL(string: celebInfo.image)!)!), options: OverlayInfo.getOptions()) })
                    .start()
            }
        }
    }
    
    func facebookTokenCheck() {
        let expirationDate = FBSDKAccessToken.current().expirationDate.stringMMddyyyyFormat().dateFromFormat("MM/dd/yyyy")!
        if expirationDate < Date.today() { self.facebookLogin(false) }
        else { UserViewModel().refreshFacebookTokenSignal() }
    }
    
    func twitterAccessCheck() {
        let account = ACAccountStore()
        let accountType = account.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        account.requestAccessToAccounts(with: accountType, options: nil, completion: {(success: Bool, error: NSError!) -> Void in
            if success == false { Animation.delay(3) { self.sendAlert(.PermissionError, with: SocialLogin.Twitter) }}
        })
    }
    
    func openSettings() {
        SettingsViewModel().loggedInAsSignal()
            .observe(on: UIScheduler())
            .on(starting: { _ in
                self.navigationDrawerController?.isEnabled = true
                self.navigationDrawerController!.setLeftViewWidth(width: Constants.kSettingsViewWidth, isHidden: true, animated: false)
                self.navigationDrawerController!.openLeftView() })
            .on(failed: { _ in
                let alertVC = PMAlertController(title: "Registration", description: OverlayInfo.menuAccess.message(), image: R.image.contract_blue_big()!, style: .alert)
                alertVC.alertTitle.textColor = Constants.kBlueText
                alertVC.addAction(PMAlertAction(title: "I'm ready to register", style: .default, action: { _ in
                    Animation.delay(time: 0.5) { self.handleMenu(true) }
                    self.dismiss(animated: true, completion: nil) }))
                alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
                alertVC.view.isOpaque = false
                self.present(alertVC, animated: true, completion: nil)
            })
            .start()
    }
    
    func setupData() {
        Duration.startMeasurement("setupData")
        let revealingSplashView = RevealingSplashView(iconImage: R.image.celscore_big_white()!,iconInitialSize: CGSize(width: 120, height: 120), backgroundColor: Constants.kBlueShade)
        self.view.addSubview(revealingSplashView)
        
        CelScoreViewModel().getFromAWSSignal(dataType: .ratings)
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .celebrity) }
            .on(starting: { _ in
                Duration.stopMeasurement()
                revealingSplashView.animationType = SplashAnimationType.PopAndZoomOut
                revealingSplashView.startAnimation()})
            .flatMapError { _ in return SignalProducer.empty }
            .flatMap(.latest) { (_) -> SignalProducer<Bool, ListError> in
                return ListViewModel().sanitizeListsSignal() }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NoError> in
                return SettingsViewModel().getSettingSignal(settingType: .defaultListIndex) }
            .on(starting: { (value:AnyObject) in
                self.segmentedControl.setSelectedSegmentIndex(value as! UInt, animated: true)
                self.changeList() })
            .flatMapError { error in
                revealingSplashView.startAnimation()
                self.dismissHUD()
                self.changeList()
                return SignalProducer.empty }
            .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .FirstLaunch) }
            .filter({ (first: AnyObject) -> Bool in let firstTime = first as! Bool
                if firstTime {
                    let alertVC = PMAlertController(title: "Welcome", description: OverlayInfo.WelcomeUser.message(), image: OverlayInfo.WelcomeUser.logo(), style: .Alert)
                    alertVC.alertTitle.textColor = Constants.kBlueText
                    alertVC.addAction(PMAlertAction(title: "I'm ready to vote", style: .Default, action: { _ in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstLaunch).start()
                        self.movingSocialButton(onScreen: true) }))
                    alertVC.view.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.7)
                    alertVC.view.opaque = false
                    MaterialAnimation.delay(2) { self.presentViewController(alertVC, animated: true, completion: nil) }
                }
                return firstTime == false
            })
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (_) -> SignalProducer<NewCelebInfo, CelebrityError> in return CelScoreViewModel().getNewCelebsSignal() }
            .observeOn(QueueScheduler.mainQueueScheduler)
            .on(next: { celebInfo in Animation.delay(1) {
                    TAOverlay.showOverlayWithLabel(celebInfo.text, image: UIImage(data: Data(contentsOfURL: URL(string: celebInfo.image)!)!), options: OverlayInfo.getOptions())
                }
            })
            .start()
    }
    
    func changeList() {
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        ListViewModel().updateListSignal(listId: list.getId())
            .flatMap(.latest) { (_) -> SignalProducer<ListsModel, ListError> in
                return ListViewModel().getListSignal(listId: list.getId()) }
            .observe(on: UIScheduler())
            .startWithValues { list in
                self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId })
                Animation.delay(time: 0.7){ self.celebrityTableView.setContentOffset(CGPointZero, animated:true) }
        }
    }
    
    //MARK: Sociable
    func handleMenu(_ open: Bool = false) {
        let image: UIImage?
        if open || (open == false && self.socialButton.menu.isOpened == false){
            self.socialButton.menu.open() { (v: UIView) in (v as? Button)?.pulse() }
            image = R.image.ic_close_white()?.withRenderingMode(.alwaysTemplate)
            let first: Button? = self.socialButton.menu.views.first as? Button
            first?.animate(animation: Animation.rotate(rotation: 5))
            first?.setImage(image, for: .normal)
            first?.setImage(image, for: .highlighted)
        } else if self.socialButton.menu.isOpened {
            self.socialButton.menu.close()
            image = R.image.ic_add_white()?.withRenderingMode(.alwaysTemplate)
            let first: Button? = self.socialButton.menu.views.first as? Button
            first?.animate(animation: Animation.rotate(rotation: 5))
            first?.setImage(image, for: .normal)
            first?.setImage(image, for: .highlighted)
        }
    }
    
    func movingSocialButton(onScreen: Bool) {
        let y: CGFloat = onScreen ? -70 : 70
        self.socialButton.menu.close()
        let first: Button? = self.socialButton.menu.views.first as? Button
        first!.animate(animation: Animation.animationGroup(animations: [
            Animation.rotate(rotation: 5),
            Animation.translateY(translation: y)
        ]))
    }
    
    func socialButton(_ button: UIButton) { self.socialButtonTapped(buttonTag: button.tag, hideButton: true) }
    
    func socialRefresh() {
        self.diffCalculator.rows = []
        self.changeList()
        self.movingSocialButton(onScreen: false)
    }
    
//    func sendNetworkAlert(splashView: RevealingSplashView) {
//        let alertVC = PMAlertController(title: "No Connection", description: OverlayInfo.TimeoutError.message(), image: R.image.cloud_big_blue()!, style: .Alert)
//        alertVC.alertTitle.textColor = Constants.kBlueText
//        alertVC.addAction(PMAlertAction(title: "Ok", style: .Cancel, action: { _ in
//            self.dismissViewControllerAnimated(true, completion: {
//                splashView.animationType = SplashAnimationType.PopAndZoomOut
//                splashView.startAnimation()
//            })
//        }))
//        alertVC.addAction(PMAlertAction(title: "Contact Us", style: .Default, action: { _ in
//            self.dismissViewControllerAnimated(true, completion: { _ in
//                splashView.animationType = SplashAnimationType.PopAndZoomOut
//                splashView.startAnimation()
//                MaterialAnimation.delay(0.5) { self.sendEmail() }
//            })
//        }))
//        alertVC.view.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.7)
//        alertVC.view.opaque = false
//        self.presentViewController(alertVC, animated: true, completion: nil)
//    }
    
    //MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: ASTableView methods
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 0 }
    
    func tableView(_ tableView: ASTableView, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        var node: ASCellNode = ASCellNode()
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        ListViewModel().getCelebrityStructSignal(listId: self.view.subviews.contains(self.searchBar) ? Constants.kSearchListId : list.getId(), index: indexPath.row)
            .observe(on: UIScheduler())
            .startWithValues({ value in node = CelebrityTableViewCell(celebrityStruct: value) })
        return node
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.movingSocialButton(onScreen: false)
        let node = self.celebrityTableView.nodeForRow(at: indexPath) as! CelebrityTableViewCell
        let detailVC = DetailViewController(celebrityST: node.celebST)
        detailVC.transitioningDelegate = self.transitionManager
        self.transitionManager.setIndexedCell(index: (indexPath as NSIndexPath).row)
        Animation.delay(time: 0.2) { self.present(detailVC, animated: true, completion: nil) }
    }
    
    func showSearchBar() {
        guard self.view.subviews.contains(self.searchBar) == false else { return hideSearchBar() }
         self.searchBar.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.searchBar.alpha = 1.0
            self.searchBar.showsCancelButton = true
            self.searchBar.tintColor = Color.white
            self.searchBar.backgroundColor = Constants.kBlueShade
            self.searchBar.barTintColor = Color.white
            self.searchBar.frame = Constants.kSegmentedControlRect
            self.view.addSubview(self.searchBar)
            self.searchBar.endEditing(true)
            }, completion: { _ in self.searchBar.becomeFirstResponder() })
    }
    
    func hideSearchBar() {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBar.alpha = 0 },
            completion: { _ in
                self.searchBar.removeFromSuperview()
                self.changeList()
        })
    }
    
    //MARK: SideNavigationControllerDelegate
    func navigationDrawerDidClose(_ navigationDrawerController: NavigationDrawerController, position: NavigationDrawerPosition) {
        self.navigationDrawerController?.isEnabled = false
        SettingsViewModel().loggedInAsSignal()
            .on(starting: { _ in self.movingSocialButton(onScreen: false) })
            .on(failed: { _ in
                self.diffCalculator.rows = []
                self.changeList()
                Animation.delay(time: 1.0) { self.movingSocialButton(onScreen: true) }
            })
            .start()
    }
    
    func navigationDrawerWillOpen(_ navigationDrawerController: NavigationDrawerController, position: NavigationDrawerPosition) {
        self.navigationDrawerController!.leftViewController?.viewDidAppear(true)
    }
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { self.hideSearchBar() }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool { return true }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 2 {
            ListViewModel().searchSignal(searchToken: searchText)
                .observe(on: UIScheduler())
                .startWithValues({ list in self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId }) })
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { searchBar.resignFirstResponder() }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { searchBar.resignFirstResponder() }
    
    //MARK: ViewDidLoad Helpers
    func getNavigationView() -> Toolbar {
        let menuButton: FlatButton = FlatButton()
        menuButton.pulseColor = Color.white
        menuButton.pulseAnimation = .none
        menuButton.addTarget(self, action: #selector(MasterViewController.openSettings), for: .touchUpInside)
        menuButton.setImage(R.image.ic_menu_white()!, for: .normal)
        menuButton.setImage(R.image.ic_menu_white()!, for: .highlighted)
        
        let rightButton: FlatButton = FlatButton()
        rightButton.pulseColor = Color.white
        rightButton.pulseAnimation = .none
        rightButton.addTarget(self, action: #selector(MasterViewController.showSearchBar), for: .touchUpInside)
        rightButton.setImage(R.image.ic_search_white()!, for: .normal)
        rightButton.setImage(R.image.ic_search_white()!, for: .highlighted)
        
        let navBar: Toolbar = Toolbar()
        navBar.frame = Constants.kNavigationBarRect
        navBar.leftViews = [menuButton]
        navBar.rightViews = [rightButton]
        navBar.grid.contentEdgeInsets.bottom = 2 * Constants.kPadding
        navBar.backgroundColor = Constants.kRedShade
        let celscoreImageView = UIImageView(image: R.image.score_white()!)
        celscoreImageView.frame = CGRect(x: navBar.width/2 - 3, y: navBar.top/2 + 2.5, width: 25, height: 25)
        navBar.addSubview(celscoreImageView)
        return navBar
    }
    
    func setupSegmentedControl() {
        self.segmentedControl.frame = Constants.kSegmentedControlRect
        self.segmentedControl.backgroundColor = Constants.kBlueShade
        self.segmentedControl.selectionIndicatorColor = Constants.kRedShade
        self.segmentedControl.selectionIndicatorLocation = .down
        self.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : Color.white,
                                                     NSFontAttributeName: UIFont.systemFont(ofSize: 18),
                                                     NSBackgroundColorAttributeName : Constants.kBlueShade]
        self.segmentedControl.selectionStyle = .textWidthStripe
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.isOpaque = true
        self.segmentedControl.clipsToBounds = false
        self.segmentedControl.layer.shadowColor = Color.black.cgColor
        self.segmentedControl.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.segmentedControl.layer.shadowOpacity = 0.3
        self.segmentedControl.isAccessibilityElement = true
        self.segmentedControl.accessibilityLabel = "List Segmented Control"
        self.segmentedControl.addTarget(self, action: #selector(MasterViewController.changeList), for: .valueChanged)
    }
}

