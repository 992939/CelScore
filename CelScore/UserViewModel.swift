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
    var notificationToken: RLMNotificationToken?
    let cognitoIdentityPoolId = "us-east-1:7201b11b-c8b4-443b-9918-cf6913c05a21"
    
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
    
    func loginCognitoSignal(token: String) -> RACSignal
    {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            var logins: NSDictionary = NSDictionary(dictionary: ["graph.facebook.com" : token])
            credentialsProvider.logins = logins as [NSObject : AnyObject]
            credentialsProvider.refresh().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                println("task is \(task.description)")
                if (task.result != nil) {
                    subscriber.sendNext(task)
                    subscriber.sendCompleted()
                } else
                {
                    subscriber.sendError(task.error)
                }
                return task
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
    
    func storeUserRatingsLocallySignal() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            return nil
        })
    }
    
    func updateUserRatingsOnAWSS3Signal() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            let realm = RLMRealm.defaultRealm()
            self.notificationToken = RLMRealm.defaultRealm().addNotificationBlock({ (text: String!, realm) -> Void in
                println("REALM NOTIFICATION \(text)")
            })
            
            realm.beginWriteTransaction()
            var allUserRatings = RatingsModel.allObjects()
            realm.commitWriteTransaction()
            RLMRealm.defaultRealm().removeNotification(self.notificationToken)
 
            return nil
        })
    }
    
    func recurringUpdateAWSS3Signal(#frequency: NSTimeInterval) -> RACSignal {
        let scheduler : RACScheduler =  RACScheduler(priority: RACSchedulerPriorityDefault)
        let recurringSignal = RACSignal.interval(frequency, onScheduler: scheduler).startWith(NSDate())
        
        return recurringSignal.flattenMap({ (text: AnyObject!) -> RACStream! in
            return self.updateUserRatingsOnAWSS3Signal()
        })
    }
}