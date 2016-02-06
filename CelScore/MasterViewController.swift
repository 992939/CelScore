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


final class MasterViewController: ASViewController, ASTableViewDataSource, ASTableViewDelegate, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    //MARK: Properties
    let displayedCelebrityListVM: CelebrityListViewModel
    let searchedCelebrityListVM: SearchListViewModel
    let celebrityTableView: ASTableView
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.displayedCelebrityListVM = CelebrityListViewModel()
        self.searchedCelebrityListVM = SearchListViewModel(searchToken: "")
        self.celebrityTableView = ASTableView()
        
        super.init(node: ASDisplayNode())

        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTokenUpdate:", name:FBSDKAccessTokenDidChangeNotification, object: nil)
    }
    
    //MARK: Methods
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.celebrityTableView.asyncDataSource = self
        self.celebrityTableView.asyncDelegate = self
        
        let title = UILabel()
        title.text = "CelScore"
        title.textAlignment = .Center
        title.textColor = MaterialColor.white
        
        let menuButton: FlatButton = FlatButton()
        menuButton.pulseColor = MaterialColor.white
        menuButton.pulseScale = false
        menuButton.addTarget(self, action: Selector("openSetings"), forControlEvents: .TouchUpInside)
        menuButton.setImage(UIImage(named: "ic_menu_white"), forState: .Normal)
        menuButton.setImage(UIImage(named: "ic_menu_white"), forState: .Highlighted)

        let searchButton: FlatButton = FlatButton()
        searchButton.pulseColor = MaterialColor.white
        searchButton.pulseScale = false
        searchButton.setImage(UIImage(named: "ic_search_white"), forState: .Normal)
        searchButton.setImage(UIImage(named: "ic_search_white"), forState: .Highlighted)
        
        let navigationBarView: NavigationBarView = NavigationBarView()
        navigationBarView.titleLabel = title
        navigationBarView.leftButtons = [menuButton]
        navigationBarView.rightButtons = [searchButton]
        navigationBarView.backgroundColor = Constants.kMainGreenColor
        
        let segmentedControl = HMSegmentedControl(sectionTitles: CelebList.getAll())
        segmentedControl.frame = CGRect(x: 0, y: navigationBarView.bottom, width: UIScreen.mainScreen().bounds.width, height: 44)
        segmentedControl.backgroundColor = MaterialColor.green.lighten3
        segmentedControl.selectionIndicatorColor = MaterialColor.green.lighten2
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : MaterialColor.white,
            NSFontAttributeName: UIFont.systemFontOfSize(16)]
        segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.clipsToBounds = false
        segmentedControl.layer.shadowColor = MaterialColor.black.CGColor
        segmentedControl.layer.shadowOffset = CGSize(width: 0, height: 2)
        segmentedControl.layer.shadowOpacity = 0.3
        segmentedControl.addTarget(self, action: "changeList:", forControlEvents: .ValueChanged)
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
        loginButton.frame = CGRect(x: 0, y: navigationBarView.bottom, width: 80, height: 44)
        loginButton.delegate = self
        
        self.view.backgroundColor = Constants.kBackgroundColor
        self.view.addSubview(navigationBarView)
        self.view.addSubview(segmentedControl)
        self.view.addSubview(self.celebrityTableView)
        //self.view.addSubview(self.searchTextField)
        self.view.addSubview(loginButton)

        self.configuration()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.sideNavigationViewController!.setLeftViewWidth(Constants.kSettingsViewWidth, hidden: true, animated: false)
        
        self.celebrityTableView.frame = CGRect(
            x: Constants.kCellPadding,
            y: Constants.kNavigationPadding + 40,
            width: self.view.frame.width - 2 * Constants.kCellPadding,
            height: self.view.frame.height - 2 * Constants.kCellPadding)
    }
    
    func openSetings() { self.sideNavigationViewController!.openLeftView() }
    
    func configuration() {
        SettingsViewModel().getSettingSignal(settingType: .DefaultListId)
            .observeOn(QueueScheduler.mainQueueScheduler)
            .flatMap(.Latest) { (value:AnyObject!) -> SignalProducer<AnyObject, NSError> in
                return self.displayedCelebrityListVM.getListSignal(listId: value as! String)
            }
            .on(next: { value in
                self.celebrityTableView.beginUpdates()
                self.celebrityTableView.reloadData()
                self.celebrityTableView.endUpdates()
            })
            .retry(1)
            .start()
    
        //self.searchedCelebrityListVM.searchText <~ self.searchTextField.rac_textSignalProducer()
        CelScoreViewModel().checkNetworkStatusSignal().start()
        SettingsViewModel().updateTodayWidgetSignal().start()
    }
    
    func changeList(segmentControl: UISegmentedControl) {
        let list: CelebList = CelebList(rawValue: segmentControl.selectedSegmentIndex)!
        self.displayedCelebrityListVM.getListSignal(listId: list.getId())
            .on(next: { value in
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
    
    //MARK: ASTableView methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return self.displayedCelebrityListVM.count }
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        var node = ASCellNode()
        self.displayedCelebrityListVM.getCelebrityStructSignal(index: indexPath.row)
            .on(next: { value in node = CelebrityTableViewCell(celebrityStruct: value) })
            .start()
        return node
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let node: CelebrityTableViewCell = self.celebrityTableView.nodeForRowAtIndexPath(indexPath) as! CelebrityTableViewCell
        self.celebrityTableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.presentViewController(DetailViewController(celebrityST: node.celebST), animated: false, completion: nil)
    }
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldEndEditing(textField: UITextField) -> Bool { return false }
    func textFieldDidBeginEditing(textField: UITextField) {}
    func textFieldShouldReturn(textField: UITextField) -> Bool { textField.resignFirstResponder(); return true }
    
    //MARK: FBSDKLoginButtonDelegate Methods.
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
}


