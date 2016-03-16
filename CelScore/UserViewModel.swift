//
//  UserViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AWSCore
import AWSCognito
import RealmSwift
import TwitterKit
import Timepiece
import Result


struct UserViewModel {
    
    func loginSignal(token token: String, loginType: LoginType) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            Constants.kCredentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { print("error:\(task.error!)"); observer.sendFailed(task.error!); return task }
                print("identity: \(task.result)")
                return nil
            }
            let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: Constants.kCredentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

            switch loginType {
            case .Facebook:
                Constants.kCredentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token] as [NSObject: AnyObject]
            case .Twitter:
                Twitter.sharedInstance().logInWithCompletion {
                    (session, error) -> Void in
                    if session != nil {
                        let value = session!.authToken + ";" + session!.authTokenSecret
                        Constants.kCredentialsProvider.logins = ["api.twitter.com": value]
                    } else { print("error: \(error!.localizedDescription)") }
                }
            default: break
            }
            Constants.kCredentialsProvider.refresh().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.sendFailed(task.error!); return task }
                observer.sendNext(task.result!)
                observer.sendCompleted()
                return task
            })
        }
    }
    
    func logoutSignal(loginType: LoginType) -> SignalProducer<LoginType, NoError> {
        return SignalProducer { observer, disposable in
            //TODO: implementation
            switch loginType {
            case .Facebook:
                Constants.kCredentialsProvider.clearCredentials()
            case .Twitter:
                print("Twitter.sharedInstance()")
            default: break
            }
            observer.sendCompleted()
        }
    }
    
    func refreshFacebookTokenSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer { observer, disposable in
            let expirationDate = FBSDKAccessToken.currentAccessToken().expirationDate.stringMMddyyyyFormat().dateFromFormat("MM/dd/yyyy")!
            if expirationDate > 10.days.later { observer.sendCompleted() }
            else {
                FBSDKAccessToken.refreshCurrentAccessToken { (connection: FBSDKGraphRequestConnection!, object: AnyObject!, error: NSError!) -> Void in
                    guard error == nil else { print("facebook refresh: \(error)"); observer.sendFailed(error); return }
                    observer.sendNext(object)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    func getUserInfoFromFacebookSignal() -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, age_range, timezone, gender, locale, birthday, location"]).startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, object: AnyObject!, error: NSError!) -> Void in
                guard error == nil else { observer.sendFailed(error); return }
                observer.sendNext(object)
                observer.sendCompleted()
            }
        }
    }
    
    //MARK: Cognito Methods
    func updateCognitoSignal(object object: AnyObject!, dataSetType: CognitoDataSet) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            
            Constants.kCredentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { print("getIdentityId.error:\(task.error)"); return task }
                let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: Constants.kCredentialsProvider)
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
                    let userRatingsArray = realm.objects(UserRatingsModel).filter("isSynced = false")
                    guard userRatingsArray.count > 0 else { observer.sendFailed(NSError(domain: "NoUserRatings", code: 1, userInfo: nil)); return task }
                    for index in 0...userRatingsArray.count { //TODO: test bounds
                        let ratings: UserRatingsModel = userRatingsArray[index]
                        dataset.setString(ratings.interpolation(), forKey: ratings.id)
                        realm.beginWrite()
                        ratings.isSynced = true
                        realm.add(ratings, update: true)
                        try! realm.commitWrite()
                    }
                case .UserSettings:
                    //TODO: Checked once a day and only called when user actually changed a setting
                    let model: SettingsModel? = realm.objects(SettingsModel).first
                    guard let settings = model else { observer.sendFailed(NSError(domain: "NoSettings", code: 1, userInfo: nil)); return task }
                    if settings.isSynced == false {
                        dataset.setString(String(settings.defaultListIndex), forKey: "defaultListIndex")
                        dataset.setString(String(settings.loginTypeIndex), forKey: "loginTypeIndex")
                        dataset.setString(String(settings.publicService), forKey: "publicService")
                        dataset.setString(String(settings.fortuneMode), forKey: "fortuneMode")
                    } else { observer.sendCompleted() }
                }
                
                dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject in
                    guard task.error == nil else {
                        if task.error!.code == 10 { Constants.kCredentialsProvider.clearKeychain() }
                        observer.sendFailed(task.error!)
                        return task
                    }
                    observer.sendNext(task.completed)
                    observer.sendCompleted()
                    return task
                })
                return nil
            }
        }
    }
    
    func getFromCognitoSignal(dataSetType dataSetType: CognitoDataSet) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            
            let syncClient: AWSCognito = AWSCognito.defaultCognito()
            let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset(dataSetType.rawValue)
            dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { syncClient.wipe(); observer.sendFailed(task.error!); return task }
                let realm = try! Realm()
                switch dataSetType {
                case .UserInfo: fatalError("Not storing user information locally")
                case .UserRatings:
                    realm.beginWrite()
                    dataset.getAll().forEach({ dico in
                        let userRatings = UserRatingsModel(id: dico.0 as! String, joinedString: dico.1 as! String)
                        realm.add(userRatings, update: true)
                    })
                    try! realm.commitWrite()
                case .UserSettings:
                    let dico = dataset.getAll()
                    let settings = realm.objects(SettingsModel).isEmpty ? SettingsModel() : realm.objects(SettingsModel).first!
                    //TODO: check .isEmpty
                    settings.defaultListIndex = (dico["defaultListId"] as! NSString).integerValue
                    settings.loginTypeIndex = (dico["loginTypeIndex"] as! NSString).integerValue
                    settings.publicService = (dico["publicService"] as! NSString).boolValue
                    settings.fortuneMode = (dico["fortuneMode"] as! NSString).boolValue
                    settings.isSynced = true
                    realm.beginWrite()
                    realm.add(settings, update: true)
                    try! realm.commitWrite()
                }
                observer.sendNext(dataset.getAll())
                observer.sendCompleted()
                return task
            })
        }
    }
}




