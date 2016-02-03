//
//  AppDelegate.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import SwiftyJSON
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

        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {}
                if oldSchemaVersion < 2 {
                    migration.enumerate(CookieModel.className()) { oldObject, newObject in
                        newObject!["list"] = List<Chip>()
                    }
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = SideNavigationViewController(mainViewController: MasterViewController(), sideViewController: SettingsViewController())
        window.makeKeyAndVisible()
        self.window = window
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
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
            imageURL:userActivity.userInfo!["imageURL"] as! String,
            nickname:userActivity.userInfo!["nickname"] as! String,
            height: userActivity.userInfo!["height"] as! String,
            netWorth: userActivity.userInfo!["netWorth"] as! String,
            prevScore: userActivity.userInfo!["prevScore"] as! Double,
            isFollowed:userActivity.userInfo!["isFollowed"]as! Bool)
        
        self.window!.rootViewController!.presentViewController(DetailViewController(celebrityST: celebST), animated: false, completion: nil)
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {}
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
    func applicationDidBecomeActive(application: UIApplication) {}
    func applicationWillTerminate(application: UIApplication) {}
}
