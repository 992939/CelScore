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
            var dataset : AWSCognitoDataset = syncClient.openOrCreateDataset("UserInfo")
            dataset.synchronize() //dataset.conflictHandler
            
            println("HEY YA \(dataset.getAll().description) COUNT \(dataset.getAll().count)")
            if dataset.getAll().count == 0 {
                dataset.setString(object.objectForKey("name") as! String, forKey: "name")
                dataset.setString(object.objectForKey("first_name") as! String, forKey: "first_name")
                dataset.setString(object.objectForKey("last_name") as! String, forKey: "last_name")
                dataset.setString(object.objectForKey("email") as! String, forKey: "email")
                let timezone = object.objectForKey("timezone") as! NSNumber
                dataset.setString(timezone.stringValue, forKey: "timezone")
                dataset.setString(object.objectForKey("gender") as! String, forKey: "gender")
                dataset.setString(object.objectForKey("locale") as! String, forKey: "locale")
                dataset.setString(object.objectForKey("birthday") as! String, forKey: "birthday")
                dataset.setString(object.objectForKey("location")?.objectForKey("name") as! String, forKey: "location")
                dataset.synchronize()
            }
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

    func updateUserRatingsOnCognitoSignal() -> RACSignal {
        var notificationToken: RLMNotificationToken?
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
            
            let predicate = NSPredicate(format: "isSynced = false")
            var userRatingsArray = RatingsModel.objectsWithPredicate(predicate)
            //println("COUNT IS \(userRatingsArray.count)")
            
            let syncClient = AWSCognito.defaultCognito()
            var dataset : AWSCognitoDataset = syncClient.openOrCreateDataset("UserVotes")
            dataset.synchronize()
            
            let realm = RLMRealm.defaultRealm()
            realm.beginWriteTransaction()
            
            for var index: UInt = 0; index < userRatingsArray.count; index++
            {
                let ratings: RatingsModel = userRatingsArray.objectAtIndex(index) as! RatingsModel
                var ratingsString = "\(ratings.rating1)/\(ratings.rating2)/\(ratings.rating3)/\(ratings.rating4)/\(ratings.rating5)/\(ratings.rating6)/\(ratings.rating7)/\(ratings.rating8)/\(ratings.rating9)/\(ratings.rating10)"
                dataset.setString(ratingsString, forKey: ratings.id)
                
                ratings.isSynced = true
                realm.addOrUpdateObject(ratings)
            }
            realm.commitWriteTransaction()
            dataset.synchronize()
 
            return nil
        })
    }
    
    func recurringUpdateUserRatingsOnCognitoSignal(#frequency: NSTimeInterval) -> RACSignal {
        let scheduler : RACScheduler =  RACScheduler(priority: RACSchedulerPriorityDefault)
        let recurringSignal = RACSignal.interval(frequency, onScheduler: scheduler).startWith(NSDate())
        
        return recurringSignal.flattenMap({ (text: AnyObject!) -> RACStream! in
            return self.updateUserRatingsOnCognitoSignal()
        })
    }
}