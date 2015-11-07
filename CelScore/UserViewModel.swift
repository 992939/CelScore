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
import TwitterKit

final class UserViewModel: NSObject {
    
    //MARK: Properties
    var votePercentageSetting: Int = 0 //TODO: NSUserStandards
    var defaultListIdSetting: String = "0001" //TODO: NSUserStandards
    enum RankSetting: Int { case All = 0, A_List, B_List } //TODO: NSUserStandards
    enum NotificationSetting: Int { case Daily = 0, Weekly, Never } //TODO: NSUserStandards
    enum LoginSetting: Int { case Facebook = 0, Twitter } //TODO: NSUserStandards
    enum CognitoDataSet: String { case UserInfo, UserVotes, UserSettings }
    
    
    //MARK: Initializers
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().rac_notifications(FBSDKProfileDidChangeNotification, object:nil)
            .start { _ in
                
                return getUserInfoFromFacebookSignal().start { event in
                    switch(event) {
                    case let .Next(value):
                        print("updateUserInfoOnCognitoSignal() Next: \(value)")
                        self.updateCognitoSignal(value, dataSetType: .UserInfo).start { event in
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
    
    
    //MARK: Login Methods
    func loginSignal(token: String, loginType: LoginSetting) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: defaults.stringForKey("cognitoIdentityPoolId"))
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            AWSCognito.registerCognitoWithConfiguration(defaultServiceConfiguration, forKey: "loginUserKey")
            
            let logins: NSDictionary
            switch loginType {
            case .Facebook:
                logins = NSDictionary(dictionary: [AWSCognitoLoginProviderKey.Facebook.rawValue : token])
                credentialsProvider.logins = logins as [NSObject: AnyObject]
            case .Twitter:
                Twitter.sharedInstance().logInWithCompletion {
                    (session, error) -> Void in
                    if (session != nil) {
                        let value = session!.authToken + ";" + session!.authTokenSecret
                        // Note: This overrides any existing logins
                        credentialsProvider.logins = ["api.twitter.com": value]
                    } else {
                        print("error: \(error!.localizedDescription)")
                    }
                }
            }

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
    
    func logoutSignal(token: String, loginType: LoginSetting) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in

            switch loginType {
            case .Facebook:
                print("FB!")
            case .Twitter:
                print("Twitter.sharedInstance()")
            }
        }
    }
    
    func getUserInfoFromFacebookSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in
            
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
    
    
    //MARK: Cognito Methods
    func updateCognitoSignal(object: AnyObject!, dataSetType: CognitoDataSet) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in
            
            let syncClient = AWSCognito.defaultCognito()
            let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset(dataSetType.rawValue)
            dataset.synchronize()
            
            switch dataSetType {
            case .UserInfo:
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
                }
            case .UserVotes:
                let realm = try! Realm()
                let predicate = NSPredicate(format: "isSynced = false")
                let userRatingsArray = realm.objects(UserRatingsModel).filter(predicate)
                
                realm.beginWrite()
                for var index: Int = 0; index < userRatingsArray.count; index++
                {
                    let ratings: UserRatingsModel = userRatingsArray[index]
                    dataset.setString(ratings.interpolation(), forKey: ratings.id)
                    ratings.isSynced = true
                    realm.add(ratings, update: true)
                }
                try! realm.commitWrite()
            case .UserSettings:
                if dataset.getAll().count == 0 {
                    print("Checked once a day and only called when user actually changed a setting")
                    dataset.setString("", forKey: "rankSetting")
                    dataset.setString("", forKey: "listSetting")
                    dataset.setString("", forKey: "notificationSetting")
                    dataset.setString("", forKey: "loginSetting")
                }
            }
            
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
    
    func getUserRatingsFromCognitoSignal() -> SignalProducer<NSDictionary!, NSError> {
        return SignalProducer { sink, _ in
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: defaults.objectForKey("cognitoIdentityPoolId") as! String)
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
    
    
    //MARK: Settings Methods
    func getUserVotePercentageSignal() -> SignalProducer<Int, NSError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            let userRatingsCount: Int = realm.objects(UserRatingsModel).count
            let celebrityCount: Int = realm.objects(CelebrityModel).count
            
            guard userRatingsCount == 0 || celebrityCount == 0 else {
                sendError(sink, NSError(domain: "com.CelScore.Empty", code: 1, userInfo: nil))
                return
            }
            
            sendNext(sink, userRatingsCount/celebrityCount)
            sendCompleted(sink)
        }
    }
}




