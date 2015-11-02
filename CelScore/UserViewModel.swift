//
//  UserViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import AWSCognito
import AWSLambda
import RealmSwift

final class UserViewModel: NSObject {
    
    //MARK: Properties
    let cognitoIdentityPoolId: String = "us-east-1:d08ddeeb-719b-4459-9a8f-91cb108a216c"
    var votePercentage: Float = 0
    var defaultListIdSetting: String = "0001" //TODO: NSUserStandards
    
    enum ListSetting: Int { case All = 0, A_List, B_List }
    enum NotificationSetting: Int { case Daily = 0, Weekly, Never }
    enum LoginSetting: Int { case None = 0, Facebook_User, Twitter_User, Google_User }
    
    
    //MARK: Initializers
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().rac_notifications(FBSDKProfileDidChangeNotification, object:nil)
            .start { _ in
                
                return getUserInfoFromFacebookSignal().start { event in
                    switch(event) {
                    case let .Next(value):
                        print("updateUserInfoOnCognitoSignal() Next: \(value)")
                        self.updateUserInfoOnCognitoSignal(value).start { event in
                            switch(event) {
                            case let .Next(value):
                                print("updateUserInfoOnCognitoSignal() Next: \(value)")
                            case let .Error(error):
                                print("getUserInfoFromFacebookSignal() Error: \(error)")
                            case .Completed:
                                print("getUserInfoFromFacebookSignal() Completed")
                            case .Interrupted:
                                print("getUserInfoFromFacebookSignal() Interrupted")
                            }
                        }
                    case let .Error(error):
                        print("getUserInfoFromFacebookSignal() Error: \(error)")
                    case .Completed:
                        print("getUserInfoFromFacebookSignal() Completed")
                    case .Interrupted:
                        print("getUserInfoFromFacebookSignal() Interrupted")
                    }
                }
        }
    }
    
    
    //MARK: Methods
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
                print(credentialsProvider.getIdentityId())
                
                sendNext(sink, task.result)
                sendCompleted(sink)
                return task
            })
        }
    }
    
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
    
    func updateUserInfoOnCognitoSignal(object: AnyObject!) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let syncClient = AWSCognito.defaultCognito()
            let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset("UserInfo")
            dataset.synchronize()
            
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
    
    func getUserRatingsFromCognitoSignal() -> SignalProducer<NSDictionary!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            let syncClient = AWSCognito.defaultCognito()
            let dataset : AWSCognitoDataset = syncClient.openOrCreateDataset("UserVotes")
            dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else {
                    credentialsProvider.clearKeychain()
                    sendError(sink, task.error)
                    return task
                }
                
                let realm = try! Realm()
                print(realm.objects(RatingsModel))
                realm.beginWrite()
                
                dataset.getAll().forEach({ dico in
                    let userRatings = UserRatingsModel(id: dico.0 as! String, string: dico.1 as! String)
                    realm.add(userRatings, update: true)
                })
                
                try! realm.commitWrite()
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
            
            let syncClient = AWSCognito.defaultCognito()
            let dataset : AWSCognitoDataset = syncClient.openOrCreateDataset("UserVotes")
            dataset.synchronize()
            
            realm.beginWrite()
            for var index: Int = 0; index < userRatingsArray.count; index++
            {
                let ratings: RatingsModel = userRatingsArray[index]
                dataset.setString(ratings.interpolation(), forKey: ratings.id)
                ratings.isSynced = true
                realm.add(ratings, update: true)
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
}