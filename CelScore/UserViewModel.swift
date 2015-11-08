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
    let cognitoIdentityPoolId: String = "us-east-1:d08ddeeb-719b-4459-9a8f-91cb108a216c"
    enum LoginType: Int { case Facebook = 0, Twitter }
    enum CognitoDataSet: String { case UserInfo, UserRatings, UserSettings }
    
    
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
    func loginSignal(token: String, loginType: LoginType) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
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
    
    func logoutSignal(token: String, loginType: LoginType) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in
            //TODO: implementation
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
            
            let syncClient: AWSCognito = AWSCognito.defaultCognito()
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
                
            case .UserRatings:
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
                    
                    let realm = try! Realm()
                    let object: SettingsModel? = realm.objects(SettingsModel).first
                    
                    guard let settings = object else {
                        sendError(sink, NSError(domain: "com.CelScore.SettingsModelNotSet", code: 1, userInfo: nil))
                        return
                    }
                
                    if settings.isSynced == false {
                        dataset.setString(settings.defaultListId, forKey: "defaultListId")
                        dataset.setValue(settings.rankSettingIndex, forKey: "rankSettingIndex")
                        dataset.setValue(settings.notificationSettingIndex, forKey: "notificationSettingIndex")
                        dataset.setValue(settings.loginTypeIndex, forKey: "loginTypeIndex")
                    } else {
                        sendCompleted(sink)
                        return
                    }
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
    
    func getFromCognitoSignal(dataSetType: CognitoDataSet) -> SignalProducer<NSDictionary!, NSError> {
        return SignalProducer { sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            let syncClient: AWSCognito = AWSCognito.defaultCognito()
            let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset(dataSetType.rawValue)
            dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else {
                    //credentialsProvider.clearKeychain()
                    sendError(sink, task.error)
                    return task
                }
                
                let realm = try! Realm()
                realm.beginWrite()
                
                switch dataSetType {
                case .UserInfo:
                    fatalError("there is no use to store user information from Facebook/Twitter locally")
                    
                case .UserRatings:
                    dataset.getAll().forEach({ dico in
                        let userRatings = UserRatingsModel(id: dico.0 as! String, string: dico.1 as! String)
                        realm.add(userRatings, update: true)
                    })
                    
                case .UserSettings:
                    print(dataset)
                }
                try! realm.commitWrite()
                sendNext(sink, dataset.getAll())
                sendCompleted(sink)
                return task
            })
        }
    }
    
    func getUserRatingsFromCognitoSignal() -> SignalProducer<NSDictionary!, NSError> {
        return SignalProducer { sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            let syncClient: AWSCognito = AWSCognito.defaultCognito()
            let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset("UserRatings")
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
}




