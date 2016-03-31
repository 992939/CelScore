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


@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Property
    var window: UIWindow?
    
    //MARK: Methods
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        //Realm
        let config = Realm.Configuration(
            schemaVersion: 12,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 10 {
                    migration.enumerate(SettingsModel.className()) { oldObject, newObject in
                        newObject!["consensusBuilding"] = true
                    }
                }
                if oldSchemaVersion < 11 {
                    migration.enumerate(SettingsModel.className()) { oldObject, newObject in
                        newObject!["isFirstStars"] = true
                        newObject!["isFirstNegative"] = true
                        newObject!["isFirstInterest"] = true
                        newObject!["isFirstCompleted"] = true
                        newObject!["isFirstVoteDisabled"] = true
                        newObject!["isFirstSocialDisabled"] = true
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
        self.window!.makeKeyAndVisible()
        
        Fabric.with([Twitter.self, AWSCognito.self])
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        guard userActivity.activityType == CelebrityStruct.domainIdentifier else { return false }
        
        let celebST = CelebrityStruct(
            id: userActivity.userInfo!["id"] as! String,
            imageURL: userActivity.userInfo!["imageURL"] as! String,
            nickname: userActivity.userInfo!["nickname"] as! String,
            prevScore: userActivity.userInfo!["prevScore"] as! Double,
            sex: userActivity.userInfo!["sex"] as! Bool,
            isFollowed: userActivity.userInfo!["isFollowed"]as! Bool)
        
        self.window!.rootViewController!.presentViewController(DetailViewController(celebrityST: celebST), animated: false, completion: nil)
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) { SettingsViewModel().updateTodayWidgetSignal().start() }
    func applicationDidBecomeActive(application: UIApplication) { SettingsViewModel().updateTodayWidgetSignal().start() }
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
    func applicationWillTerminate(application: UIApplication) {}
}
