//
//  UserViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation

class UserViewModel : NSObject {
    
    //MARK: Properties
    var username, password, email : String
    var firstTimeLoggedIn, lastLoggedIn : NSDate
    var ratingsList : [RatingsViewModel]
    
    enum listSetting {
        case A_List
        case B_List
        case Others
        case All
    }
    
    enum searchSetting {
        case Celebs
        case Lists
        case All
    }
    
    enum notificationSetting {
        case Daily
        case Twice_Daily
        case Never
    }
    
    enum loginSetting {
        case Guest
        case Facebook_User
        case Twitter_User
        case Registered_User
    }
    
    //MARK: Initializers
    init(username: String, password: String, email: String) {
        
        self.username = String()
        self.password = String()
        self.email = String()
        self.firstTimeLoggedIn = NSDate()
        self.lastLoggedIn = NSDate()
        self.ratingsList = Array()
        
        super.init()
        
        self.username = username
        self.password = password
        self.email = email
    }
    
    //MARK: Methods
    func registerSignal(username: String, password: String, email: String) -> RACSignal
    {
        let newUser = PFUser()
        newUser.username = username
        newUser.password = password
        newUser.email = email
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            newUser.signUpInBackgroundWithBlock({
                (status: Bool, error: NSError?) -> Void in
                if status {
                    println("User Registered!.")
                    subscriber.sendCompleted()
                } else
                {
                    println("Registration failed.")
                    subscriber.sendError(error)
                }
            })
            return nil
        })
    }
    
    func loginSignal(username: String, password: String) -> RACSignal
    {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            PFUser.logInWithUsernameInBackground(username, password: password){
                (user :PFUser?, error: NSError?) -> Void in
                if user != nil {
                    println("loginSignal success.")
                    subscriber.sendNext(user)
                    subscriber.sendCompleted()
                } else
                {
                    println("loginSignal errors")
                    subscriber.sendError(error)
                }
            }
            return nil
        })
    }
}