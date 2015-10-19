//
//  UserViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import AWSS3
import AWSCognito
import AWSLambda
import RealmSwift

class UserViewModel : NSObject {
    
    //MARK: Properties
    let cognitoIdentityPoolId = "us-east-1:d08ddeeb-719b-4459-9a8f-91cb108a216c"
    
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
            .rac_notifications(FBSDKProfileDidChangeNotification)
            //.skip(1)
//            .start { _ in
//                
//                return updateUserInfoOnCognitoSignal().start { event in
//                    switch(event) {
//                    case let .Next(value):
//                        print("updateUserInfoOnCognitoSignal() Next: \(value)")
//                    case let .Error(error):
//                        print("updateUserInfoOnCognitoSignal() Error: \(error)")
//                    case .Completed:
//                        print("updateUserInfoOnCognitoSignal() Completed")
//                    case .Interrupted:
//                        print("updateUserInfoOnCognitoSignal() Interrupted")
//                    }
//                }
//            }
    
//    .subscribeNext({ (object: AnyObject!) -> Void in
//                self.updateUserInfoOnCognitoSignal(object)
//                    .subscribeNext({ (object: AnyObject!) -> Void in
//                        print("updateUserInfoOnCognitoSignal success.")
//                        }, error: { (error: NSError!) -> Void in
//                            print("updateUserInfoOnCognitoSignal failed.")
//                    })
//                }, error: { (error: NSError!) -> Void in
//                    print("NSNotification failed.")
//            })
    }
    
    //MARK: Methods

    func getUserInfoFromFacebookSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, age_range, timezone, gender, locale, birthday, location"]).startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, object: AnyObject!, error: NSError!) -> Void in
                
                guard error == nil else {
                    sendError(sink, error)
                    return
                }
                
                sendNext(sink, object)
                sendCompleted(sink)
            }
        }
    }
    
    func loginCognitoSignal(token: String) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            AWSCognito.registerCognitoWithConfiguration(defaultServiceConfiguration, forKey: "loginUserKey")
            
            let logins: NSDictionary = NSDictionary(dictionary: [AWSCognitoLoginProviderKey.Facebook.rawValue : token])
            credentialsProvider.logins = logins as [NSObject : AnyObject]
            credentialsProvider.refresh().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                
                guard task.error == nil else {
                    sendError(sink, task.error)
                    return task
                }
                
                sendNext(sink, task.result)
                sendCompleted(sink)
                return task
            })
        }
    }
    
    func updateUserInfoOnCognitoSignal(object: AnyObject!) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let syncClient = AWSCognito.defaultCognito()
            let dataset : AWSCognitoDataset = syncClient.openOrCreateDataset("UserInfo")
            dataset.synchronize()
            
            print("HEY YA \(dataset.getAll().description) COUNT \(dataset.getAll().count)")
            
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
                
                dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                    
                    guard task.error == nil else {
                        sendError(sink, task.error)
                        return task
                    }
                    
                    sendNext(sink, task.result)
                    return task
                })
            }
            sendCompleted(sink)
        }
    }
    
    func getUserRatingsFromCognitoSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            //AWSLogger.defaultLogger().logLevel = .Verbose
            
            let syncClient = AWSCognito.defaultCognito()
            let dataset : AWSCognitoDataset = syncClient.openOrCreateDataset("UserVotes")
            dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                
                guard task.error == nil else {
                    credentialsProvider.clearKeychain()
                    sendError(sink, task.error)
                    return task
                }
                
                sendNext(sink, dataset.getAll())
                sendCompleted(sink)
                return task
            })
        }
    }

    func updateUserRatingsOnCognitoSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let realm = try! Realm()
            
            let predicate = NSPredicate(format: "isSynced = false")
            let userRatingsArray = realm.objects(RatingsModel).filter(predicate)
            print("COUNT IS \(userRatingsArray.count)")
            
            let syncClient = AWSCognito.defaultCognito()
            let dataset : AWSCognitoDataset = syncClient.openOrCreateDataset("UserVotes")
            dataset.synchronize()
            
            realm.beginWrite()
            for var index: Int = 0; index < userRatingsArray.count; index++
            {
                let ratings: RatingsModel = userRatingsArray[index]
                dataset.setString(ratings.interpolation(), forKey: ratings.id)
                ratings.isSynced = true
                realm.add(ratings)
            }
            try! realm.commitWrite()
            
            dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                
                guard task.error == nil else {
                    sendError(sink, task.error)
                    return task
                }
                sendNext(sink, task.result)
                sendCompleted(sink)
                return task
            })
        }
    }
    
//    func recurringUpdateUserRatingsOnCognitoSignal(frequency frequency: NSTimeInterval) -> RACSignal {
//        let scheduler : RACScheduler =  RACScheduler(priority: RACSchedulerPriorityDefault)
//        let recurringSignal = RACSignal.interval(frequency, onScheduler: scheduler).startWith(NSDate())
//        
//        return recurringSignal.flattenMap({ (text: AnyObject!) -> RACStream! in
//            return self.updateUserRatingsOnCognitoSignal()
//        })
//    }
}