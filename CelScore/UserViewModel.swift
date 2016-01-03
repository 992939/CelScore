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
import Timepiece

final class UserViewModel: NSObject {
    
    //MARK: Properties
    enum LoginType: Int { case Facebook = 0, Twitter }
    enum CognitoDataSet: String { case UserInfo, UserRatings, UserSettings }
    
    
    //MARK: Initializers
    override init() { super.init() }
    
    
    //MARK: Login Methods
    func loginSignal(token token: String, loginType: LoginType) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.cognitoIdentityPoolId)
            credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { print("getIdentityId :\(task.error)"); credentialsProvider.refresh(); return task }
                return nil
            }
            let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

            switch loginType {
            case .Facebook:
                credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token] as [NSObject: AnyObject]
            case .Twitter:
                Twitter.sharedInstance().logInWithCompletion {
                    (session, error) -> Void in
                    if session != nil {
                        let value = session!.authToken + ";" + session!.authTokenSecret
                        credentialsProvider.logins = ["api.twitter.com": value]
                    } else { print("error: \(error!.localizedDescription)") }
                }
            }
            
            credentialsProvider.refresh().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { sendError(sink, task.error!); return task }
                sendNext(sink, task.result)
                sendCompleted(sink)
                return task
            })
        }
    }
    
    func logoutSignal(token token: String, loginType: LoginType) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in
            //TODO: implementation
            switch loginType {
            case .Facebook:
                print("FB!") //credentialsProvider.clearCredentials()
            case .Twitter:
                print("Twitter.sharedInstance()")
            }
        }
    }
    
    func refreshFacebookTokenSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in
            
            print("refesh expiration date: \(FBSDKAccessToken.currentAccessToken().expirationDate)")
            
            
            
//            FBSDKAccessToken.refreshCurrentAccessToken { (connection: FBSDKGraphRequestConnection!, object: AnyObject!, error: NSError!) -> Void in
//                guard error == nil else { sendError(sink, error); return }
//                sendNext(sink, object)
//                sendCompleted(sink)
//            }
            sendCompleted(sink)
        }
    }

    
    func getUserInfoFromFacebookSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, age_range, timezone, gender, locale, birthday, location"]).startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, object: AnyObject!, error: NSError!) -> Void in
                guard error == nil else { sendError(sink, error); return }
                sendNext(sink, object)
                sendCompleted(sink)
            }
        }
    }
    
    
    //MARK: Cognito Methods
    func updateCognitoSignal(object object: AnyObject!, dataSetType: CognitoDataSet) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in
            //AWSLogger.defaultLogger().logLevel = .Verbose
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.cognitoIdentityPoolId)
            let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
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
                guard userRatingsArray.count > 0 else {
                    sendError(sink, NSError(domain: "com.CelScore.NoUserRatings", code: 1, userInfo: nil)); return
                }
                
                realm.beginWrite()
                for var index: Int = 0; index < userRatingsArray.count; index++
                {
                    let ratings: UserRatingsModel = userRatingsArray[index]
                    ratings.isSynced = true
                    realm.add(ratings, update: true)
                    dataset.setString(ratings.interpolation(), forKey: ratings.id)
                }
                try! realm.commitWrite()
            case .UserSettings:
                //TODO: Checked once a day and only called when user actually changed a setting
                let realm = try! Realm()
                let model: SettingsModel? = realm.objects(SettingsModel).first
                
                guard let settings = model else { sendError(sink, NSError(domain: "com.CelScore.NoSettings", code: 1, userInfo: nil)); return }
                if settings.isSynced == false {
                    dataset.setString(settings.defaultListId, forKey: "defaultListId")
                    dataset.setString(String(settings.loginTypeIndex), forKey: "loginTypeIndex")
                } else { sendCompleted(sink); return }
            }
            
            dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject in
                guard task.error == nil else { syncClient.wipe(); sendError(sink, task.error!); return task }
                sendNext(sink, task.completed)
                sendCompleted(sink)
                return task
            })
        }
    }
    
    func getFromCognitoSignal(dataSetType dataSetType: CognitoDataSet) -> SignalProducer<NSDictionary, NSError> {
        return SignalProducer { sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            let syncClient: AWSCognito = AWSCognito.defaultCognito()
            let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset(dataSetType.rawValue)
            dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { syncClient.wipe(); sendError(sink, task.error!); return task }
                let realm = try! Realm()
                realm.beginWrite()
                
                switch dataSetType {
                case .UserInfo: fatalError("Not storing user information locally")
                case .UserRatings:
                    dataset.getAll().forEach({ dico in
                        let userRatings = UserRatingsModel(id: dico.0 as! String, joinedString: dico.1 as! String)
                        realm.add(userRatings, update: true)
                    })
                case .UserSettings:
                    let dico = dataset.getAll()
                    var model = realm.objects(SettingsModel).first
                    if model == nil { model = SettingsModel() }
                    let settings: SettingsModel = model!
                    
                    settings.defaultListId = dico["defaultListId"] as! String
                    settings.loginTypeIndex = (dico["loginTypeIndex"] as! NSString).integerValue
                    settings.isSynced = true
                    realm.add(settings, update: true)
                }
                try! realm.commitWrite()
                sendNext(sink, dataset.getAll())
                sendCompleted(sink)
                return task
            })
        }
    }
}




