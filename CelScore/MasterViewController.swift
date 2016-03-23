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


final class MasterViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, UISearchBarDelegate, UIViewControllerTransitioningDelegate, SideNavigationControllerDelegate, Sociable {
    
    //MARK: Properties
    private let celebrityTableView: ASTableView
    private let segmentedControl: HMSegmentedControl
    private let socialButton: MenuView
    private let searchBar: UISearchBar
    private var count: Int = 0
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.celebrityTableView = ASTableView()
        self.segmentedControl = HMSegmentedControl(sectionTitles: ListInfo.getAll())
        self.socialButton = MenuView()
        self.searchBar = UISearchBar()
        super.init(nibName: nil, bundle: nil)
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
    }
    
    //MARK: Methods
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func viewWillAppear(animated: Bool) {
        if let index = self.celebrityTableView.indexPathForSelectedRow {
            self.celebrityTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Fade)
        }
        self.socialButton.hidden = false
        SettingsViewModel().loggedInAsSignal().startWithNext { _ in self.socialButton.hidden = true }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.celebrityTableView.asyncDataSource = self
        self.celebrityTableView.asyncDelegate = self
        self.celebrityTableView.backgroundColor = MaterialColor.clear
        self.sideNavigationController!.delegate = self
        
        let attr = [NSForegroundColorAttributeName: MaterialColor.white, NSFontAttributeName : UIFont.systemFontOfSize(14.0)]
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).defaultTextAttributes = attr
        
        self.searchBar.delegate = self
        self.searchBar.searchBarStyle = .Minimal
        
        let navigationBarView: Toolbar = self.getNavigationView()
        self.setupSegmentedControl()
        
        self.setUpSocialButton(self.socialButton, controller: self, origin: CGPoint(x: Constants.kScreenWidth - 70, y: Constants.kScreenHeight - 70), buttonColor: Constants.kDarkGreenShade)
        
        self.view.backgroundColor = Constants.kDarkShade
        self.view.addSubview(navigationBarView)
        self.view.addSubview(self.segmentedControl)
        self.view.addSubview(self.celebrityTableView)
        self.view.addSubview(self.socialButton)
        MaterialLayout.size(self.view, child: self.socialButton, width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        self.setupData()
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
                TAOverlay.showOverlayWithLabel(OverlayInfo.MenuAccess.message(), image: UIImage(named: OverlayInfo.MenuAccess.logo()), options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in self.socialButton.menu.open() }) })
            .start()
    }
    
    func setupData() {
        CelScoreViewModel().getFromAWSSignal(dataType: .Ratings)
            .observeOn(UIScheduler())
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .List) }
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .Celebrity) }
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .DefaultListIndex) }
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, ListError> in
                self.segmentedControl.setSelectedSegmentIndex(value as! UInt, animated: true)
                return ListViewModel().getListSignal(listId: ListInfo(rawValue: (value as! Int))!.getId()) }
            .on(next: { list in
                self.count = list.count ?? 0
                self.celebrityTableView.beginUpdates()
                self.celebrityTableView.reloadData()
                self.celebrityTableView.endUpdates()
                self.setupUser() })
            .start()
    }
    
    func setupUser() {
        SettingsViewModel().getSettingSignal(settingType: .FirstLaunch)
            .observeOn(UIScheduler())
            .startWithNext { first in
            let firstTime = first as! Bool
            if firstTime {
                TAOverlay.showOverlayWithLabel(OverlayInfo.WelcomeUser.message(),
                    image: UIImage(named: OverlayInfo.WelcomeUser.logo()),
                    options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstLaunch).start() })
            }
        }
    }
    
    func changeList() {
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        ListViewModel().getListSignal(listId: list.getId())
            .startWithNext({ list in
                self.count = list.count
                self.celebrityTableView.beginUpdates()
                self.celebrityTableView.reloadData()
                self.celebrityTableView.endUpdates()
            })
        
        //ListViewModel().updateListSignal(listId: "0001").start() //TODO: save list in Realm
    }
    
    //MARK: Sociable
    func handleMenu(open: Bool = false) {
        let image: UIImage?
        if self.socialButton.menu.opened {
            self.socialButton.menu.close()
            image = UIImage(named: "ic_add_white")?.imageWithRenderingMode(.AlwaysTemplate)
        } else {
            self.socialButton.menu.open() { (v: UIView) in (v as? MaterialButton)?.pulse() }
            image = UIImage(named: "ic_close_white")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        let first: MaterialButton? = self.socialButton.menu.views?.first as? MaterialButton
        first?.animate(MaterialAnimation.rotate(rotation: 1))
        first?.setImage(image, forState: .Normal)
        first?.setImage(image, forState: .Highlighted)
    }
    
    func socialButton(button: UIButton) {
        if button.tag == 1 {
            let readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
            FBSDKLoginManager().logInWithReadPermissions(readPermissions, fromViewController: self, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                guard error == nil else { print("FBSDKLogin error: \(error)"); return }
                guard result.isCancelled == false else { return }
                
                FBSDKAccessToken.setCurrentAccessToken(result.token)
                UserViewModel().loginSignal(token: result.token.tokenString, loginType: .Facebook)
                    .retry(Constants.kNetworkRetry)
                    .observeOn(UIScheduler())
                    .on(next: { _ in
                        self.handleMenu()
                        TAOverlay.showOverlayWithLabel(OverlayInfo.LoginSuccess.message(),
                            image: UIImage(named: OverlayInfo.LoginSuccess.logo()),
                            options: OverlayInfo.getOptions())
                        TAOverlay.setCompletionBlock({ _ in self.socialButton.hidden = true }) })
                    .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                        return UserViewModel().getUserInfoFromFacebookSignal() }
                    .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                        return UserViewModel().updateCognitoSignal(object: value, dataSetType: .UserInfo) }
                    .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<SettingsModel, NSError> in
                        return SettingsViewModel().updateUserName(username: value.objectForKey("name") as! String) }
                    .map({ _ in return UserViewModel().getFromCognitoSignal(dataSetType: .UserRatings).start() })
                    .start()
            })
        } else {
            UserViewModel().loginSignal(token: FBSDKAccessToken.currentAccessToken().tokenString, loginType: .Facebook)
                .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                    return UserViewModel().getFromCognitoSignal(dataSetType: .UserRatings)
                }
                .start()
            //TWITTER
        }
    }
    
    //MARK: ASTableView methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return self.count }
    
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        var node = ASCellNode()
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        ListViewModel().getCelebrityStructSignal(listId: list.getId(), index: indexPath.row)
            .startWithNext({ value in node = CelebrityTableViewCell(celebrityStruct: value) })
        return node
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let node: CelebrityTableViewCell = self.celebrityTableView.nodeForRowAtIndexPath(indexPath) as! CelebrityTableViewCell
        let detailVC = DetailViewController(celebrityST: node.celebST)
        detailVC.modalTransitionStyle = .CrossDissolve
        self.presentViewController(detailVC, animated: true, completion: nil)
    }
    
    func showSearchBar() {
        if self.view.subviews.contains(self.searchBar) { hideSearchBar() }
        else {
             self.searchBar.alpha = 0.0
            UIView.animateWithDuration(0.5, animations: {
                self.searchBar.alpha = 1.0
                self.searchBar.showsCancelButton = true
                self.searchBar.tintColor = Constants.kDarkGreenShade
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
        self.socialButton.hidden = false
        SettingsViewModel().loggedInAsSignal().startWithNext { _ in self.socialButton.hidden = true }
    }
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) { self.hideSearchBar() }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool { return true }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 2 {
            ListViewModel().searchSignal(searchToken: searchText)
                .throttle(1.0, onScheduler: QueueScheduler.mainQueueScheduler)
                .startWithNext({ list in
                    self.count = list.count
                    self.celebrityTableView.beginUpdates()
                    self.celebrityTableView.reloadData()
                    self.celebrityTableView.endUpdates()
                })
        }
    }
    
    //MARK: ViewDidLoad Helpers
    func getNavigationView() -> Toolbar {
        let menuButton: FlatButton = FlatButton()
        menuButton.pulseColor = MaterialColor.white
        menuButton.pulseScale = false
        menuButton.addTarget(self, action: #selector(MasterViewController.openSettings), forControlEvents: .TouchUpInside)
        menuButton.setImage(UIImage(named: "ic_menu_white"), forState: .Normal)
        menuButton.setImage(UIImage(named: "ic_menu_white"), forState: .Highlighted)
        
        let rightButton: FlatButton = FlatButton()
        rightButton.pulseColor = MaterialColor.white
        rightButton.pulseScale = false
        rightButton.addTarget(self, action: #selector(MasterViewController.showSearchBar), forControlEvents: .TouchUpInside)
        rightButton.setImage(UIImage(named: "ic_search_white"), forState: .Normal)
        rightButton.setImage(UIImage(named: "ic_search_white"), forState: .Highlighted)
        
        let navBar: Toolbar = Toolbar()
        navBar.leftControls = [menuButton]
        navBar.rightControls = [rightButton]
        navBar.backgroundColor = Constants.kMainShade
        let celscoreImageView = UIImageView(image: UIImage(named: "score_white"))
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


