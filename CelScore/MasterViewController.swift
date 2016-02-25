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


final class MasterViewController: ASViewController, ASTableViewDataSource, ASTableViewDelegate, UITextFieldDelegate, FBSDKLoginButtonDelegate, UISearchBarDelegate, UIViewControllerTransitioningDelegate {
    
    //MARK: Properties
    let celebrityListVM: ListViewModel
    let celebrityTableView: ASTableView
    let segmentedControl: HMSegmentedControl
    let searchBar: UISearchBar
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.celebrityListVM = ListViewModel()
        self.celebrityTableView = ASTableView()
        self.segmentedControl = HMSegmentedControl(sectionTitles: ListInfo.getAll())
        self.searchBar = UISearchBar()
        super.init(node: ASDisplayNode())

        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTokenUpdate:", name:FBSDKAccessTokenDidChangeNotification, object: nil)
    }
    
    //MARK: Methods
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func viewWillAppear(animated: Bool) {
        if let index = self.celebrityTableView.indexPathForSelectedRow {
            self.celebrityTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Fade)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.celebrityTableView.asyncDataSource = self
        self.celebrityTableView.asyncDelegate = self
        self.celebrityTableView.backgroundColor = MaterialColor.clear
        
        self.searchBar.delegate = self
        self.searchBar.searchBarStyle = .Minimal
        let attr = [NSForegroundColorAttributeName: MaterialColor.white, NSFontAttributeName : UIFont.systemFontOfSize(14.0)]
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).defaultTextAttributes = attr
        
        let navigationBarView: NavigationBarView = getNavigationView()
        self.setupSegmentedControl()
        let loginButton: FBSDKLoginButton = getLoginButton()
        
        self.view.backgroundColor = Constants.kDarkShade
        self.view.addSubview(navigationBarView)
        self.view.addSubview(segmentedControl)
        self.view.addSubview(self.celebrityTableView)
        //self.view.addSubview(loginButton)
        self.configuration()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.sideNavigationViewController!.setLeftViewWidth(Constants.kSettingsViewWidth, hidden: true, animated: false)
        self.celebrityTableView.frame = Constants.kCelebrityTableViewRect
    }
    
    func openSettings() { self.sideNavigationViewController!.openLeftView() }
    
    func configuration() {
        SettingsViewModel().getSettingSignal(settingType: .DefaultListId)
            .observeOn(QueueScheduler.mainQueueScheduler)
            .flatMap(.Latest) { (value:AnyObject!) -> SignalProducer<AnyObject, NSError> in
                return self.celebrityListVM.getListSignal(listId: value as! String)
            }
            .on(next: { value in
                self.celebrityTableView.beginUpdates()
                self.celebrityTableView.reloadData()
                self.celebrityTableView.endUpdates()
            })
            .start()
    
        CelScoreViewModel().checkNetworkStatusSignal().start()
        SettingsViewModel().updateTodayWidgetSignal().start()
    }
    
    func changeList() {
        let list: ListInfo = ListInfo(rawValue: self.segmentedControl.selectedSegmentIndex)!
        self.celebrityListVM.getListSignal(listId: list.getId())
            .on(next: { _ in
                self.celebrityTableView.beginUpdates()
                self.celebrityTableView.reloadData()
                self.celebrityTableView.endUpdates()
            })
            .start()
    }
    
    func onTokenUpdate(notification: NSNotification) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            UserViewModel().updateCognitoSignal(object: nil, dataSetType: .UserRatings).start()
            //UserViewModel().refreshFacebookTokenSignal().start()
        }
    }
    
    //MARK: ViewDidLoad Helpers
    func getNavigationView() -> NavigationBarView {
        let menuButton: FlatButton = FlatButton()
        menuButton.pulseColor = MaterialColor.white
        menuButton.pulseScale = false
        menuButton.addTarget(self, action: Selector("openSettings"), forControlEvents: .TouchUpInside)
        menuButton.setImage(UIImage(named: "ic_menu_white"), forState: .Normal)
        menuButton.setImage(UIImage(named: "ic_menu_white"), forState: .Highlighted)
        
        let searchButton: FlatButton = FlatButton()
        searchButton.pulseColor = MaterialColor.white
        searchButton.pulseScale = false
        searchButton.setImage(UIImage(named: "ic_search_white"), forState: .Normal)
        searchButton.setImage(UIImage(named: "ic_search_white"), forState: .Highlighted)
        searchButton.addTarget(self, action: "showSearchBar", forControlEvents: .TouchUpInside)
        
        let navigationBarView: NavigationBarView = NavigationBarView()
        navigationBarView.leftControls = [menuButton]
        navigationBarView.rightControls = [searchButton]
        navigationBarView.backgroundColor = Constants.kMainShade
        let celscoreImageView = UIImageView(image: UIImage(named: "celscore_white"))
        celscoreImageView.frame = CGRect(x: navigationBarView.width/2, y: navigationBarView.centerY - 5, width: 25, height: 25)
        navigationBarView.addSubview(celscoreImageView)
        return navigationBarView
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
        self.segmentedControl.addTarget(self, action: "changeList", forControlEvents: .ValueChanged)
    }
    
    func getLoginButton() -> FBSDKLoginButton {
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
        loginButton.frame = CGRect(x: 0, y: 70, width: 80, height: 44)
        loginButton.delegate = self
        return loginButton
    }
    
    //MARK: ASTableView methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return self.celebrityListVM.getCount() }
    
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        var node = ASCellNode()
        self.celebrityListVM.getCelebrityStructSignal(index: indexPath.row)
            .on(next: { value in node = CelebrityTableViewCell(celebrityStruct: value) })
            .start()
        return node
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let node: CelebrityTableViewCell = self.celebrityTableView.nodeForRowAtIndexPath(indexPath) as! CelebrityTableViewCell
        let detailVC = DetailViewController(celebrityST: node.celebST)
        detailVC.modalTransitionStyle = .CrossDissolve
        self.presentViewController(detailVC, animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldEndEditing(textField: UITextField) -> Bool { return false }
    func textFieldDidBeginEditing(textField: UITextField) {}
    func textFieldShouldReturn(textField: UITextField) -> Bool { textField.resignFirstResponder(); return true }
    
    //MARK: FBSDKLoginButtonDelegate Methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil else { print("FBSDKLogin error: \(error)"); return }
        guard result.isCancelled == false else { return }
        FBSDKAccessToken.setCurrentAccessToken(result.token)
        
        UserViewModel().loginSignal(token: result.token.tokenString, loginType: .Facebook)
            .observeOn(QueueScheduler.mainQueueScheduler)
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getUserInfoFromFacebookSignal()
            }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .Celebrity)
            }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .Ratings)
            }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .List)
            }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getFromCognitoSignal(dataSetType: .UserRatings)
            }
            .flatMapError { _ in SignalProducer<AnyObject, NSError>.empty }
            .retry(2)
            .start()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) { UserViewModel().logoutSignal(.Facebook).start() }
    
    func showSearchBar() {
        if self.view.subviews.contains(self.searchBar) { hideSearchBar() }
        else {
            self.searchBar.alpha = 0
            self.view.addSubview(self.searchBar)
            UIView.animateWithDuration(0.5, animations: {
                self.searchBar.alpha = 1
                self.searchBar.showsCancelButton = true
                self.searchBar.tintColor = Constants.kBrightShade
                self.searchBar.backgroundColor = Constants.kDarkShade
                self.searchBar.barTintColor = MaterialColor.white
                self.searchBar.frame = Constants.kSegmentedControlRect
                }, completion: { finished in self.searchBar.becomeFirstResponder() })
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
    
    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) { hideSearchBar() }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 2 {
            self.celebrityListVM.searchSignal(searchToken: searchText)
                .on(next: { _ in
                    self.celebrityTableView.beginUpdates()
                    self.celebrityTableView.reloadData()
                    self.celebrityTableView.endUpdates()
                })
                .start()
        }
    }
}


