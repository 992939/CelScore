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
import SwiftyJSON
import ReactiveCocoa
import ReactiveSwift
import FBSDKCoreKit
import Result
import AWSCore

struct UserViewModel {
    
    func loginSignal(token: String, with loginType: SocialLogin) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            switch loginType {
            case .facebook:
                Constants.kCredentialsProvider.setIdentityProviderManagerOnce(CustomIdentityProvider(tokens: ["graph.facebook.com": token as NSString] as [NSString: NSString]))
                Constants.kCredentialsProvider.getIdentityId().continueWith(block: ({ (task: AWSTask!) -> AnyObject! in
                    guard task.error == nil else {
                        let error: NSError = task.error! as NSError
                        observer.send(error: error)
                        if error.code == 8 || error.code == 10 || error.code == 11 { Constants.kCredentialsProvider.clearKeychain() }
                        return task
                    }
                    observer.send(value: task)
                    observer.sendCompleted()
                    return task
                }))
            case .twitter:
                Twitter.sharedInstance().logIn { (session, error) -> Void in
                    guard error == nil else { return observer.send(error: error! as NSError) }
                    Constants.kCredentialsProvider.setIdentityProviderManagerOnce(CustomIdentityProvider(tokens: ["api.twitter.com": String(session!.authToken + ";" + session!.authTokenSecret) as NSString]))
                    Constants.kCredentialsProvider.getIdentityId().continueWith(block: ({ (task: AWSTask!) -> AnyObject! in
                        guard task.error == nil else {
                            let error: NSError = task.error! as NSError
                            observer.send(error: error)
                            if error.code == 8 || error.code == 10 || error.code == 11 { Constants.kCredentialsProvider.clearKeychain() }
                            return task
                        }
                        observer.send(value: task)
                        observer.sendCompleted()
                        return task
                    }))
                }
            default: break
            }
        }
    }
    
    func logoutSignal() -> SignalProducer<AnyObject, NoError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            realm.beginWrite()
            let settings = realm.objects(SettingsModel.self)
            realm.delete(settings)
            let userRatings = realm.objects(UserRatingsModel.self)
            realm.delete(userRatings)
            try! realm.commitWrite()
            
            realm.beginWrite()
            let celebs = realm.objects(CelebrityModel.self)
            let newCelebs = celebs.map({ (celeb: CelebrityModel) -> CelebrityModel in
                celeb.isFollowed = false
                return celeb })
            realm.add(newCelebs, update: true)
            try! realm.commitWrite()
            
            Constants.kCredentialsProvider.clearKeychain()
            Constants.kCredentialsProvider.clearCredentials()
            observer.send(value: Constants.kCredentialsProvider)
            observer.sendCompleted()
        }
    }
    
    func refreshFacebookTokenSignal() -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            FBSDKAccessToken.refreshCurrentAccessToken({ (FBSDKGraphRequestConnection, object: Any?, error: Error?) in
                guard error == nil else { return observer.send(error: error! as NSError) }
                observer.send(value: object as AnyObject)
                observer.sendCompleted()
            })
        }
    }
    
    func getUserInfoFromSignal(loginType: SocialLogin) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            switch loginType {
            case .facebook:
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, age_range, gender"]).start { (FBSDKGraphRequestConnection, object: Any?, error: Error?) in
                    guard error == nil else { print("fb error: \(String(describing: error))"); return observer.send(error: error! as NSError) }
                    observer.send(value: object as AnyObject)
                    observer.sendCompleted()
                }
            case .twitter:
                let statusesShowEndpoint = "https://api.twitter.com/1.1/users/lookup.json"
                let client = TWTRAPIClient(userID: Twitter.sharedInstance().sessionStore.session()!.userID)
                let params = ["user_id" : Twitter.sharedInstance().sessionStore.session()!.userID]
                var clientError : NSError?
                let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
                guard clientError == nil else { print("Get User Info Error"); return observer.send(error: clientError! as NSError) }
                client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                    guard connectionError == nil else { return observer.send(error: connectionError! as NSError) }
                    let json = JSON(data: data!)
                    observer.send(value: json.arrayObject![0] as AnyObject)
                    observer.sendCompleted()
                }
            default: break
            }
        }
    }
    
    func updateCognitoSignal(object: AnyObject!, dataSetType: CognitoDataSet) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            
            Constants.kCredentialsProvider.getIdentityId().continueWith(block:({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.send(error: task.error! as NSError); return task }
                return nil }))
            
            let syncClient: AWSCognito = AWSCognito.default()
            let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset(dataSetType.rawValue)
            let realm = try! Realm()
            
            switch dataSetType {
            case .facebookInfo:
                if dataset.getAll().count == 0 {
                    dataset.setString(object.object(forKey: "name") as! String, forKey: "name")
                    dataset.setString(object.object(forKey: "first_name") as! String, forKey: "first_name")
                    dataset.setString(object.object(forKey: "last_name") as! String, forKey: "last_name")
                    dataset.setString(object.object(forKey: "email") as! String, forKey: "email")
                    dataset.setString(object.object(forKey: "gender") as! String, forKey: "gender")
                    dataset.setString(UIDevice.current.modelName, forKey: "device")
                    dataset.setString(Bundle.main.releaseVersionNumber, forKey: "release_version")
                    dataset.setString(Bundle.main.buildVersionNumber, forKey: "build_version")
                }
            case .twitterInfo:
                if dataset.getAll().count == 0 {
                    dataset.setString(object.object(forKey: "screen_name") as! String, forKey: "screen_name")
                    let followers = object.object(forKey: "followers_count") as! NSNumber
                    dataset.setString(followers.stringValue, forKey: "followers_count")
                    let following = object.object(forKey: "following") as! NSNumber
                    dataset.setString(following.stringValue, forKey: "following")
                    let verified = object.object(forKey: "verified") as! NSNumber
                    dataset.setString(verified.stringValue, forKey: "verified")
                    dataset.setString(object.object(forKey: "created_at") as! String, forKey: "created_at")
                    dataset.setString(object.object(forKey: "time_zone") as! String, forKey: "time_zone")
                    dataset.setString(object.object(forKey: "location") as! String, forKey: "location")
                    dataset.setString(UIDevice.current.modelName, forKey: "device")
                    dataset.setString(Bundle.main.releaseVersionNumber, forKey: "release_version")
                    dataset.setString(Bundle.main.buildVersionNumber, forKey: "build_version")
                }
            case .userRatings:
                let userRatingsArray = realm.objects(UserRatingsModel.self).filter("isSynced = false")
                guard userRatingsArray.count > 0 else { observer.send(value: userRatingsArray); return observer.sendCompleted(); }
                for index in 0..<userRatingsArray.count {
                    let ratings: UserRatingsModel = userRatingsArray[index]
                    dataset.setString(ratings.interpolation(), forKey: ratings.id)
                    realm.beginWrite()
                    ratings.isSynced = true
                    realm.add(ratings, update: true)
                    try! realm.commitWrite()
                }
            case .userSettings:
                let settings = realm.objects(SettingsModel.self).isEmpty ? SettingsModel() : realm.objects(SettingsModel.self).first!
                guard settings.isSynced == false else  { observer.send(value: settings); return observer.sendCompleted(); }
                
                dataset.setString(String(settings.defaultListIndex), forKey: "defaultListIndex")
                dataset.setString(String(settings.loginTypeIndex), forKey: "loginTypeIndex")
                dataset.setString(String(settings.onSocialSharing), forKey: "onSocialSharing")
                dataset.setString(String(settings.onCountdown), forKey: "onCountdown")
                dataset.setString(String(settings.isFirstLaunch), forKey: "isFirstLaunch")
                dataset.setString(String(settings.isFirstFollow), forKey: "isFirstFollow")
                dataset.setString(String(settings.isFirstInterest), forKey: "isFirstInterest")
                dataset.setString(String(settings.isFirstVoteDisabled), forKey: "isFirstVoteDisabled")
                dataset.setString(String(settings.isFirstSocialDisabled), forKey: "isFirstSocialDisabled")
                dataset.setString(String(settings.isFirstTrollWarning), forKey: "isFirstTrollWarning")
            }
            
            dataset.synchronize().continueWith(block:({ (task: AWSTask!) -> AnyObject in
                guard task.error == nil else {
                    let error: NSError = task.error! as NSError
                    print("Update Cognito Error: \(task.error.debugDescription)")
                    if error.code == 8 || error.code == 13 || error.code == -4000 { Constants.kCredentialsProvider.clearKeychain() }
                    else if error.code == 10 {
                        Constants.kCredentialsProvider.clearKeychain()
                        Constants.kCredentialsProvider.clearCredentials()
                    }
                    observer.send(error: task.error! as NSError)
                    return task }
                if case .userRatings = dataSetType { dataset.clear() }
                dataset.synchronize()
                observer.send(value: object)
                observer.sendCompleted()
                return task
            }))
        }
    }
    
    func getFromCognitoSignal(dataSetType: CognitoDataSet) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            
            Constants.kCredentialsProvider.getIdentityId().continueWith(block: ({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.send(error: task.error! as NSError); return task }
                return nil }))
            
            let syncClient: AWSCognito = AWSCognito.default()
            let dataset: AWSCognitoDataset = syncClient.openOrCreateDataset(dataSetType == .userRatings ? "UserVotes" : dataSetType.rawValue )
            dataset.synchronize().continueWith(executor: AWSExecutor.mainThread(), block:{ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else {
                    observer.send(error: task.error! as NSError)
                    return task }
                let realm = try! Realm()
                switch dataSetType {
                case .facebookInfo: fatalError("Not storing user information locally")
                case .twitterInfo: fatalError("Not storing user information locally")
                case .userRatings:
                    dataset.getAll().forEach({ dico in
                        realm.beginWrite()
                        let userRatings = UserRatingsModel(id: dico.0 , joinedString: dico.1)
                        userRatings.totalVotes = 1
                        realm.add(userRatings, update: true)
                        try! realm.commitWrite()
                    })
                case .userSettings:
                    let dico: [AnyHashable: Any] = dataset.getAll()
                    let settings: SettingsModel = realm.objects(SettingsModel.self).isEmpty ? SettingsModel() : realm.objects(SettingsModel.self).first!
                    guard dico.isEmpty == false else { observer.send(value: task); return task }
                    realm.beginWrite()
                    settings.defaultListIndex = (dico["defaultListIndex"] as! NSString).integerValue
                    settings.loginTypeIndex =  (dico["loginTypeIndex"] as! NSString).integerValue
                    settings.onSocialSharing = (dico["onSocialSharing"] as? NSString)?.boolValue ?? true
                    settings.onCountdown = (dico["onCountdown"] as? NSString)?.boolValue ?? true
                    settings.isFirstLaunch = (dico["isFirstLaunch"] as! NSString).boolValue
                    settings.isFirstFollow = (dico["isFirstFollow"] as! NSString).boolValue
                    settings.isFirstInterest = (dico["isFirstInterest"] as! NSString).boolValue
                    settings.isFirstVoteDisabled = (dico["isFirstVoteDisabled"] as! NSString).boolValue
                    settings.isFirstSocialDisabled = (dico["isFirstSocialDisabled"] as! NSString).boolValue
                    settings.isFirstTrollWarning = (dico["isFirstTrollWarning"] as! NSString).boolValue
                    settings.isSynced = true
                    realm.add(settings, update: true)
                    try! realm.commitWrite()
                }
                observer.send(value: dataset.getAll() as AnyObject)
                observer.sendCompleted()
                return task
            })
        }
    }
}




