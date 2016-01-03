//
//  MasterViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FBSDKLoginKit
import FBSDKCoreKit
import ReactiveCocoa
import RealmSwift
import TwitterKit



final class MasterViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    //MARK: Properties
    let searchTextField: UITextField!
    let celebrityTableView: ASTableView!
    let celscoreVM: CelScoreViewModel
    let userVM: UserViewModel
    let settingsVM: SettingsViewModel
    var loginButton: FBSDKLoginButton!
    lazy var displayedCelebrityListVM: CelebrityListViewModel = CelebrityListViewModel()
    lazy var searchedCelebrityListVM: SearchListViewModel = SearchListViewModel(searchToken: "")

    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(viewModel:CelScoreViewModel) {
        self.celscoreVM = viewModel
        self.userVM = UserViewModel()
        self.settingsVM = SettingsViewModel()
        self.celebrityTableView = ASTableView(frame: CGRectMake(0 , 60, 300, 400), style: UITableViewStyle.Plain, asyncDataFetching: true)
        self.searchTextField = UITextField(frame: CGRectMake(10 , 5, 300, 50))
        
        super.init(nibName: nil, bundle: nil)
        
        self.searchTextField.delegate = self
        self.searchTextField.placeholder = "look up a celebrity"
        self.view.addSubview(self.searchTextField)
        self.view.addSubview(self.celebrityTableView)
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTokenUpdate:", name:FBSDKAccessTokenDidChangeNotification, object: nil)
    }
    
    func onTokenUpdate(notification: NSNotification) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            self.loginButton = FBSDKLoginButton()
            self.loginButton.readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
            self.loginButton.delegate = self
            self.view.addSubview(loginButton)
            
            self.userVM.refreshFacebookTokenSignal().start()
        }
    }
    
    
    //MARK: Methods
    override func viewDidLoad() { super.viewDidLoad(); self.configuration() }
    override func viewWillLayoutSubviews() { /*self.celebrityTableView.frame = self.view.bounds */ }
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    func configuration()
    {
        self.celebrityTableView.asyncDataSource = self
        self.celebrityTableView.asyncDelegate = self
        
        self.displayedCelebrityListVM.initializeListSignal(listId: self.settingsVM.defaultListId)
            .on(next: { value in
                self.celebrityTableView.beginUpdates()
                self.celebrityTableView.reloadData()
                self.celebrityTableView.endUpdates()
            })
            .start()
    
        self.searchedCelebrityListVM.searchText <~ self.searchTextField.rac_textSignalProducer()
        self.celscoreVM.checkNetworkConnectivitySignal().start()
        //self.settingsVM.getFollowedCelebritiesSignal().start()
    }
    
    
    //MARK: ASTableView methods
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int { return 1 }
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int { return self.displayedCelebrityListVM.count }
    func tableView(tableView: ASTableView!, willDisplayNodeForRowAtIndexPath indexPath: NSIndexPath!) {
        /*TODO: Implement*/
    }
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        var node = ASCellNode()
        self.displayedCelebrityListVM.getCelebrityProfileSignal(index: indexPath.row)
            .on(next: { value in node = CelebrityTableViewCell(profile: value) })
            .start()
        return node
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let node: CelebrityTableViewCell = self.celebrityTableView.nodeForRowAtIndexPath(indexPath) as! CelebrityTableViewCell
        self.presentViewController(DetailViewController(celebrityId: node.profile.id), animated: false, completion: nil)
        //self.presentViewController(SettingsViewController(), animated: false, completion: nil)
    }
    
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldEndEditing(textField: UITextField) -> Bool { return false }
    func textFieldDidBeginEditing(textField: UITextField) {}
    func textFieldShouldReturn(textField: UITextField) -> Bool { textField.resignFirstResponder(); return true }
    
    
    //MARK: FBSDKLoginButtonDelegate Methods.
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil else { print("FBSDKLogin error: \(error)"); return }
        guard result.isCancelled == false else { return }
        
        print("expiration date: \(result.token.expirationDate)")
        
        self.userVM.loginSignal(token: result.token.tokenString, loginType: .Facebook)
            .observeOn(QueueScheduler.mainQueueScheduler)
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject!, NSError> in
                return self.userVM.getUserInfoFromFacebookSignal()
            }
            .flatMap(.Latest) { (value:AnyObject!) -> SignalProducer<AnyObject, NSError> in
                return self.userVM.updateCognitoSignal(object: nil, dataSetType: .UserRatings) //TODO: enum every_day, every_minute, every_hour
            }
            .flatMapError { _ in SignalProducer<AnyObject, NSError>.empty }
            .retry(2)
            .start()
        
        //self.settingsVM.calculateSocialConsensusSignal().start()
        //self.celscoreVM.getFromAWSSignal(dataType: .List).start()
        //self.celscoreVM.getFromAWSSignal(dataType: .Ratings).start()
        //self.celscoreVM.getFromAWSSignal(dataType: .Celebrity, timeInterval: 3).start()
        //self.userVM.getFromCognitoSignal(dataSetType: .UserRatings).start()
        //self.userVM.updateCognitoSignal(object: nil, dataSetType: .UserRatings).start()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {}
}


//MARK: Extensions
extension UITextField {
    func rac_textSignalProducer() -> SignalProducer<String, NoError> {
        return self.rac_textSignal().toSignalProducer()
            .map { $0 as! String }
            .flatMapError { _ in SignalProducer<String, NoError>.empty }
    }
}

extension Array {
    func randomItem() -> Element {
        let index = Int(rand()) % count
        return self[index]
    }
}

