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
import WillowTreeReachability

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Properties
    var window: UIWindow?
    
    
    //MARK: Methods
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let celscoreVM = CelScoreViewModel()
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.backgroundColor = UIColor.whiteColor()
        window.rootViewController = MasterViewController(viewModel: celscoreVM)
        
        //Twitter().startWithConsumerKey(Twitter.sharedInstance().consumerKey, consumerSecret: Twitter.sharedInstance().consumerSecret)
        Fabric.with([Twitter.self])
        
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        guard userActivity.activityType == CelebrityProfile.domainIdentifier, let objectId = userActivity.userInfo?["id"] as? String
            else { return false }
        
        window!.rootViewController?.popoverPresentationController
        window!.rootViewController?.presentViewController(DetailViewController(celebrityId: objectId), animated: false, completion: nil)
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {}
    func applicationDidEnterBackground(application: UIApplication) {}
    func applicationWillEnterForeground(application: UIApplication) {}
    func applicationDidBecomeActive(application: UIApplication) {}
    func applicationWillTerminate(application: UIApplication) {}
}
