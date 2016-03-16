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

        let config = Realm.Configuration(
            schemaVersion: 8,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 7 {
                    migration.enumerate(SettingsModel.className()) { oldObject, newObject in
                        newObject!["isFirstRoad"] = true
                        newObject!["isFirstPublic"] = true
                    }
                }
                if oldSchemaVersion < 8 {
                    migration.enumerate(SettingsModel.className()) { oldObject, newObject in
                        newObject!["isFirstFollow"] = true
                    }
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        // AWS Cognito Access for authenticated requests
        let configurationAuth = AWSServiceConfiguration(region: .USEast1, credentialsProvider: Constants.kCredentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configurationAuth
        
        // Anonymous Access
        let configurationAnonymous = AWSServiceConfiguration(region: .USEast1, credentialsProvider: AWSAnonymousCredentialsProvider())
        MACelScoreAPIClient.registerClientWithConfiguration(configurationAnonymous, forKey: "anonymousAccess")
        
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = SideNavigationController(mainViewController: MasterViewController(), leftViewController: SettingsViewController())
        let statusView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.kScreenWidth, height: 20))
        statusView.backgroundColor = Constants.kDarkShade
        window.rootViewController!.view.addSubview(statusView)
        window.makeKeyAndVisible()
        self.window = window
        
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
            height: userActivity.userInfo!["height"] as! String,
            netWorth: userActivity.userInfo!["netWorth"] as! String,
            prevScore: userActivity.userInfo!["prevScore"] as! Double,
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
