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

class MasterViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    //MARK: Properties
    var loadingIndicator: UIActivityIndicatorView!
    var signInButton: UIButton!
    var searchTextField : UITextField!
    var celebrityTableView : ASTableView!
    var loginButton : FBSDKLoginButton!
    private var celscoreVM: CelScoreViewModel!
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
        
        super.init(nibName: nil, bundle: nil)
        
        self.searchTextField.delegate = self
        self.searchTextField.placeholder = "look up a celebrity or a #list"
        
        self.celebrityTableView.asyncDataSource = self
        self.celebrityTableView.asyncDelegate = self
        
        self.bindWithViewModels()
        
        self.view.addSubview(self.searchTextField)
        self.view.addSubview(self.celebrityTableView)
    }

    //MARK: Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
//    override func viewWillLayoutSubviews() {
//        //self.celebrityTableView.frame = self.view.bounds
//    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func bindWithViewModels ()
    {
        userVM = UserViewModel()
        
        loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
        loginButton.delegate = self
        
        userVM.getCelebInfoLambdaSignal()
            .subscribeNext({ (object: AnyObject!) -> Void in
                print("getCelebInfoLambdaSignal success")
                },
                error: { (error: NSError!) -> Void in
                    print("getCelebInfoLambdaSignal error: \(error)")
            })
        
//        userVM.getCelebRatingsLambdaSignal()
//            .subscribeNext({ (object: AnyObject!) -> Void in
//                println("getCelebRatingsLambdaSignal success")
//                },
//                error: { (error: NSError!) -> Void in
//                    println("getCelebRatingsLambdaSignal error: \(error)")
//            })


        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        if let accessToken = FBSDKAccessToken.currentAccessToken()
        {
            print("TOKEN IS \(accessToken)")
        } else
        {
            self.view.addSubview(loginButton)
        }
        
        
       // Signal to search for a celebrity or a #list
       self.searchTextField.rac_textSignal()
        .filter { (d:AnyObject!) -> Bool in
            let token = d as! NSString
            return token.length > 0
        }
        .distinctUntilChanged()
        .throttle(1)
        .flattenMap { (d:AnyObject!) -> RACStream! in
            let token = d as! String
            let isList = token.hasPrefix("#")
            
            let searchSignal : RACSignal
            if isList {
               searchSignal = RACSignal()// self.celscoreVM.searchedCelebrityListVM.searchForListsSignal(searchToken: token)
            } else
            {
                searchSignal = RACSignal() //self.celscoreVM.searchedCelebrityListVM.searchForCelebritiesSignal(searchToken: token)
            }
            return searchSignal
        }
        .subscribeNext({ (d:AnyObject!) -> Void in
            print("searchTextField signal returned \(d)")
            }, error :{ (_) -> Void in
                print("searchTextField error")
        })
        
        
        // Signal to check network connectivity
//        let networkSignal : RACSignal = celscoreVM.checkNetworkConnectivitySignal()
//        networkSignal.subscribeNext({ (_) -> Void in
//            print("networkSignal subscribe")
//            }, error: { (_) -> Void in
//                print("networkSignal error")
//        })
        

        // Signal to update the celscore of all celebrities
        let updateAllCelebritiesCelScoreSignal : RACSignal = self.celscoreVM.recurringUpdateCelebritiesCelScoreSignal(frequency: periodSetting.Every_Minute.rawValue)
        updateAllCelebritiesCelScoreSignal
            .subscribeNext({ (object: AnyObject!) -> Void in
                        print("updateAllCelebritiesCelScore subscribe")
                        }, error: { (_) -> Void in
                            print("updateAllCelebritiesCelScore error")
        })
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
        
        let celebrityVM : CelebrityViewModel = self.celscoreVM.displayedCelebrityListVM.celebrityList[indexPath.row] as! CelebrityViewModel
        
        let node = ASTextCellNode()
        node.text = "Celebrity"
        node.autoresizesSubviews = true
        var a = 5

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
        
        celebrityVM.updateCelebrityViewModelSignal(periodSetting.Every_Minute.rawValue)
        
       return node
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.celscoreVM.displayedCelebrityListVM.celebrityList.count
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let celebrityVM : CelebrityViewModel = self.celscoreVM.displayedCelebrityListVM.celebrityList[indexPath.row] as! CelebrityViewModel
        let ratings = RatingsViewModel(rating: celebrityVM.ratings!, celebrityId: celebrityVM.celebrityId!)
        print("ROW \(ratings.ratings!.description)")
        
        /* store ratings locally */
        ratings.updateUserRatingsInRealmSignal()
                .subscribeNext({ (object: AnyObject!) -> Void in
                    print("updateUserRatingsInRealmSignal success")
                },
                error: { (error: NSError!) -> Void in
                    print("updateUserRatingsInRealmSignal error: \(error)")
                })
        
        /* retrieve user ratings */
//        ratings.retrieveUserRatingsFromRealmSignal()
//            .subscribeNext({ (object: AnyObject!) -> Void in
//                println("retrieveUserRatingsFromRealmSignal success")
//                },
//                error: { (error: NSError!) -> Void in
//                    println("retrieveUserRatingsFromRealmSignal error: \(error)")
//            })
    }
    
    
    // MARK: UITextFieldDelegate methods.
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print("textFieldDidBeginEditing")
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing")
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        
        return true
    }
    
    //MARK: FBSDKLoginButtonDelegate Methods.
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil) {
            print("Process error")
        }
        else if result.isCancelled {
            print("Process cancelled")
        }
        else {
            //cache profile
            print("NIN IS \(result.description)")
            userVM.loginCognitoSignal(result.token.tokenString)
                .subscribeNext({ (object: AnyObject!) -> Void in
                    print("loginCognitoSignal success")
                    
                    let userRatingsArray = RatingsModel.allObjects()
                    if userRatingsArray.count > 0
                    {
                        //self.userVM.recurringUpdateUserRatingsOnCognitoSignal(frequency: periodSetting.Daily.rawValue)
                        self.userVM.updateUserRatingsOnCognitoSignal()
                            .subscribeNext({ (_) -> Void in
                                print("updateUserRatingsOnCognitoSignal subscribe")
                                }, error: { (_) -> Void in
                                    print("updateUserRatingsOnCognitoSignal error")
                            })
                    } else
                    {
                        self.userVM.getUserRatingsFromCognitoSignal()
                            .subscribeNext({ (_) -> Void in
                                print("getUserRatingsFromCognitoSignal subscribe")
                                }, error: { (_) -> Void in
                                    print("getUserRatingsFromCognitoSignal error")
                            })
                    }
                    },
                    error: { (error: NSError!) -> Void in
                        print("loginCognitoSignal error: \(error)")
                })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
}

