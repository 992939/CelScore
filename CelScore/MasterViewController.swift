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
import Result
import Material
import HMSegmentedControl
import RateLimit
import Dwifft
import PMAlertController
import RevealingSplashView
import FBSDKCoreKit
import Accounts
import NotificationCenter


final class MasterViewController: UIViewController, ASTableDataSource, ASTableDelegate, UISearchBarDelegate, NavigationDrawerControllerDelegate, Sociable {
    
    //MARK: Properties
    fileprivate let segmentedControl: HMSegmentedControl
    fileprivate let celebSearchBar: UISearchBar
    fileprivate let transitionManager: TransitionManager = TransitionManager()
    fileprivate let diffCalculator: SingleSectionTableViewDiffCalculator<CelebId>
    fileprivate let socialButton: FABMenu
    internal let celebrityTableNode: ASTableNode
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.celebrityTableNode = ASTableNode()
        self.diffCalculator = SingleSectionTableViewDiffCalculator<CelebId>(tableView: self.celebrityTableNode.view)
        self.diffCalculator.insertionAnimation = .fade
        self.diffCalculator.deletionAnimation = .fade
        self.segmentedControl = HMSegmentedControl(sectionTitles: ListInfo.getAllNames())
        self.socialButton = FABMenu()
        self.celebSearchBar = UISearchBar()
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Motion.delay(0.4) {
            if let index = self.celebrityTableNode.indexPathForSelectedRow {
                self.celebrityTableNode.performBatchUpdates({ 
                   self.celebrityTableNode.reloadRows(at: [index], with: .fade)
                }, completion: nil)
            }
        }
    
        SettingsViewModel().loggedInAsSignal()
            .observe(on: UIScheduler())
            .on(value: { _ in
                self.movingSocialButton(onScreen: false)
                
                let hourly = TimedLimiter(limit: 60 * Constants.kOneMinute)
                _ = hourly.execute {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    
                    SettingsViewModel().getSettingSignal(settingType: .lastVisit)
                        .filter({ lastVisit -> Bool in
                            guard (lastVisit as! String).characters.count > 0 else { return true }
                            let visit = dateFormatter.date(from: lastVisit as! String)!
                            let today = dateFormatter.date(from: Date().stringMMddyyyyFormat())!
                            let isToday = visit.compare(today) != ComparisonResult.orderedAscending
                            return isToday })
                        .delay(2, on: QueueScheduler.main)
                        .flatMap(.latest) { (_) -> SignalProducer<String, NoError> in
                            return CelebrityViewModel().getWelcomeRuleMessageSignal() }
                        .on(value: { message in self.displaySnack(message: message, icon: .crown) })
                        .flatMap(.latest) { (_) -> SignalProducer<SettingsModel, NSError> in
                            let today = dateFormatter.string(from: Date()) as AnyObject
                            return SettingsViewModel().updateSettingSignal(value: today, settingType: .lastVisit) }
                        .mapError({ (error: NSError) -> ListError in return ListError(rawValue: 1)! })
                        .flatMap(.latest) { (_) -> SignalProducer<Bool, ListError> in
                            return ListViewModel().sanitizeListsSignal() }
                        .start()
                }
                
                let refresh = TimedLimiter(limit: 2 * Constants.kOneMinute)
                _ = refresh.execute {
                    CelScoreViewModel().getFromAWSSignal(dataType: .list)
                        .observe(on: UIScheduler())
                        .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                            return CelScoreViewModel().getFromAWSSignal(dataType: .ratings) }
                        .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                            return CelScoreViewModel().getFromAWSSignal(dataType: .celebrity) }
                        .flatMap(.latest) { (value:AnyObject) -> SignalProducer<CGFloat, NoError> in
                            return SettingsViewModel().calculateAverageRoyaltySignal() }
                        .flatMap(.latest) { (_) -> SignalProducer<CGFloat, NoError> in
                            return SettingsViewModel().calculateUserAverageCelScoreSignal() }
                        .filter({ (score: CGFloat) -> Bool in score > Constants.kTrollingThreshold })
                        .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NoError> in
                            return SettingsViewModel().getSettingSignal(settingType: .loginTypeIndex) }
                        .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                            let type = SocialLogin(rawValue:value as! Int)!
                            let token = type == .facebook ? self.facebookToken() : self.twitterAccess()
                            return UserViewModel().loginSignal(token: token, with: type) }
                        .retry(upTo: Constants.kNetworkRetry)
                        .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                            return UserViewModel().updateCognitoSignal(object: "" as AnyObject!, dataSetType: .userRatings) }
                        .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                            return UserViewModel().updateCognitoSignal(object: "" as AnyObject!, dataSetType: .userSettings) }
                        .flatMapError { _ in SignalProducer.empty }
                        .flatMap(.latest) { (value:AnyObject) -> SignalProducer<Int, NoError> in
                            return CelebrityViewModel().removeCelebsNotInPublicOpinionSignal() }
                        .start()
                }})
            .on(failed: { _ in self.movingSocialButton(onScreen: true) })
            .start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.celebrityTableNode.frame = Constants.kcelebrityTableNodeRect
        self.celebrityTableNode.backgroundColor = Color.clear
        self.celebrityTableNode.dataSource = self
        self.celebrityTableNode.delegate = self
        
        let attr = [NSForegroundColorAttributeName: Color.white, NSFontAttributeName : UIFont.systemFont(ofSize: 14.0)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attr
        self.celebSearchBar.delegate = self
        self.celebSearchBar.searchBarStyle = .minimal
        
        let navigationBarView: Toolbar = self.getNavigationView()
        self.setUpSocialButton(menu: self.socialButton, buttonColor: Constants.kRedShade)
        self.setupSegmentedControl()
        
        self.view.backgroundColor = Constants.kBlueShade
        self.view.addSubview(navigationBarView)
        self.view.addSubview(self.segmentedControl)
        self.view.addSubview(self.celebrityTableNode.view)
        self.view.layout(socialButton).size(CGSize(width: Constants.kFabDiameter, height: Constants.kFabDiameter)).bottom(2*Constants.kPadding).right(2 * Constants.kPadding)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationCallback), name: .onSelectedBox, object: nil)
        self.setupData()
    }
    
    func setupData() {
        let revealingSplashView = RevealingSplashView(iconImage: R.image.logo_big_white()!,
                                                      iconInitialSize: CGSize(width: 400, height: 400),
                                                      backgroundColor: Constants.kBlueShade)
        revealingSplashView.animationType = SplashAnimationType.popAndZoomOut
        self.view.addSubview(revealingSplashView)
        
        CelScoreViewModel().getFromAWSSignal(dataType: .list)
            .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .ratings) }
            .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .celebrity) }
            .observe(on: UIScheduler())
            .on(value: { _ in
                revealingSplashView.startAnimation()
                self.segmentedControl.setSelectedSegmentIndex(0, animated: true)
                self.changeList() })
            .on(failed: { _ in
                revealingSplashView.startAnimation()
                self.changeList() })
            .start()
    }
    
    func notificationCallback(withNotification notification: NSNotification) {
        Motion.delay(0.8){ self.displaySnack(message: notification.userInfo!["message"] as! String, icon: .alert) }
    }
    
    func facebookToken() -> String {
        guard let current = FBSDKAccessToken.current() else {
            UserViewModel().refreshFacebookTokenSignal().start()
            return ""
        }
        if current.expirationDate < Date() { self.facebookLogin(hideButton: false) }
        else { UserViewModel().refreshFacebookTokenSignal().start() }
        return current.tokenString
    }
    
    func twitterAccess() -> String {
        let account = ACAccountStore()
        let accountType = account.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        account.requestAccessToAccounts(with: accountType, options: nil) { (success: Bool, error: Error?) in
            if success == false { Motion.delay(3) { self.sendAlert(.permissionError, with: SocialLogin.twitter) }}
        }
        return ""
    }
    
    func openSettings() {
        SettingsViewModel().loggedInAsSignal()
            .observe(on: UIScheduler())
            .on(completed: { _ in
                self.navigationDrawerController?.isEnabled = true
                self.navigationDrawerController!.setLeftViewWidth(width: Constants.kSettingsViewWidth, isHidden: true, animated: false)
                self.navigationDrawerController!.openLeftView() })
            .on(failed: { _ in
                let alertVC = PMAlertController(title: Constants.kAlertName, description: OverlayInfo.menuAccess.message(), image: OverlayInfo.menuAccess.logo(), style: .alert)
                alertVC.alertTitle.textColor = Constants.kBlueText
                alertVC.addAction(PMAlertAction(title: Constants.kAlertAction, style: .default, action: { _ in
                    Motion.delay(0.5) { self.handleMenu(open: true) }
                    self.dismiss(animated: true, completion: nil) }))
                alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
                alertVC.view.isOpaque = false
                self.present(alertVC, animated: true, completion: nil)
            })
            .start()
    }
    
    func changeList() {
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        ListViewModel().updateListSignal(listId: list.getId())
            .observe(on: UIScheduler())
            .flatMap(.latest) { (_) -> SignalProducer<ListsModel, ListError> in
                return ListViewModel().getListSignal(listId: list.getId()) }
            .on(value: { list in
                self.diffCalculator.rows = list.celebList.flatMap{ return $0 }
                Motion.delay(0.7){ self.celebrityTableNode.view.setContentOffset(CGPoint.zero, animated:true) }})
            .start()
    }
    
    //MARK: Sociable
    func fabMenuWillOpen(fabMenu: FABMenu) {
        self.handleMenu(open: true)
    }
    
    func fabMenuWillClose(fabMenu: FABMenu) {
        self.handleMenu(open: false)
    }

    func handleMenu(open: Bool = false) {
        let image: UIImage?
        if open || (open == false && self.socialButton.isOpened == false){
            self.socialButton.open() { (v: UIView) in (v as? Button)?.pulse() }
            image = R.image.ic_close_white()?.withRenderingMode(.alwaysTemplate)
            self.socialButton.fabButton?.layer.animate(MotionAnimation.spin(z: 0.25))
            self.socialButton.fabButton?.setImage(image, for: .normal)
            self.socialButton.fabButton?.setImage(image, for: .highlighted)
        } else if self.socialButton.isOpened {
            self.socialButton.close()
            image = R.image.ic_add_white()?.withRenderingMode(.alwaysTemplate)
            self.socialButton.fabButton?.layer.animate(MotionAnimation.spin(z: 0.5))
            self.socialButton.fabButton?.setImage(image, for: .normal)
            self.socialButton.fabButton?.setImage(image, for: .highlighted)
        }
    }

    func movingSocialButton(onScreen: Bool) {
        self.socialButton.animate(
            .spin(z: 1.0),
            .translate(x: 0, y: onScreen ? 0 : 70, z: 0),
            .completion({ [weak self] in self?.socialButton.close() }))
    }
    
    func socialButton(button: UIButton) { self.socialButtonTapped(buttonTag: button.tag, hideButton: true) }
    
    func socialRefresh() {
        self.diffCalculator.rows = []
        self.changeList()
        self.movingSocialButton(onScreen: false)
    }
    
    //MARK: ASTableView methods
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return self.diffCalculator.rows.count }
    
    func tableView(_ tableView: ASTableView, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        var node: ASCellNode = ASCellNode()
        CelebrityViewModel().getCelebrityStructSignal(id: self.diffCalculator.rows[indexPath.row].id)
            .observe(on: UIScheduler())
            .on(value: { value in node = celebrityTableNodeCell(celebrityStruct: value) })
            .start()
        return node
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.movingSocialButton(onScreen: false)
        let node = self.celebrityTableNode.nodeForRow(at: indexPath) as! celebrityTableNodeCell
        let detailVC = DetailViewController(celebrityST: node.celebST)
        detailVC.transitioningDelegate = self.transitionManager
        self.transitionManager.setIndexedCell(index: (indexPath as NSIndexPath).row)
        Motion.delay(0.2) { self.present(detailVC, animated: true, completion: nil) }
    }
    
    func showSearchBar() {
        guard self.view.subviews.contains(self.celebSearchBar) == false else { return hideSearchBar() }
         self.celebSearchBar.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.celebSearchBar.alpha = 1.0
            self.celebSearchBar.showsCancelButton = true
            self.celebSearchBar.tintColor = Color.white
            self.celebSearchBar.backgroundColor = Constants.kBlueShade
            self.celebSearchBar.barTintColor = Color.white
            self.celebSearchBar.frame = Constants.kSegmentedControlRect
            self.view.addSubview(self.celebSearchBar)
            self.celebSearchBar.endEditing(true)
            }, completion: { _ in self.celebSearchBar.becomeFirstResponder() })
    }
    
    func hideSearchBar() {
        UIView.animate(withDuration: 0.3, animations: {
            self.celebSearchBar.alpha = 0 },
            completion: { _ in
                self.celebSearchBar.removeFromSuperview()
                self.changeList()
        })
    }
    
    //MARK: NavigationDrawerControllerDelegate
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, didClose position: NavigationDrawerPosition) {
        self.navigationDrawerController?.isEnabled = false
        SettingsViewModel().loggedInAsSignal()
            .on(value: { _ in self.movingSocialButton(onScreen: false) })
            .on(failed: { _ in
                self.diffCalculator.rows = []
                self.changeList()
                Motion.delay(1.0) { self.movingSocialButton(onScreen: true)
                }
            })
            .start()
    }
    
    func navigationDrawerController(navigationDrawerController: NavigationDrawerController, willOpen position: NavigationDrawerPosition) {
        self.navigationDrawerController!.leftViewController?.viewDidAppear(true)
    }
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { self.hideSearchBar() }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool { return true }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 2 {
            ListViewModel().searchSignal(searchToken: searchText)
                .observe(on: UIScheduler())
                .on(value: { list in self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId }) })
                .start()
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
        navBar.backgroundColor = Constants.kRedShade
        navBar.title = "Celeb&Noble"
        navBar.titleLabel.textColor = .white
        navBar.titleLabel.font = UIFont.boldSystemFont(ofSize: UIDevice.getFontSize() + 1)
        return navBar
    }
    
    func setupSegmentedControl() {
        self.segmentedControl.frame = Constants.kSegmentedControlRect
        self.segmentedControl.backgroundColor = Constants.kBlueShade
        self.segmentedControl.selectionIndicatorColor = Constants.kRedShade
        self.segmentedControl.selectionIndicatorLocation = .down
        self.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : Color.white,
                                                     NSFontAttributeName: UIFont.boldSystemFont(ofSize: UIDevice.getFontSize() + 1),
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

