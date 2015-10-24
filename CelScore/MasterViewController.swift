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

enum FBLoginError : ErrorType {
    case Error
    case Cancel
}

final class MasterViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    //MARK: Properties
    var searchSignalProducer: SignalProducer<AnyObject?, NSError>
    var loadingIndicator: UIActivityIndicatorView!
    var signInButton: UIButton!
    var searchTextField : UITextField!
    var celebrityTableView : ASTableView!
    var loginButton : FBSDKLoginButton!
    var celscoreVM: CelScoreViewModel!
    var userVM: UserViewModel!
    
    enum periodSetting: NSTimeInterval {
        case Every_Minute = 60.0
        case Daily = 86400.0
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    init(viewModel:CelScoreViewModel)
    {
        self.celscoreVM = viewModel
        self.celebrityTableView = ASTableView(frame: CGRectMake(0 , 60, 300, 400), style: UITableViewStyle.Plain, asyncDataFetching: true)
        self.searchTextField = UITextField(frame: CGRectMake(10 , 5, 300, 50))
        self.searchSignalProducer = self.searchTextField.rac_textSignal().toSignalProducer()
        
        super.init(nibName: nil, bundle: nil)
        
        self.bindWithViewModels()
        
        self.searchTextField.delegate = self
        self.searchTextField.placeholder = "look up a celebrity or a #list"
        
        self.celebrityTableView.asyncDataSource = self
        self.celebrityTableView.asyncDelegate = self
        
        self.view.addSubview(self.searchTextField)
        self.view.addSubview(self.celebrityTableView)
    }

    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        //self.celebrityTableView.frame = self.view.bounds
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func bindWithViewModels ()
    {
        userVM = UserViewModel()
        
        
        // LOGIN
        loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
        loginButton.delegate = self

        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        if let accessToken = FBSDKAccessToken.currentAccessToken()
        {
            print("fb token \(accessToken)")
        } else
        {
            self.view.addSubview(loginButton)
        }
        
        
       // SEARCH
        self.celscoreVM.searchedCelebrityListVM.searchText <~ self.searchTextField.rac_textSignalProducer()
        
        
        // REACHABILITY
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
        

        // Signal to update the celscore of all celebrities
//        let updateAllCelebritiesCelScoreSignal : RACSignal = self.celscoreVM.recurringUpdateCelebritiesCelScoreSignal(frequency: periodSetting.Every_Minute.rawValue)
//        updateAllCelebritiesCelScoreSignal
//            .subscribeNext({ (object: AnyObject!) -> Void in
//                        print("updateAllCelebritiesCelScore subscribe")
//                        }, error: { (_) -> Void in
//                            print("updateAllCelebritiesCelScore error")
//        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: ASTableView data source and delegate methods.
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        //1. REUSE CELL/NODE?!?!
        
        //2. NO DATA BINDING HERE, NO CELL ON SCREEN YET. USE WILLDISPLAYCELL()/willDisplayNodeForRowAtIndexPath
        
        //3. DON'T USE AUTOLAYOUT, SHIT IS SLOOOOOW
        
        //4. AVOID BLENDING AS IT MAKES RENDERING SLOW: RUN APP IN SIMULATOR, THEN DEBUG AND PICK ITEM "COLOR BLENDED LAYERS
        
//        let celebrityVM : CelebrityViewModel = CelebrityViewModel(celebrityId: "0001")
//        let starVM = celebrityVM.getCelebrityWithIdFromLocalStoreSignal(celebId: "0002")
        
        //self.celscoreVM.displayedCelebrityListVM.celebrityList[indexPath.row] as! CelebrityViewModel
        
        let node = ASTextCellNode()
        node.text = "Celebrity"
        node.autoresizesSubviews = true

// SAVE FOR NOW
        
//        celebrityVM.initCelebrityViewModelSignal!
//            .doNext { (object: AnyObject!) -> Void in
//                a = a + a
//                node.text = "\(celebrityVM.nickName!)" + " \(a)"
//            }
//            .subscribeNext({ (object: AnyObject!) -> Void in
//                },
//                error: { (error: NSError!) -> Void in
//                    print("initCelebrityViewModelSignal error: \(error)")
//            })
        
        //celebrityVM.updateCelebrityViewModelSignal(periodSetting.Every_Minute.rawValue)
        
       return node
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.celscoreVM.displayedCelebrityListVM.celebrityList.count
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let celebrityVM : CelebrityViewModel = CelebrityViewModel(celebrityId: "0001")
        //self.celscoreVM.displayedCelebrityListVM.celebrityList[indexPath.row] as! CelebrityViewModel
        let ratings = RatingsViewModel(rating: celebrityVM.ratings!, celebrityId: (celebrityVM.celebrityInfo?.id)!)
        //print("ROW \(ratings.ratings!.description)")
        
        /* store ratings locally */
//        ratings.updateUserRatingsInRealmSignal()
//                .subscribeNext({ (object: AnyObject!) -> Void in
//                    print("updateUserRatingsInRealmSignal success")
//                },
//                error: { (error: NSError!) -> Void in
//                    print("updateUserRatingsInRealmSignal error: \(error)")
//                })
        
        /* retrieve user ratings */
//        ratings.retrieveUserRatingsFromRealmSignal()
//            .subscribeNext({ (object: AnyObject!) -> Void in
//                println("retrieveUserRatingsFromRealmSignal success")
//                },
//                error: { (error: NSError!) -> Void in
//                    println("retrieveUserRatingsFromRealmSignal error: \(error)")
//            })
    }
    
    
    // MARK: UITextFieldDelegate methods
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {}
    
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
        
        userVM.loginCognitoSignal(result.token.tokenString)
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("userVM.loginCognitoSignal Next: \(value)")
                    
                    let realm = try! Realm()
                    let userRatingsArray = realm.objects(UserRatingsModel)
                    if userRatingsArray.count > 0
                    {
                        self.userVM.updateUserRatingsOnCognitoSignal()
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
                        self.celscoreVM.getCelebsInfoFromAWSSignal()
                            .start { event in
                                switch(event) {
                                case let .Next(value):
                                    print("getCelebRatingsFromAWSSignal Value: \(value)")
                                case let .Error(error):
                                    print("getCelebRatingsFromAWSSignal Error: \(error)")
                                case .Completed:
                                    print("getCelebRatingsFromAWSSignal Completed")
                                case .Interrupted:
                                    print("getCelebRatingsFromAWSSignal Interrupted")
                                }
                        }
//                        self.celscoreVM.getCelebRatingsFromAWSSignal()
//                            .start { event in
//                                switch(event) {
//                                case let .Next(value):
//                                    print("getCelebRatingsFromAWSSignal Value: \(value)")
//                                case let .Error(error):
//                                    print("getCelebRatingsFromAWSSignal Error: \(error)")
//                                case .Completed:
//                                    print("getCelebRatingsFromAWSSignal Completed")
//                                case .Interrupted:
//                                    print("getCelebRatingsFromAWSSignal Interrupted")
//                                }
//                        }
                        
//                        self.userVM.getUserRatingsFromCognitoSignal()
//                            .start { event in
//                                switch(event) {
//                                case let .Next(value):
//                                    print("userVM.loginCognitoSignal Value: \(value)")
//                                case let .Error(error):
//                                    print("userVM.loginCognitoSignal Error: \(error)")
//                                case .Completed:
//                                    print("userVM.loginCognitoSignal Completed")
//                                case .Interrupted:
//                                    print("userVM.loginCognitoSignal Interrupted")
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

