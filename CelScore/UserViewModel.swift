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
        case Google_User
    }
    
    //MARK: Initializers
    override init() {
        
        super.init()
        
        NSNotificationCenter.defaultCenter()
            .rac_addObserverForName(FBSDKProfileDidChangeNotification, object: nil)
            .flattenMap { (object: AnyObject!) -> RACStream! in
                return self.getUserInfoFromFacebookSignal().distinctUntilChanged()
            }
            .subscribeNext({ (object: AnyObject!) -> Void in
                self.updateUserInfoOnCognitoSignal(object)
                    .subscribeNext({ (object: AnyObject!) -> Void in
                        println("updateUserInfoOnCognitoSignal success.")
                        }, error: { (error: NSError!) -> Void in
                            println("updateUserInfoOnCognitoSignal failed.")
                    })
                }, error: { (error: NSError!) -> Void in
                    println("NSNotification failed.")
            })
    }
    
    //MARK: Methods
    func updateUserInfoOnCognitoSignal(object: AnyObject!) -> RACSignal
    {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            let syncClient = AWSCognito.defaultCognito()
            //dataset.synchronize() //SEPERATE TASK? AS IN REGISTRATION + dataset.conflictHandler HOW TO HANDLE CONFLICT?
            var dataset : AWSCognitoDataset = syncClient.openOrCreateDataset("UserInfo")
            dataset.setString(object.objectForKey("name") as! String, forKey: "name")
            dataset.setString(object.objectForKey("first_name") as! String, forKey: "first_name")
            dataset.setString(object.objectForKey("last_name") as! String, forKey: "last_name")
            dataset.setString(object.objectForKey("email") as! String, forKey: "email")
            dataset.setString(object.objectForKey("age_range") as! String, forKey: "age_range")
            let timezone = object.objectForKey("timezone") as! NSNumber
            dataset.setString(timezone.stringValue, forKey: "timezone")
            dataset.setString(object.objectForKey("gender") as! String, forKey: "gender")
            dataset.setString(object.objectForKey("locale") as! String, forKey: "locale")
            dataset.setString(object.objectForKey("birthday") as! String, forKey: "birthday")
            dataset.setString(object.objectForKey("location")?.objectForKey("name") as! String, forKey: "location")
            dataset.synchronize()
            
            return nil
        })
    }
    
    func getUserInfoFromFacebookSignal() -> RACSignal
    {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, age_range, timezone, gender, locale, birthday, location"]).startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, object: AnyObject!, error: NSError!) -> Void in
                if error == nil {
                    println("getUserInfoFromFacebookSignal object is \(object)")
                    subscriber.sendNext(object)
                    subscriber.sendCompleted()
                } else
                {
                    println("getUserInfoFromFacebookSignal error is \(error)")
                    subscriber.sendError(error)
                }
            }
            return nil
        })
    }
    
    func loginCognitoSignal(token: String) -> RACSignal
    {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            AWSLogger.defaultLogger().logLevel = AWSLogLevel.Verbose
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            AWSCognito.registerCognitoWithConfiguration(defaultServiceConfiguration, forKey: "loginUserKey")
            
            var logins: NSDictionary = NSDictionary(dictionary: [AWSCognitoLoginProviderKey.Facebook.rawValue : token])
            credentialsProvider.logins = logins as [NSObject : AnyObject]
            credentialsProvider.refresh().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                if (task.error == nil) {
                    subscriber.sendNext(task)
                    subscriber.sendCompleted()
                } else
                {
                    subscriber.sendError(task.error)
                    println("credentialsProvider.refresh() error \(task.error)")
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
        var notificationToken: RLMNotificationToken?
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            let realm = RLMRealm.defaultRealm()
            notificationToken = RLMRealm.defaultRealm().addNotificationBlock({ (text: String!, realm) -> Void in
                println("REALM NOTIFICATION \(text)")
            })
            
            realm.beginWriteTransaction()
            var allUserRatings = RatingsModel.allObjects()
            realm.commitWriteTransaction()
            RLMRealm.defaultRealm().removeNotification(notificationToken)
 
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