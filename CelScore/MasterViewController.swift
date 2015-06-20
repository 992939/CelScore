//
//  MasterViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import UIKit
//import ReactiveCocoa
//import Parse

class MasterViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    var loadingIndicator: UIActivityIndicatorView!
    var signInButton: UIButton!
    var searchTextField : UITextField!
    var celebrityTableView : ASTableView!
    private var celscoreVM: CelScoreViewModel!

    required init(coder aDecoder: NSCoder)
    {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    init(viewModel:CelScoreViewModel)
    {
        self.celscoreVM = viewModel
        self.celebrityTableView = ASTableView(frame: CGRectMake(0 , 60, 300, 400))
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
    
    override func viewWillLayoutSubviews() {
        //self.celebrityTableView.frame = self.view.bounds
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func bindWithViewModels ()
    {
        let userVM = UserViewModel(username: "Gary", password: "myPassword", email: "gmensah@gmail.com")
        
        /* binds celscore VM */
//        RACObserve(self.celscoreVM, "displayedCelebrityListVM")
//            .distinctUntilChanged()
//            .subscribeNext({ (d:AnyObject!) -> Void in
//            println("dataSourceSignal success is \(d.description)")
//            }, error :{ (_) -> Void in
//                println("dataSourceSignal error")
//            })
        
       /* search for a celebrity */
       self.searchTextField.rac_textSignal()
        .distinctUntilChanged()
        .throttle(1)
        .flattenMap { (d:AnyObject!) -> RACStream! in
            self.celscoreVM.searchedCelebrityListVM.searchForCelebritiesSignal(searchToken: d as! String)
        }
        .subscribeNext({ (d:AnyObject!) -> Void in
            println("searchTextField signal returned \(d)")
            }, error :{ (_) -> Void in
                print("searchTextField error")
        })
        
        
        RACObserve(self.celscoreVM, "searchedCelebrityListVM")
            .distinctUntilChanged()
            .subscribeNext({ (d:AnyObject!) -> Void in
                println("RACObserve searchedCelebrityListVM is now \(d)")
                }, error :{ (_) -> Void in
                    print("RACObserve searchedCelebrityListVM error")
            })
        
        /* checking network connectivity */
//                let networkSignal : RACSignal = celscoreVM.checkNetworkConnectivitySignal()
//                networkSignal.subscribeNext({ (_) -> Void in
//                                println("networkSignal subscribe")
//                                }, error: { (_) -> Void in
//                                    println("networkSignal error")
//                })
        
        
        /* user registration */
//                let signUpSignal = userVM.registerSignal(userVM.username, password: userVM.password, email: userVM.email)
//                signUpSignal.subscribeNext({ (_) -> Void in
//                    println("next")
//                    }, error: { (_) -> Void in
//                        println("error")
//                })
        
        
        /* user logging in */
//        let executeSearch = RACCommand(enabled: celscoreVM.checkNetworkConnectivitySignal()) {
//            (any:AnyObject!) -> RACSignal in
//            return userVM.loginSignal(userVM.username, password: userVM.password)
//        }
//        
//        executeSearch.executionSignals
//            .switchToLatest()
//            .subscribeNext({ (text: AnyObject!) -> Void in
//            println("executionSignals subscribe: \(text)")
//            }, error: { (text: AnyObject!) -> Void in
//                println("executionSignals error: \(text)")
//        })
//        
//        signInButton.rac_command = executeSearch
        

        /* ***PROLLY NO LONGER NEEDED*** updating table via LocalDataStore */
//        let updateTableSignal : RACSignal = celscoreVM.getAllCelebritiesInfoSignal(classTypeName: "Celebrity")
//        updateTableSignal.subscribeNext({ (text: AnyObject!) -> Void in
//            println("next:\(text)")
//            var ratings: PFObject = PFObject(className:"ratings")
//
//            }, error: { (_) -> Void in
//                println("error")
//        })

        /* update the celscore of all celebrities */
//        let updateAllCelebritiesCelScoreSignal : RACSignal = celscoreVM!.updateAllCelebritiesCelScore()
//        updateAllCelebritiesCelScoreSignal.subscribeNext({ (_) -> Void in
//                        println("updateAllCelebritiesCelScore subscribe")
//                        }, error: { (_) -> Void in
//                            println("updateAllCelebritiesCelScore error")
//        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: ASTableView data source and delegate methods.
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        var celebrityVM : CelebrityViewModel = celscoreVM.searchedCelebrityListVM.celebrityList[indexPath.row] as! CelebrityViewModel

        let node = ASTextCellNode()
        node.text = "Celebrity"
        
        celebrityVM.initCelebrityViewModelSignal!
            .distinctUntilChanged()
            .doNext { (object: AnyObject!) -> Void in
                node.text = node.text + " \(celebrityVM.currentScore!)"
            }
            .subscribeNext({ (object: AnyObject!) -> Void in
                println("celebrityViewModel Initialized: \(object)")
                //println("celebrityViewModel celebrityVM \(celebrityVM.nickName!)")
                },
                error: { (error: NSError!) -> Void in
                    println("initCelebrityViewModelSignal error: \(error)")
            })
        return node
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return celscoreVM.searchedCelebrityListVM.celebrityList.count
    }
    
    
    // MARK: UITextFieldDelegate methods.
    
    func textFieldDidBeginEditing(textField: UITextField) {
        println("textFieldDidBeginEditing")
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        println("textFieldShouldEndEditing")
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("textFieldShouldReturn")
        textField.resignFirstResponder()
        
        return true
    }
}

