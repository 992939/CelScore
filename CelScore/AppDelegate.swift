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
import ReactiveCocoa
import FBSDKCoreKit
import Armchair
import SafariServices


@UIApplicationMain

final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Property
    var window: UIWindow?
    
    //MARK: Methods
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        //BuddyBuild
        BuddyBuildSDK.setup()
        
        //ArmChair
        Armchair.appID("783417076")
       
        //Realm
        let config = Realm.Configuration(
            schemaVersion: 22,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 17 {
                    migration.enumerate(CelebrityModel.className()) { oldObject, newObject in
                        newObject!["isNew"] = false
                    }
                }
                if oldSchemaVersion < 21 {
                    migration.enumerate(SettingsModel.className()) { oldObject, newObject in
                        newObject!["isFirst25"] = true
                        newObject!["isFirst50"] = true
                        newObject!["isFirst75"] = true
                    }
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        //AWS
        AWSLogger.defaultLogger().logLevel = .Error
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: Constants.kCredentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        let configurationAnonymous = AWSServiceConfiguration(region: .USEast1, credentialsProvider: AWSAnonymousCredentialsProvider())
        CACelScoreAPIClient.registerClientWithConfiguration(configurationAnonymous, forKey: "anonymousAccess")
        
        //UI
        CelScoreViewModel().getFromAWSSignal(dataType: .List).start()
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let nav: NavigationDrawerController = NavigationDrawerController(rootViewController: MasterViewController(), leftViewController: SettingsViewController())
        nav.contentViewController.view.backgroundColor = UIColor.clearColor()
        self.window!.rootViewController = nav
        let statusView = UIView(frame: Constants.kStatusViewRect)
        statusView.backgroundColor = Constants.kBlueShade
        window!.rootViewController!.view.addSubview(statusView)
        self.window!.backgroundColor = Constants.kBlueShade
        self.window!.makeKeyAndVisible()
        
        Twitter.sharedInstance().startWithConsumerKey("EKczkoEeUbMNkBplemTY7rypt", consumerSecret: "Vldif166LG2VOdgMBmlVqsS0XaN071JqEMZTXqut7cL7pVZPFm")
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
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if Twitter.sharedInstance().application(app, openURL:url, options: options) { return true }
        else if FBSDKApplicationDelegate.sharedInstance().application(app, openURL: url, sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as! String, annotation: nil) { return true }
        return false
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
        RateLimit.execute(name: "updateRatings", limit: Constants.kUpdateRatings) { CelScoreViewModel().getFromAWSSignal(dataType: .Ratings) }
    }
    func applicationWillResignActive(application: UIApplication) { }
    func applicationDidEnterBackground(application: UIApplication) { }
    func applicationWillEnterForeground(application: UIApplication) { }
}
