//
//  AppDelegate.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import RealmSwift
import Fabric
import TwitterKit
import AWSCognito
import Material
import RateLimit
import Fabric
import Crashlytics


@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Property
    var window: UIWindow?
    
    //MARK: Methods
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        BuddyBuildSDK.setup()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        //Realm
        let config = Realm.Configuration(
            schemaVersion: 17,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 11 {
                    migration.enumerate(SettingsModel.className()) { oldObject, newObject in
                        newObject!["isFirstStars"] = true
                        newObject!["isFirstNegative"] = true
                        newObject!["isFirstInterest"] = true
                        newObject!["isFirstCompleted"] = true
                        newObject!["isFirstVoteDisabled"] = true
                        newObject!["isFirstSocialDisabled"] = true
                        newObject!["isFirstTrollWarning"] = true
                    }
                }
                if oldSchemaVersion < 12 {
                    migration.enumerate(SettingsModel.className()) { oldObject, newObject in
                        newObject!["isFirstTrollWarning"] = true
                    }
                }
                if oldSchemaVersion < 14 {
                    migration.enumerate(SettingsModel.className()) { oldObject, newObject in

                    }
                }
                if oldSchemaVersion < 16 {
                    migration.enumerate(ListsModel.className()) { oldObject, newObject in
                        newObject!["numberOfSearchByLocalUser"] = 0
                    }
                }
                if oldSchemaVersion < 17 {
                    migration.enumerate(CelebrityModel.className()) { oldObject, newObject in
                        newObject!["isNew"] = false
                    }
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        //AWS
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: Constants.kCredentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        let configurationAnonymous = AWSServiceConfiguration(region: .USEast1, credentialsProvider: AWSAnonymousCredentialsProvider())
        BECelScoreAPIClient.registerClientWithConfiguration(configurationAnonymous, forKey: "anonymousAccess")
        
        //UI
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.rootViewController = SideNavigationController(rootViewController: MasterViewController(), leftViewController: SettingsViewController())
        let statusView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 20))
        statusView.backgroundColor = Constants.kDarkShade
        window!.rootViewController!.view.addSubview(statusView)
        self.window!.backgroundColor = Constants.kDarkShade
        self.window!.makeKeyAndVisible()
        Fabric.with([Twitter.self, AWSCognito.self, Crashlytics.self])
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.absoluteString.containsString("TheScore://") {
            CelebrityViewModel().getCelebritySignal(id: url.query!).startWithNext({ celeb in
                let celebST = CelebrityStruct(
                    id: celeb.id,
                    imageURL: celeb.picture3x,
                    nickname: celeb.nickName,
                    prevScore: celeb.prevScore,
                    sex: celeb.sex,
                    isFollowed: celeb.isFollowed)
                application.keyWindow!.rootViewController!.presentViewController(DetailViewController(celebrityST: celebST), animated: false, completion: nil)
            })
        }
        else { FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) }
        return true
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        guard userActivity.activityType == CelebrityStruct.domainIdentifier else { return true }
        guard let id = userActivity.userInfo!["id"] else { return true }
        
        let celebST = CelebrityStruct(
            id: id as! String,
            imageURL: userActivity.userInfo!["imageURL"] as! String,
            nickname: userActivity.userInfo!["nickname"] as! String,
            prevScore: userActivity.userInfo!["prevScore"] as! Double,
            sex: userActivity.userInfo!["sex"] as! Bool,
            isFollowed: userActivity.userInfo!["isFollowed"]as! Bool)
        
        application.keyWindow!.rootViewController!.presentViewController(DetailViewController(celebrityST: celebST), animated: false, completion: nil)
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        SettingsViewModel().updateTodayWidgetSignal().start()
        RateLimit.execute(name: "updateRatings", limit: Constants.kUpdateRatings) { CelScoreViewModel().getFromAWSSignal(dataType: .Ratings) }
    }
    
    func applicationWillResignActive(application: UIApplication) { SettingsViewModel().updateTodayWidgetSignal().start() }
    func applicationWillTerminate(application: UIApplication) {}
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
}
