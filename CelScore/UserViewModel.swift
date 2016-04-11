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
import SwiftyJSON


struct UserViewModel {
    
    func loginSignal(token token: String, with loginType: SocialLogin) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            Constants.kCredentialsProvider.getIdentityId().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock:{ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.sendFailed(task.error!); return task }
                return nil })

            switch loginType {
            case .Facebook:
                Constants.kCredentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token] as [NSObject: AnyObject]
            case .Twitter:
                Twitter.sharedInstance().logInWithCompletion { (session, error) -> Void in
                    guard session != nil else { print("error: \(error!.localizedDescription)"); return }
                    Constants.kCredentialsProvider.logins = ["api.twitter.com": session!.authToken + ";" + session!.authTokenSecret]
                }
            default: break
            }
            Constants.kCredentialsProvider.refresh().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock:{ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.sendFailed(task.error!); return task }
                observer.sendNext(task.result!)
                observer.sendCompleted()
                return task
            })
        }
    }
    
    func logoutSignal() -> SignalProducer<AnyObject, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            
            realm.beginWrite()
            let settings = realm.objects(SettingsModel)
            realm.delete(settings)
            let userRatings = realm.objects(UserRatingsModel)
            realm.delete(userRatings)
            try! realm.commitWrite()
            
            realm.beginWrite()
            let celebs = realm.objects(CelebrityModel)
            let newCelebs = celebs.map({ (celeb: CelebrityModel) -> CelebrityModel in
                celeb.isFollowed = false
                return celeb })
            realm.add(newCelebs, update: true)
            try! realm.commitWrite()
            
            Constants.kCredentialsProvider.clearCredentials()
            observer.sendNext(Constants.kCredentialsProvider)
            observer.sendCompleted()
        }
    }
    
    func refreshFacebookTokenSignal() -> SignalProducer<AnyObject, NSError> {
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
    
    func getUserInfoFromSignal(loginType loginType: SocialLogin) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            switch loginType {
            case .Facebook:
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, age_range, timezone, gender, locale, birthday, location"]).startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, object: AnyObject!, error: NSError!) -> Void in
                    guard error == nil else { observer.sendFailed(error); return }
                    observer.sendNext(object)
                    observer.sendCompleted()
                }
            case .Twitter:
                let statusesShowEndpoint = "https://api.twitter.com/1.1/users/lookup.json"
                let client = TWTRAPIClient(userID: Twitter.sharedInstance().sessionStore.session()!.userID)
                let params = ["user_id" : Twitter.sharedInstance().sessionStore.session()!.userID]
                var clientError : NSError?
                let request = client.URLRequestWithMethod("GET", URL: statusesShowEndpoint, parameters: params, error: &clientError)
                guard clientError == nil else { observer.sendFailed(clientError!); return }
                client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                    guard connectionError == nil else { observer.sendFailed(connectionError!); return }
                    let json = JSON(data: data!)
                    observer.sendNext(json.arrayObject![0])
                    observer.sendCompleted()
                }
            default: break
            }
        }
    }
    
    func updateCognitoSignal(object object: AnyObject!, dataSetType: CognitoDataSet) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            
            Constants.kCredentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.sendFailed(task.error!); return task }
                
                let syncClient: AWSCognito = AWSCognito.defaultCognito()
                let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset(dataSetType.rawValue)
                let realm = try! Realm()
                
                switch dataSetType {
                case .FacebookInfo:
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
                case .TwitterInfo:
                    if dataset.getAll().count == 0 {
                        dataset.setString(object.objectForKey("screen_name") as! String, forKey: "screen_name")
                        let followers = object.objectForKey("followers_count") as! NSNumber
                        dataset.setString(followers.stringValue, forKey: "followers_count")
                        let following = object.objectForKey("following") as! NSNumber
                        dataset.setString(following.stringValue, forKey: "following")
                        let verified = object.objectForKey("verified") as! NSNumber
                        dataset.setString(verified.stringValue, forKey: "verified")
                        dataset.setString(object.objectForKey("created_at") as! String, forKey: "created_at")
                        dataset.setString(object.objectForKey("time_zone") as! String, forKey: "time_zone")
                        dataset.setString(object.objectForKey("location") as! String, forKey: "location")
                        dataset.setString(UIDevice.currentDevice().modelName, forKey: "device")
                        dataset.setString(NSBundle.mainBundle().releaseVersionNumber, forKey: "release_version")
                        dataset.setString(NSBundle.mainBundle().buildVersionNumber, forKey: "build_version")
                    }
                case .UserRatings:
                    let userRatingsArray = realm.objects(UserRatingsModel).filter("isSynced = false")
                    guard userRatingsArray.count > 0 else { observer.sendFailed(NSError(domain: "NoUserRatings", code: 1, userInfo: nil)); return task }
                    for index in 0..<userRatingsArray.count {
                        let ratings: UserRatingsModel = userRatingsArray[index]
                        dataset.setString(ratings.interpolation(), forKey: ratings.id)
                        realm.beginWrite()
                        ratings.isSynced = true
                        realm.add(ratings, update: true)
                        try! realm.commitWrite()
                    }
                case .UserSettings:
                    let model = realm.objects(SettingsModel).first
                    guard let settings = model else { observer.sendFailed(NSError(domain: "NoSettings", code: 1, userInfo: nil)); return task }
                    if settings.isSynced == false {
                        dataset.setString(String(settings.defaultListIndex), forKey: "defaultListIndex")
                        dataset.setString(String(settings.loginTypeIndex), forKey: "loginTypeIndex")
                        dataset.setString(String(settings.publicService), forKey: "publicService")
                        dataset.setString(String(settings.consensusBuilding), forKey: "consensusBuilding")
                        dataset.setString(String(settings.isFirstLaunch), forKey: "isFirstLaunch")
                        dataset.setString(String(settings.isFirstConsensus), forKey: "isFirstConsensus")
                        dataset.setString(String(settings.isFirstPublic), forKey: "isFirstPublic")
                        dataset.setString(String(settings.isFirstFollow), forKey: "isFirstFollow")
                        dataset.setString(String(settings.isFirstStars), forKey: "isFirstStars")
                        dataset.setString(String(settings.isFirstNegative), forKey: "isFirstNegative")
                        dataset.setString(String(settings.isFirstCompleted), forKey: "isFirstCompleted")
                        dataset.setString(String(settings.isFirstInterest), forKey: "isFirstInterest")
                        dataset.setString(String(settings.isFirstVoteDisabled), forKey: "isFirstVoteDisabled")
                        dataset.setString(String(settings.isFirstSocialDisabled), forKey: "isFirstSocialDisabled")
                        dataset.setString(String(settings.isFirstTrollWarning), forKey: "isFirstTrollWarning")
                    } else { observer.sendCompleted() }
                }
                
                dataset.synchronize().continueWithBlock({ (task: AWSTask!) -> AnyObject in
                    guard task.error == nil else {
                        if task.error!.code == 10 { Constants.kCredentialsProvider.clearKeychain() }
                        observer.sendFailed(task.error!)
                        return task }
                    observer.sendNext(object)
                    observer.sendCompleted()
                    return task
                })
                return nil
            }
        }
    }
    
    func getFromCognitoSignal(dataSetType dataSetType: CognitoDataSet) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            Constants.kCredentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.sendFailed(task.error!); return task }
                return nil }
            
            let syncClient: AWSCognito = AWSCognito.defaultCognito()
            let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset(dataSetType.rawValue)
            dataset.synchronize().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock:{ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.sendFailed(task.error!); return task }
                let realm = try! Realm()
                switch dataSetType {
                case .FacebookInfo: fatalError("Not storing user information locally")
                case .TwitterInfo: fatalError("Not storing user information locally")
                case .UserRatings:
                    dataset.getAll().forEach({ dico in
                        realm.beginWrite()
                        let userRatings = UserRatingsModel(id: dico.0 as! String, joinedString: dico.1 as! String)
                        userRatings.totalVotes = 1
                        realm.add(userRatings, update: true)
                        try! realm.commitWrite()
                    })
                case .UserSettings:
                    let dico: [NSObject : AnyObject] = dataset.getAll()
                    let settings = realm.objects(SettingsModel).isEmpty ? SettingsModel() : realm.objects(SettingsModel).first!
                    guard dico.isEmpty == false else { observer.sendFailed(NSError(domain: "NoDio", code: 1, userInfo: nil)); return task }
                        
                    settings.defaultListIndex = (dico["defaultListIndex"] as! NSString).integerValue
                    settings.loginTypeIndex = (dico["loginTypeIndex"] as! NSString).integerValue
                    settings.publicService = (dico["publicService"] as! NSString).boolValue
                    settings.consensusBuilding = (dico["consensusBuilding"] as! NSString).boolValue
                    settings.isFirstLaunch = (dico["isFirstLaunch"] as! NSString).boolValue
                    settings.isFirstConsensus = (dico["isFirstConsensus"] as! NSString).boolValue
                    settings.isFirstPublic = (dico["isFirstPublic"] as! NSString).boolValue
                    settings.isFirstFollow = (dico["isFirstFollow"] as! NSString).boolValue
                    settings.isFirstStars = (dico["isFirstStars"] as! NSString).boolValue
                    settings.isFirstNegative = (dico["isFirstNegative"] as! NSString).boolValue
                    settings.isFirstCompleted = (dico["isFirstCompleted"] as! NSString).boolValue
                    settings.isFirstInterest = (dico["isFirstInterest"] as! NSString).boolValue
                    settings.isFirstVoteDisabled = (dico["isFirstVoteDisabled"] as! NSString).boolValue
                    settings.isFirstSocialDisabled = (dico["isFirstSocialDisabled"] as! NSString).boolValue
                    settings.isFirstTrollWarning = (dico["isFirstTrollWarning"] as! NSString).boolValue
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




