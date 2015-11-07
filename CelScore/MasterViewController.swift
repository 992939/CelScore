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
    var loadingIndicator: UIActivityIndicatorView!
    var signInButton: UIButton!
    var searchTextField: UITextField!
    var celebrityTableView: ASTableView!
    var loginButton: FBSDKLoginButton!
    
    let celscoreVM: CelScoreViewModel
    let userVM: UserViewModel
    lazy var displayedCelebrityListVM: CelebrityListViewModel = CelebrityListViewModel()
    lazy var searchedCelebrityListVM: SearchListViewModel = SearchListViewModel(searchToken: "")

    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(viewModel:CelScoreViewModel) {
        self.celscoreVM = viewModel
        self.userVM = UserViewModel()
        self.celebrityTableView = ASTableView(frame: CGRectMake(0 , 60, 300, 400), style: UITableViewStyle.Plain, asyncDataFetching: true)
        self.searchTextField = UITextField(frame: CGRectMake(10 , 5, 300, 50))
        
        super.init(nibName: nil, bundle: nil)
        
        self.bindWithViewModels()
        
        self.searchTextField.delegate = self
        self.searchTextField.placeholder = "look up a celebrity or a #list"
        
        //self.celebrityTableView.asyncDataSource = self
        //self.celebrityTableView.asyncDelegate = self
        
        self.view.addSubview(self.searchTextField)
        self.view.addSubview(self.celebrityTableView)
    }
    
    
    //MARK: Methods
    override func viewDidLoad() { super.viewDidLoad() }
    override func viewWillLayoutSubviews() { /*self.celebrityTableView.frame = self.view.bounds */ }
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    
    //MARK: ViewModel Binding
    func bindWithViewModels ()
    {
        self.celebrityTableView.asyncDataSource = self
        self.celebrityTableView.asyncDelegate = self
        
        //LOGIN
        loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        //Check if Already Logged In
        //        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        //        print(FBSDKAccessToken.currentAccessToken())
        //        if let accessToken = FBSDKAccessToken.currentAccessToken()
        //        {
        //            print("fb token \(accessToken)")
        //        } else
        //        {
        //            print("fb error")
        //        }
        
        //DISPLAY
        self.displayedCelebrityListVM.initializeListSignal(listId: "0001")
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("initializeListSignal Value: \(value)")
                    self.celebrityTableView.beginUpdates()
                    self.celebrityTableView.reloadData()
                    self.celebrityTableView.endUpdates()
                case let .Error(error):
                    print("initializeListSignal Error: \(error)")
                case .Completed:
                    print("initializeListSignal Completed")
                case .Interrupted:
                    print("initializeListSignal Interrupted")
                }
        }
        
        //SEARCH
        self.searchedCelebrityListVM.searchText <~ self.searchTextField.rac_textSignalProducer()
        
        //REACHABILITY
        self.celscoreVM.checkNetworkConnectivitySignal()
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("checkNetworkConnectivitySignal Value: \(value)")
                case let .Error(error):
                    print("checkNetworkConnectivitySignal Error: \(error)")
                case .Completed:
                    print("checkNetworkConnectivitySignal Completed")
                case .Interrupted:
                    print("checkNetworkConnectivitySignal Interrupted")
                }
        }
    }
    
    
    //MARK: ASTableView methods.
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let celebId = self.displayedCelebrityListVM.getIdForCelebAtIndex(indexPath.row)
        let celebProfile = try! self.displayedCelebrityListVM.getCelebrityProfile(celebId: celebId)
        let node = CelebrityTableViewCell(profile: celebProfile)
        
        return node
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.displayedCelebrityListVM.getCount()
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        print("Node at \(indexPath.row)")
        //let node: CelebrityTableViewCell = self.celebrityTableView.nodeForRowAtIndexPath(indexPath) as! CelebrityTableViewCell
        let celebId = self.displayedCelebrityListVM.getIdForCelebAtIndex(indexPath.row)
        let celebProfile = try! self.displayedCelebrityListVM.getCelebrityProfile(celebId: celebId)
        self.presentViewController(DetailViewController(profile: celebProfile), animated: false, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int { return 1 }
    
    
    // MARK: UITextFieldDelegate methods
    func textFieldShouldEndEditing(textField: UITextField) -> Bool { return false }
    
    func textFieldDidBeginEditing(textField: UITextField) {}
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: FBSDKLoginButtonDelegate Methods.
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil else {
            print(error)
            return
        }
        guard result.isCancelled == false else {
            print("canceled")
            return
        }
        
        userVM.loginSignal(result.token.tokenString, loginType: .Facebook)
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("userVM.loginCognitoSignal Next: \(value)")
                    
                    let realm = try! Realm()
                    let userRatingsArray = realm.objects(UserRatingsModel)
                    if userRatingsArray.count > 0
                    {
                        self.userVM.updateCognitoSignal(nil, dataSetType: .UserRatings)
                            .start { event in
                                switch(event) {
                                case let .Next(value):
                                    print("userVM.loginCognitoSignal Value: \(value)")
                                case let .Error(error):
                                    print("userVM.loginCognitoSignal Error: \(error)")
                                case .Completed:
                                    print("userVM.loginCognitoSignal Completed")
                                case .Interrupted:
                                    print("userVM.loginCognitoSignal Interrupted")
                                }
                        }
                    } else
                    {

// **** DO NOT DELETE *****
//                        self.celscoreVM.timeNotifier.producer
//                            .start { event in
//                                switch(event) {
//                                case let .Next(value):
//                                    print("celscoreVM.timeNotifier.producer Value: \(value)")
//                                case let .Error(error):
//                                    print("celscoreVM.timeNotifier.producer Error: \(error)")
//                                case .Completed:
//                                    print("celscoreVM.timeNotifier.producer Completed")
//                                case .Interrupted:
//                                    print("celscoreVM.timeNotifier.producer Interrupted")
//                                }
//                        }
                        
                        self.celscoreVM.getFromAWSSignal(.List)
                            .start { event in
                                switch(event) {
                                case let .Next(value):
                                    print("getFromAWSSignal Value: \(value)")
                                case let .Error(error):
                                    print("getFromAWSSignal Error: \(error)")
                                case .Completed:
                                    print("getFromAWSSignal Completed")
                                case .Interrupted:
                                    print("getFromAWSSignal Interrupted")
                                }
                        }
                        
//                        self.userVM.getUserRatingsFromCognitoSignal()
//                            .start { event in
//                                switch(event) {
//                                case let .Next(value):
//                                    print("getUserRatingsFromCognitoSignal Value: \(value)")
//                                case let .Error(error):
//                                    print("getUserRatingsFromCognitoSignal Error: \(error)")
//                                case .Completed:
//                                    print("getUserRatingsFromCognitoSignal Completed")
//                                case .Interrupted:
//                                    print("getUserRatingsFromCognitoSignal Interrupted")
//                                }
//                        }
                    }
                case let .Error(error):
                    print("userVM.loginCognitoSignal Error: \(error)")
                case .Completed:
                    print("userVM.loginCognitoSignal Completed")
                case .Interrupted:
                    print("userVM.loginCognitoSignal Interrupted")
                }
        }
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

