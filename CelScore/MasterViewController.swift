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
    lazy var displayedCelebrityListVM: CelebrityListViewModel = CelebrityListViewModel()
    lazy var searchedCelebrityListVM: SearchListViewModel = SearchListViewModel(searchToken: "")
    var loginButton: FBSDKLoginButton!

    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(viewModel:CelScoreViewModel) {
        self.celscoreVM = viewModel
        self.userVM = UserViewModel()
        self.settingsVM = SettingsViewModel()
        
        self.celebrityTableView = ASTableView(frame: CGRectMake(0 , 60, 300, 400), style: UITableViewStyle.Plain, asyncDataFetching: true)
        self.searchTextField = UITextField(frame: CGRectMake(10 , 5, 300, 50))
        
        super.init(nibName: nil, bundle: nil)
        
        self.bindWithViewModels()
        
        self.searchTextField.delegate = self
        self.searchTextField.placeholder = "look up a celebrity"
        
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
        
        //Login
        loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        /*FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        print(FBSDKAccessToken.currentAccessToken())
        if let accessToken = FBSDKAccessToken.currentAccessToken() { print("fb token \(accessToken)") }
        else { print("fb error") }*/
        
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
    func tableView(tableView: ASTableView!, willDisplayNodeForRowAtIndexPath indexPath: NSIndexPath!) { /*TODO: Implement*/ }
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        var node = ASCellNode()
        self.displayedCelebrityListVM.getCelebrityProfileSignal(index: indexPath.row)
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("getCelebrityProfileSignal Value: \(value)")
                    node = CelebrityTableViewCell(profile: value)
                case let .Error(error):
                    print("getCelebrityProfileSignal Error: \(error)")
                case .Completed:
                    print("getCelebrityProfileSignal Completed")
                case .Interrupted:
                    print("getCelebrityProfileSignal Interrupted")
                }
        }
        return node
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let node: CelebrityTableViewCell = self.celebrityTableView.nodeForRowAtIndexPath(indexPath) as! CelebrityTableViewCell
        self.presentViewController(DetailViewController(profile: node.profile), animated: false, completion: nil)
        //self.presentViewController(SettingsViewController(), animated: false, completion: nil)
    }
    
    
    // MARK: UITextFieldDelegate methods
    func textFieldShouldEndEditing(textField: UITextField) -> Bool { return false }
    func textFieldDidBeginEditing(textField: UITextField) {}
    func textFieldShouldReturn(textField: UITextField) -> Bool { textField.resignFirstResponder(); return true }
    
    
    //MARK: FBSDKLoginButtonDelegate Methods.
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil else { print(error); return }
        guard result.isCancelled == false else { return }
        
        userVM.loginSignal(token: result.token.tokenString, loginType: .Facebook)
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("userVM.loginCognitoSignal Next: \(value)")
                    
                    let realm = try! Realm()
                    let userRatingsArray = realm.objects(UserRatingsModel)
                    if userRatingsArray.count == 0
                    {
                        self.userVM.updateCognitoSignal(object: nil, dataSetType: .UserRatings).retry(2).start()
                    } else
                    {
                        self.celscoreVM.getFromAWSSignal(dataType: .List).start()
                        self.celscoreVM.getFromAWSSignal(dataType: .Celebrity).start()
                        self.celscoreVM.getFromAWSSignal(dataType: .Ratings).start()
                        //self.celscoreVM.timeNotifier.producer.start()
                        //self.userVM.getFromCognitoSignal(dataSetType: .UserRatings).retry(2).start()
                        //self.userVM.updateCognitoSignal(object: nil, dataSetType: .UserRatings).retry(2).start()
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

