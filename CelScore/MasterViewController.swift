//
//  MasterViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import FBSDKLoginKit
import ReactiveCocoa
import RealmSwift
import TwitterKit
import Material
import HMSegmentedControl
import AIRTimer
import RateLimit
import Dwifft


final class MasterViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, UISearchBarDelegate, SideNavigationControllerDelegate, Sociable, HUDable {
    
    //MARK: Properties
    private let segmentedControl: HMSegmentedControl
    private let searchBar: UISearchBar
    private let transitionManager = TransitionManager()
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
        
        //UNIT TEST: SettingsViewModel().loggedInAsSignal().startWithNext { name in print(name) }
    }
    
    //MARK: Methods
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sideNavigationController?.delegate = self
        MaterialAnimation.delay(0.7) {
            if let index = self.celebrityTableView.indexPathForSelectedRow {
                if self.socialButton.hidden == true { self.celebrityTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .None) }
                else { SettingsViewModel().loggedInAsSignal().startWithNext { _ in self.socialRefresh() }}
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SettingsViewModel().loggedInAsSignal().startWithNext { _ in
            self.hideSocialButton(self.socialButton)
            RateLimit.execute(name: "updateUserRatingsOnAWS", limit: 10) {
                SettingsViewModel().calculateUserAverageCelScoreSignal()
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
        self.setUpSocialButton(self.socialButton, controller: self, origin: CGPoint(x: Constants.kScreenWidth - 80, y: Constants.kScreenHeight - 70), buttonColor: Constants.kDarkGreenShade)
        self.view.backgroundColor = Constants.kDarkShade
        self.view.addSubview(navigationBarView)
        self.view.addSubview(self.segmentedControl)
        self.view.addSubview(self.celebrityTableView)
        self.view.addSubview(self.socialButton)
        MaterialLayout.size(self.view, child: self.socialButton, width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        self.setupData()
        
        NSNotificationCenter.defaultCenter().rac_notifications(UIApplicationWillEnterForegroundNotification, object: nil)
            .startWithNext { _ in
                RateLimit.execute(name: "DailyAWSRefresh", limit: 10) {
                    CelScoreViewModel().getFromAWSSignal(dataType: .List)
                        .observeOn(UIScheduler())
                        .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                            return CelScoreViewModel().getFromAWSSignal(dataType: .Celebrity) }
                        .flatMapError { _ in SignalProducer.empty }
                        .flatMap(.Latest) { (_) -> SignalProducer<ListsModel, ListError> in
                            let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
                            return ListViewModel().updateListSignal(listId: list.getId() )}
                        .observeOn(UIScheduler())
                        .on(next: { list in
                            self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId }) })
                        .start()
                }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.celebrityTableView.frame = Constants.kCelebrityTableViewRect
    }
    
    func openSettings() {
        SettingsViewModel().loggedInAsSignal()
            .observeOn(UIScheduler())
            .on(next: { _ in
                self.sideNavigationController!.setLeftViewWidth(Constants.kSettingsViewWidth, hidden: true, animated: false)
                self.sideNavigationController!.openLeftView() })
            .on(failed: { _ in
                TAOverlay.showOverlayWithLabel(OverlayInfo.MenuAccess.message(), image: OverlayInfo.MenuAccess.logo(), options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in self.socialButton.menu.open() }) })
            .start()
    }
    
    func setupData() {
        self.showHUD()
        CelScoreViewModel().getFromAWSSignal(dataType: .Ratings)
            .observeOn(UIScheduler())
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .List) }
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .Celebrity) }
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .DefaultListIndex) }
            .flatMapError { _ in SignalProducer.empty }
            .observeOn(UIScheduler())
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<ListsModel, ListError> in
                self.segmentedControl.setSelectedSegmentIndex(value as! UInt, animated: true)
                return ListViewModel().getListSignal(listId: ListInfo(rawValue: (value as! Int))!.getId()) }
            .on(next: { list in
                self.diffCalculator.rows = list.celebList.flatMap({ celebId in return celebId })
                self.dismissHUD() })
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .FirstLaunch) }
            .on(next: { first in let firstTime = first as! Bool
                if firstTime {
                    TAOverlay.showOverlayWithLabel(OverlayInfo.WelcomeUser.message(), image: OverlayInfo.WelcomeUser.logo(), options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstLaunch).start() })
                }})
            .start()
    }
    
    func changeList() {
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        ListViewModel().getListSignal(listId: list.getId())
            .observeOn(UIScheduler())
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
    
    func socialRefresh() { self.diffCalculator.rows = []; self.changeList() }
    
    //MARK: ASTableView methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 0 }
    
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        var node = ASCellNode()
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        ListViewModel().getCelebrityStructSignal(listId: self.view.subviews.contains(self.searchBar) ? Constants.kSearchListId : list.getId(), index: indexPath.row)
            .observeOn(UIScheduler())
            .startWithNext({ value in node = CelebrityTableViewCell(celebrityStruct: value) })
        return node
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let node: CelebrityTableViewCell = self.celebrityTableView.nodeForRowAtIndexPath(indexPath) as! CelebrityTableViewCell
        let detailVC = DetailViewController(celebrityST: node.celebST)
        detailVC.transitioningDelegate = self.transitionManager
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
        self.showSocialButton(self.socialButton, controller: self)
        SettingsViewModel().loggedInAsSignal()
            .on(next: { _ in self.hideSocialButton(self.socialButton) })
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
    
    //MARK: ViewDidLoad Helpers
    func getNavigationView() -> Toolbar {
        let menuButton: FlatButton = FlatButton()
        menuButton.pulseColor = MaterialColor.white
        menuButton.pulseScale = false
        menuButton.addTarget(self, action: #selector(MasterViewController.openSettings), forControlEvents: .TouchUpInside)
        menuButton.setImage(R.image.ic_menu_white()!, forState: .Normal)
        menuButton.setImage(R.image.ic_menu_white()!, forState: .Highlighted)
        
        let rightButton: FlatButton = FlatButton()
        rightButton.pulseColor = MaterialColor.white
        rightButton.pulseScale = false
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
            NSFontAttributeName: UIFont.systemFontOfSize(18)]
        self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe
        self.segmentedControl.selectedSegmentIndex = 0
        self.segmentedControl.clipsToBounds = false
        self.segmentedControl.layer.shadowColor = MaterialColor.black.CGColor
        self.segmentedControl.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.segmentedControl.layer.shadowOpacity = 0.3
        self.segmentedControl.addTarget(self, action: #selector(MasterViewController.changeList), forControlEvents: .ValueChanged)
    }
}

