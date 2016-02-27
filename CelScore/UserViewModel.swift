//
//  UserViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognito
import RealmSwift
import TwitterKit
import Timepiece


final class UserViewModel: NSObject {
    
    //MARK: Properties
    enum LoginType: Int { case Facebook = 0, Twitter }
    enum CognitoDataSet: String { case UserInfo, UserRatings, UserSettings }
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Login Methods
    func loginSignal(token token: String, loginType: LoginType) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.cognitoIdentityPoolId)
            credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { print("error:\(task.error!)"); sendError(sink, task.error!); return task }
                print("identity: \(task.result)")
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
                sendNext(sink, task.result!)
                sendCompleted(sink)
                return task
            })
        }
    }
    
    func logoutSignal(loginType: LoginType) -> SignalProducer<LoginType, NoError> {
        return SignalProducer { sink, _ in
            //TODO: implementation
            switch loginType {
            case .Facebook:
                print("FB!")
                let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.cognitoIdentityPoolId)
                credentialsProvider.clearCredentials()
            case .Twitter:
                print("Twitter.sharedInstance()")
            }
            sendCompleted(sink)
        }
    }
    
    func refreshFacebookTokenSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { sink, _ in
            let expirationDate = FBSDKAccessToken.currentAccessToken().expirationDate.stringMMddyyyyFormat().dateFromFormat("MM/dd/yyyy")!
            if expirationDate > 10.days.later { sendCompleted(sink) }
            else {
                FBSDKAccessToken.refreshCurrentAccessToken { (connection: FBSDKGraphRequestConnection!, object: AnyObject!, error: NSError!) -> Void in
                    guard error == nil else { print("facebook refresh: \(error)"); sendError(sink, error); return }
                    sendNext(sink, object)
                    sendCompleted(sink)
                }
            }
        }
    }
    
    func getUserInfoFromFacebookSignal() -> SignalProducer<AnyObject, NSError> {
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
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.cognitoIdentityPoolId)
            credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { print("getIdentityId.error:\(task.error)"); return task }
                
                let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
                AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
                AWSCognito.registerCognitoWithConfiguration(configuration, forKey: "USEast1Cognito")
                let syncClient: AWSCognito = AWSCognito(forKey: "USEast1Cognito")
                let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset(dataSetType.rawValue)
                let realm = try! Realm()
                
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
                        dataset.setString(UIDevice.currentDevice().modelName, forKey: "device")
                        dataset.setString(NSBundle.mainBundle().releaseVersionNumber, forKey: "release_version")
                        dataset.setString(NSBundle.mainBundle().buildVersionNumber, forKey: "build_version")
                    }
                case .UserRatings:
                    let predicate = NSPredicate(format: "isSynced = false")
                    let userRatingsArray = realm.objects(UserRatingsModel).filter(predicate)
                    guard userRatingsArray.count > 0 else { sendError(sink, NSError(domain: "NoUserRatings", code: 1, userInfo: nil)); return task }
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
                    //TODO: Checked once a day and only called when user actually changed a setting
                    let model: SettingsModel? = realm.objects(SettingsModel).first
                    guard let settings = model else { sendError(sink, NSError(domain: "NoSettings", code: 1, userInfo: nil)); return task }
                    if settings.isSynced == false {
                        dataset.setString(String(settings.defaultListIndex), forKey: "defaultListIndex")
                        dataset.setString(String(settings.loginTypeIndex), forKey: "loginTypeIndex")
                        dataset.setString(String(settings.publicService), forKey: "publicService")
                        dataset.setString(String(settings.fortuneMode), forKey: "fortuneMode")
                    } else { sendCompleted(sink) }
                }
                
                dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject in
                    guard task.error == nil else {
                        if task.error!.code == 10 { credentialsProvider.clearKeychain() }
                        sendError(sink, task.error!)
                        return task
                    }
                    sendNext(sink, task.completed)
                    sendCompleted(sink)
                    return task
                })
                return nil
            }
        }
    }
    
    func getFromCognitoSignal(dataSetType dataSetType: CognitoDataSet) -> SignalProducer<AnyObject, NSError> {
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
                    settings.defaultListIndex = (dico["defaultListId"] as! NSString).integerValue
                    settings.loginTypeIndex = (dico["loginTypeIndex"] as! NSString).integerValue
                    settings.publicService = (dico["publicService"] as! NSString).boolValue
                    settings.fortuneMode = (dico["fortuneMode"] as! NSString).boolValue
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




