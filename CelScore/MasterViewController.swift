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
import AWSPinpoint


final class MasterViewController: UIViewController, ASTableDataSource, ASTableDelegate, UISearchBarDelegate, NavigationDrawerControllerDelegate, Sociable, MFMailComposeViewControllerDelegate {
    
    //MARK: Properties
    fileprivate let segmentedControl: HMSegmentedControl
    fileprivate let celebSearchBar: UISearchBar
    fileprivate let transitionManager: TransitionManager = TransitionManager()
    fileprivate let diffCalculator: TableViewDiffCalculator<CelebId>
    fileprivate let socialButton: FABMenu
    internal let celebrityTableNode: ASTableNode
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.celebrityTableNode = ASTableNode()
        self.diffCalculator = TableViewDiffCalculator<CelebId>(tableView: self.celebrityTableNode.view)
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
        CelebrityViewModel().removeCelebsNotInPublicOpinionSignal().start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Motion.delay(0.4) {
            if let index = self.celebrityTableNode.indexPathForSelectedRow {
                self.celebrityTableNode.performBatchUpdates({ 
                   self.celebrityTableNode.reloadRows(at: [index], with: .fade)
                }, completion: nil)
            }
            
            SettingsViewModel().loggedInAsSignal()
                .on(failed: { _ in self.movingSocialButton(onScreen: true) })
                .start()
        }
    
        SettingsViewModel().loggedInAsSignal()
            .observe(on: UIScheduler())
            .on(completed: { _ in
                let refresh = TimedLimiter(limit: Constants.kUpdateRatings)
                _ = refresh.execute {
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
                            let token = type == .facebook ? self.facebookToken() : self.twitterAccess()
                            return UserViewModel().loginSignal(token: token, with: type) }
                        .retry(upTo: Constants.kNetworkRetry)
                        .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                            return UserViewModel().updateCognitoSignal(object: "" as AnyObject!, dataSetType: .userRatings) }
                        .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                            return UserViewModel().updateCognitoSignal(object: "" as AnyObject!, dataSetType: .userSettings) }
                        .start()
                }
        }).start()
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
        setupSegmentedControl()
        
        self.view.backgroundColor = Constants.kBlueShade
        self.view.addSubview(navigationBarView)
        self.view.addSubview(self.segmentedControl)
        self.view.addSubview(self.celebrityTableNode.view)

        try! self.setupData()
        
        NotificationCenter.default.reactive.notifications(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            .observeValues { _ in
                
                let refresh = TimedLimiter(limit: Constants.kOneDay)
                _ = refresh.execute {
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
                        .flatMap(.latest) { (_) -> SignalProducer<Bool, NoError> in
                            return ListViewModel().updateListSignal(listId: list.getId()) }
                        .flatMap(.latest) { (_) -> SignalProducer<ListsModel, ListError> in
                            return ListViewModel().getListSignal(listId: list.getId()) }
                        .map { list in self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId }) }
                        .flatMapError { _ in SignalProducer.empty }
                        .flatMap(.latest) { (_) -> SignalProducer<NewCelebInfo, CelebrityError> in return CelScoreViewModel().getNewCelebsSignal() }
                        .observe(on:UIScheduler())
                        .map { celebInfo in TAOverlay.show(withLabel: celebInfo.text, image: UIImage(data: NSData(contentsOf: NSURL(string: celebInfo.image)! as URL)! as Data), options: OverlayInfo.getOptions()) }
                        .start()
                }
        }
    }
    
    func facebookToken() -> String {
        guard let current = FBSDKAccessToken.current() else {
            UserViewModel().refreshFacebookTokenSignal().start()
            return ""
        }
        let expirationDate = current.expirationDate.stringMMddyyyyFormat().date(inFormat:"MM/dd/yyyy")!
        if expirationDate < Date.today() { self.facebookLogin(hideButton: false) }
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
                let alertVC = PMAlertController(title: "To Join", description: OverlayInfo.menuAccess.message(), image: OverlayInfo.menuAccess.logo(), style: .alert)
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
    
    func setupData() throws {
        let revealingSplashView = RevealingSplashView(iconImage: R.image.celscore_big_white()!,iconInitialSize: CGSize(width: 120, height: 120), backgroundColor: Constants.kBlueShade)
        self.view.addSubview(revealingSplashView)
        
        CelScoreViewModel().getFromAWSSignal(dataType: .ratings)
            .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .celebrity) }
            .observe(on: UIScheduler())
            .on(value: { _ in
                revealingSplashView.animationType = SplashAnimationType.popAndZoomOut
                revealingSplashView.startAnimation()
            })
            .flatMapError { _ in return SignalProducer.empty }
            .flatMap(.latest) { (_) -> SignalProducer<Bool, ListError> in
                return ListViewModel().sanitizeListsSignal() }
            .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NoError> in
                return SettingsViewModel().getSettingSignal(settingType: .defaultListIndex) }
            .observe(on: UIScheduler())
            .on(value: { index in
                self.segmentedControl.setSelectedSegmentIndex(UInt(index as! NSNumber), animated: true)
                self.changeList()
            })
            .flatMapError { error in
                revealingSplashView.startAnimation()
                self.dismissHUD()
                self.changeList()
                return SignalProducer.empty }
            .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NoError> in
                return SettingsViewModel().getSettingSignal(settingType: .firstLaunch) }
            .filter({ (first: AnyObject) -> Bool in let firstTime = first as! Bool
                if firstTime {
                    let alertVC = PMAlertController(title: "To Crown", description: OverlayInfo.welcomeUser.message(), image: OverlayInfo.welcomeUser.logo(), style: .alert)
                    alertVC.alertTitle.textColor = Constants.kBlueText
                    alertVC.addAction(PMAlertAction(title: Constants.kAlertAction, style: .default, action: { _ in
                        self.dismiss(animated: true, completion: nil)
                        SettingsViewModel().updateSettingSignal(value: false as AnyObject, settingType: .firstLaunch).start()
                        self.movingSocialButton(onScreen: true)
                    }))
                    alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
                    alertVC.view.isOpaque = false
                    Motion.delay(2) { self.present(alertVC, animated: true, completion: nil) }
                }
                return firstTime == false
            })
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.latest) { (_) -> SignalProducer<NewCelebInfo, CelebrityError> in return CelScoreViewModel().getNewCelebsSignal() }
            .on(value: { celebInfo in Motion.delay(1) {
                    TAOverlay.show(withLabel: celebInfo.text, image: UIImage(data: try! Data(contentsOf: URL(string: celebInfo.image)!)), options: OverlayInfo.getOptions())
                }
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
    
    func fabMenuDidOpen(fabMenu: FABMenu) {
        print("Yelllllaaaaw!!!")
    }

    func handleMenu(open: Bool = false) {
        let image: UIImage?
        if open || (open == false && self.socialButton.isOpened == false){
            self.socialButton.open() { (v: UIView) in (v as? Button)?.pulse() }
            image = R.image.ic_close_white()?.withRenderingMode(.alwaysTemplate)
            self.socialButton.fabButton?.motionRotationAngle = 45.0
            self.socialButton.fabButton?.setImage(image, for: .normal)
            self.socialButton.fabButton?.setImage(image, for: .highlighted)
        } else if self.socialButton.isOpened {
            self.socialButton.close()
            image = R.image.ic_add_white()?.withRenderingMode(.alwaysTemplate)
            self.socialButton.fabButton?.motionRotationAngle = 45.0
            self.socialButton.fabButton?.setImage(image, for: .normal)
            self.socialButton.fabButton?.setImage(image, for: .highlighted)
        }
    }

    func movingSocialButton(onScreen: Bool) {
        let y: CGFloat = onScreen ? 0 : 70
        self.socialButton.close()
        self.socialButton.fabButton?.motion([MotionAnimation.translateY(y), MotionAnimation.rotationAngle(45)])
    }
    
    func socialButton(button: UIButton) { self.socialButtonTapped(buttonTag: button.tag, hideButton: true) }
    
    func socialRefresh() {
        self.diffCalculator.rows = []
        self.changeList()
        self.movingSocialButton(onScreen: false)
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: ASTableView methods
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return self.diffCalculator.rows.count }
    
    func tableView(_ tableView: ASTableView, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        var node: ASCellNode = ASCellNode()
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        ListViewModel().getCelebrityStructSignal(listId: (self.view.subviews as [UIView]).contains(self.celebSearchBar) ? Constants.kSearchListId : list.getId(), index: indexPath.row)
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
        let celscoreImageView = UIImageView(image: R.image.score_white()!)
        celscoreImageView.frame = CGRect(x: navBar.width/2 - 3, y: navBar.top/2, width: 25, height: 25)
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

