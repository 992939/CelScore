//
//  MasterViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import ReactiveCocoa
import Material
import HMSegmentedControl
import RateLimit
import Dwifft
import Result
import RevealingSplashView


final class MasterViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, UISearchBarDelegate, SideNavigationControllerDelegate, Sociable {
    
    //MARK: Properties
    private let segmentedControl: HMSegmentedControl
    private let searchBar: UISearchBar
    private let transitionManager: TransitionManager = TransitionManager()
    private let diffCalculator: TableViewDiffCalculator<CelebId>
    internal let celebrityTableView: ASTableView
    internal let socialButton: MenuView
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.celebrityTableView = ASTableView()
        self.diffCalculator = TableViewDiffCalculator<CelebId>(tableView: self.celebrityTableView)
        self.diffCalculator.insertionAnimation = .Fade
        self.diffCalculator.deletionAnimation = .Fade
        self.segmentedControl = HMSegmentedControl(sectionTitles: ListInfo.getAllNames())
        self.socialButton = MenuView()
        self.searchBar = UISearchBar()
        super.init(nibName: nil, bundle: nil)
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
    }
    
    //MARK: Methods
    override func prefersStatusBarHidden() -> Bool { return true }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideNavigationController?.delegate = self
        self.sideNavigationController?.enabled = false
        self.sideNavigationController?.animationDuration = 0.4
        
        MaterialAnimation.delay(0.7) {
            if self.socialButton.hidden == true {
                if let index = self.celebrityTableView.indexPathForSelectedRow {
                    self.celebrityTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .None)
                }
            } else { SettingsViewModel().loggedInAsSignal().startWithNext { _ in self.socialRefresh() }}
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        CelebrityViewModel().removeCelebsNotInPublicOpinionSignal().start()
        
        SettingsViewModel().loggedInAsSignal().startWithNext { _ in
            guard Reachability.isConnectedToNetwork() else {
                return TAOverlay.showOverlayWithLabel(OverlayInfo.NetworkError.message(), image: OverlayInfo.NetworkError.logo(), options: OverlayInfo.getOptions()) }
            RateLimit.execute(name: "updateRatings", limit: Constants.kUpdateRatings) {
                CelScoreViewModel().getFromAWSSignal(dataType: .Ratings)
                    .observeOn(UIScheduler())
                    .flatMapError { _ in SignalProducer.empty }
                    .flatMap(.Latest) { (_) -> SignalProducer<CGFloat, NoError> in
                        return SettingsViewModel().calculateUserAverageCelScoreSignal() }
                    .filter({ (score:CGFloat) -> Bool in score > Constants.kTrollingThreshold })
                    .flatMapError { _ in SignalProducer.empty }
                    .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                        return SettingsViewModel().getSettingSignal(settingType: .LoginTypeIndex) }
                    .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                        let type = SocialLogin(rawValue:value as! Int)!
                        let token = type == .Facebook ? FBSDKAccessToken.currentAccessToken().tokenString : ""
                        return UserViewModel().loginSignal(token: token, with: type) }
                    .retry(Constants.kNetworkRetry)
                    .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                        return UserViewModel().updateCognitoSignal(object: "", dataSetType: .UserRatings) }
                    .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                        return UserViewModel().updateCognitoSignal(object: "", dataSetType: .UserSettings) }
                    .start()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.celebrityTableView.frame = Constants.kCelebrityTableViewRect
        self.celebrityTableView.asyncDataSource = self
        self.celebrityTableView.asyncDelegate = self
        self.celebrityTableView.separatorStyle = .None
        self.celebrityTableView.backgroundColor = MaterialColor.clear
        self.socialButton.hidden = false
        
        let attr = [NSForegroundColorAttributeName: MaterialColor.white, NSFontAttributeName : UIFont.systemFontOfSize(14.0)]
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).defaultTextAttributes = attr
        self.searchBar.delegate = self
        self.searchBar.searchBarStyle = .Minimal
        
        let navigationBarView: Toolbar = self.getNavigationView()
        self.setupSegmentedControl()
        self.setUpSocialButton(self.socialButton, controller: self, origin: CGPoint(x: Constants.kScreenWidth - 65, y: Constants.kScreenHeight - 70), buttonColor: Constants.kDarkGreenShade)
        self.view.backgroundColor = Constants.kDarkShade
        self.view.addSubview(navigationBarView)
        self.view.addSubview(self.segmentedControl)
        self.view.addSubview(self.celebrityTableView)
        self.view.addSubview(self.socialButton)
        MaterialLayout.size(self.view, child: self.socialButton, width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        self.setupData()
        
        NSNotificationCenter.defaultCenter().rac_notifications(UIApplicationWillEnterForegroundNotification, object: nil).startWithNext { _ in
            guard Reachability.isConnectedToNetwork() else { return }
            RateLimit.execute(name: "updateFromAWS", limit: 10) { //TODO: Constants.kDayInSeconds) {
                let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
                CelScoreViewModel().getFromAWSSignal(dataType: .Celebrity)
                    .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                        return CelScoreViewModel().getFromAWSSignal(dataType: .Ratings) }
                    .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                        return CelScoreViewModel().getFromAWSSignal(dataType: .List) }
                    .observeOn(UIScheduler())
                    .flatMapError { _ in SignalProducer.empty }
                    .flatMap(.Latest) { (_) -> SignalProducer<Bool, ListError> in
                        return ListViewModel().sanitizeListsSignal() }
                    .flatMap(.Latest) { (_) -> SignalProducer<Bool, ListError> in
                        return ListViewModel().updateListSignal(listId: list.getId()) }
                    .flatMap(.Latest) { (_) -> SignalProducer<ListsModel, ListError> in
                        return ListViewModel().getListSignal(listId: list.getId()) }
                    .on(next: { list in self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId }) })
                    .flatMapError { _ in SignalProducer.empty }
                    .flatMap(.Latest) { (_) -> SignalProducer<NewCelebInfo, CelebrityError> in return CelScoreViewModel().getNewCelebsSignal() }
                    .observeOn(UIScheduler())
                    .on(next: { celebInfo in TAOverlay.showOverlayWithLabel(celebInfo.text, image: UIImage(data: NSData(contentsOfURL: NSURL(string: celebInfo.image)!)!), options: OverlayInfo.getOptions()) })
                    .start()
            }
        }
    }
    
    func openSettings() {
        SettingsViewModel().loggedInAsSignal()
            .observeOn(UIScheduler())
            .on(next: { _ in
                self.sideNavigationController?.enabled = true
                self.sideNavigationController!.setLeftViewWidth(Constants.kSettingsViewWidth, hidden: true, animated: false)
                self.sideNavigationController!.openLeftView() })
            .on(failed: { _ in
                TAOverlay.showOverlayWithLabel(OverlayInfo.MenuAccess.message(), image: OverlayInfo.MenuAccess.logo(), options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in self.socialButton.menu.open() }) })
            .start()
    }
    
    func setupData() {
        Duration.startMeasurement("setupData")
        let revealingSplashView = RevealingSplashView(iconImage: R.image.celscore_big_white()!,iconInitialSize: CGSizeMake(120, 120), backgroundColor: Constants.kDarkShade)
        self.view.addSubview(revealingSplashView)
        guard Reachability.isConnectedToNetwork() else { return revealingSplashView.startAnimation() }
        CelScoreViewModel().getFromAWSSignal(dataType: .Ratings)
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .Celebrity) }
            .observeOn(UIScheduler())
            .on(next: { _ in
                Duration.stopMeasurement()
                revealingSplashView.animationType = SplashAnimationType.SqueezeAndZoomOut
                revealingSplashView.startAnimation()})
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (_) -> SignalProducer<Bool, ListError> in
                return ListViewModel().sanitizeListsSignal() }
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .DefaultListIndex) }
            .timeoutWithError(NetworkError.TimedOut as NSError, afterInterval: Constants.kTimeout, onScheduler: QueueScheduler.mainQueueScheduler)
            .flatMapError { error in if error.domain == "CelebrityScore.NetworkError" && error.code == NetworkError.TimedOut.hashValue {
                TAOverlay.showOverlayWithLabel(OverlayInfo.TimeoutError.message(), image: OverlayInfo.TimeoutError.logo(), options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in revealingSplashView.startAnimation() })
                }
                return SignalProducer.empty }
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<ListsModel, ListError> in
                self.segmentedControl.setSelectedSegmentIndex(value as! UInt, animated: true)
                return ListViewModel().getListSignal(listId: ListInfo(rawValue: (value as! Int))!.getId()) }
            .on(next: { list in self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId }) })
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .FirstLaunch) }
            .delay(3, onScheduler: QueueScheduler.mainQueueScheduler)
            .on(next: { first in let firstTime = first as! Bool
                if firstTime {
                    TAOverlay.showOverlayWithLabel(OverlayInfo.WelcomeUser.message(), image: OverlayInfo.WelcomeUser.logo(), options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstLaunch).start() })
                }})
            .start()
    }
    
    func changeList() {
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        ListViewModel().updateListSignal(listId: list.getId())
            .observeOn(UIScheduler())
            .flatMap(.Latest) { (_) -> SignalProducer<ListsModel, ListError> in
                return ListViewModel().getListSignal(listId: list.getId()) }
            .startWithNext { list in self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId }) }
    }
    
    //MARK: Sociable
    func handleMenu(open: Bool = false) {
        let image: UIImage?
        if self.socialButton.menu.opened {
            self.socialButton.menu.close()
            image = R.image.ic_add_white()?.imageWithRenderingMode(.AlwaysTemplate)
        } else {
            self.socialButton.menu.open() { (v: UIView) in (v as? MaterialButton)?.pulse() }
            image = R.image.ic_close_white()?.imageWithRenderingMode(.AlwaysTemplate)
        }
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        first?.animate(MaterialAnimation.rotate(rotation: 1))
        first?.setImage(image, forState: .Normal)
        first?.setImage(image, forState: .Highlighted)
    }
    
    func socialButton(button: UIButton) { self.socialButtonTapped(buttonTag: button.tag, from: self, hideButton: true) }
    
    func socialRefresh() {
        self.diffCalculator.rows = []
        self.changeList()
        SettingsViewModel().loggedInAsSignal().startWithNext { _ in self.hideSocialButton(self.socialButton, controller: self) }
    }
    
    //MARK: ASTableView methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 0 }
    
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        var node: ASCellNode = ASCellNode()
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        ListViewModel().getCelebrityStructSignal(listId: self.view.subviews.contains(self.searchBar) ? Constants.kSearchListId : list.getId(), index: indexPath.row)
            .observeOn(UIScheduler())
            .startWithNext({ value in node = CelebrityTableViewCell(celebrityStruct: value) })
        return node
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let node = self.celebrityTableView.nodeForRowAtIndexPath(indexPath) as! CelebrityTableViewCell
        let detailVC = DetailViewController(celebrityST: node.celebST)
        detailVC.transitioningDelegate = self.transitionManager
        self.transitionManager.setIndexedCell(index: indexPath.row)
        self.presentViewController(detailVC, animated: true, completion: nil)
    }
    
    func showSearchBar() {
        if self.view.subviews.contains(self.searchBar) { hideSearchBar() }
        else {
             self.searchBar.alpha = 0.0
            UIView.animateWithDuration(0.5, animations: {
                self.searchBar.alpha = 1.0
                self.searchBar.showsCancelButton = true
                self.searchBar.tintColor = Constants.kWineShade
                self.searchBar.backgroundColor = Constants.kDarkShade
                self.searchBar.barTintColor = MaterialColor.white
                self.searchBar.frame = Constants.kSegmentedControlRect
                self.view.addSubview(self.searchBar)
                self.searchBar.endEditing(true)
                }, completion: { _ in self.searchBar.becomeFirstResponder() })
        }
    }
    
    func hideSearchBar() {
        UIView.animateWithDuration(0.3, animations: {
            self.searchBar.alpha = 0 },
            completion: { _ in
                self.searchBar.removeFromSuperview()
                self.changeList()
        })
    }
    
    //MARK: SideNavigationControllerDelegate
    func sideNavigationDidClose(sideNavigationController: SideNavigationController, position: SideNavigationPosition) {
        self.sideNavigationController?.enabled = false
        self.showSocialButton(self.socialButton, controller: self)
        SettingsViewModel().loggedInAsSignal()
            .on(next: { _ in self.hideSocialButton(self.socialButton, controller: self) })
            .on(failed: { _ in self.diffCalculator.rows = []; self.changeList()  })
            .start()
    }
    
    func sideNavigationWillOpen(sideNavigationController: SideNavigationController, position: SideNavigationPosition) {
        self.sideNavigationController!.leftViewController?.viewDidAppear(true)
    }
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) { self.hideSearchBar() }
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool { return true }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 2 {
            ListViewModel().searchSignal(searchToken: searchText)
                .observeOn(UIScheduler())
                .startWithNext({ list in self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId }) })
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: ViewDidLoad Helpers
    func getNavigationView() -> Toolbar {
        let menuButton: FlatButton = FlatButton()
        menuButton.pulseColor = MaterialColor.white
        menuButton.pulseAnimation = .None
        menuButton.addTarget(self, action: #selector(MasterViewController.openSettings), forControlEvents: .TouchUpInside)
        menuButton.setImage(R.image.ic_menu_white()!, forState: .Normal)
        menuButton.setImage(R.image.ic_menu_white()!, forState: .Highlighted)
        
        let rightButton: FlatButton = FlatButton()
        rightButton.pulseColor = MaterialColor.white
        rightButton.pulseAnimation = .None
        rightButton.addTarget(self, action: #selector(MasterViewController.showSearchBar), forControlEvents: .TouchUpInside)
        rightButton.setImage(R.image.ic_search_white()!, forState: .Normal)
        rightButton.setImage(R.image.ic_search_white()!, forState: .Highlighted)
        
        let navBar: Toolbar = Toolbar()
        navBar.leftControls = [menuButton]
        navBar.rightControls = [rightButton]
        navBar.backgroundColor = Constants.kMainShade
        let celscoreImageView = UIImageView(image: R.image.score_white()!)
        celscoreImageView.frame = CGRect(x: navBar.width/2, y: navBar.centerY - 2, width: 25, height: 25)
        navBar.addSubview(celscoreImageView)
        return navBar
    }
    
    func setupSegmentedControl() {
        self.segmentedControl.frame = Constants.kSegmentedControlRect
        self.segmentedControl.backgroundColor = Constants.kDarkShade
        self.segmentedControl.selectionIndicatorColor = Constants.kWineShade
        self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        self.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : MaterialColor.white,
                                                     NSFontAttributeName: UIFont.systemFontOfSize(18),
                                                     NSBackgroundColorAttributeName : Constants.kDarkShade]
        self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.opaque = true
        self.segmentedControl.clipsToBounds = false
        self.segmentedControl.layer.shadowColor = MaterialColor.black.CGColor
        self.segmentedControl.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.segmentedControl.layer.shadowOpacity = 0.3
        self.segmentedControl.addTarget(self, action: #selector(MasterViewController.changeList), forControlEvents: .ValueChanged)
    }
}

