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
import AWSPinpoint
import Material
import RateLimit
import Fabric
import Crashlytics
import ReactiveCocoa
import ReactiveSwift
import FBSDKCoreKit
import SafariServices
import UserNotifications


@UIApplicationMain

final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Property
    var window: UIWindow?
    var pinpoint: AWSPinpoint?
    
    //MARK: Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        //Realm
        let config = Realm.Configuration (
            schemaVersion: 61,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 43 {
                    migration.enumerateObjects(ofType: CelebrityModel.className()) { oldObject, newObject in
                        newObject!["isTrending"] = false
                    }
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        //AWS
        AWSDDLog().logLevel = .info
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: Constants.kCredentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let pinpointConfig = AWSPinpointConfiguration.init(appId: "ef0864d6aecb4206b0a518b43bacb836", launchOptions: launchOptions)
        pinpoint = AWSPinpoint(configuration: pinpointConfig)
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in }
        
        let configurationAnonymous = AWSServiceConfiguration(region: .USEast1, credentialsProvider: AWSAnonymousCredentialsProvider())
        JUCelScoreAPIClient.registerClient(withConfiguration: configurationAnonymous!, forKey: "anonymousAccess")
        
        //UI
        window = UIWindow(frame: UIScreen.main.bounds)
        let nav = NavigationDrawerController(rootViewController: MasterViewController(), leftViewController: SettingsViewController())
        nav.contentViewController.view.backgroundColor = .clear
        window!.rootViewController = nav
        window!.backgroundColor = Constants.kBlueShade
        window!.makeKeyAndVisible()
        
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.statusBarView?.backgroundColor = Color.red.darken2

        Twitter.sharedInstance().start(withConsumerKey: "EKczkoEeUbMNkBplemTY7rypt", consumerSecret: "Vldif166LG2VOdgMBmlVqsS0XaN071JqEMZTXqut7cL7pVZPFm")
        Fabric.with([Twitter.self, AWSCognito.self, Crashlytics.self])
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pinpoint!.notificationManager.interceptDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pinpoint!.notificationManager.interceptDidReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        pinpoint!.notificationManager.interceptDidReceiveRemoteNotification(response.notification.request.content.userInfo) { (UIBackgroundFetchResult) in }
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.absoluteString.contains("TheScore://") {
            CelebrityViewModel().getCelebritySignal(id: url.query!)
            .on(value: { celeb in
                application.keyWindow!.rootViewController!.present(DetailViewController(celebrity: celeb), animated: false, completion: nil)
            })
            .start()
        }
        else { FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if url.absoluteString.contains("TheScore://") {
            CelebrityViewModel().getCelebritySignal(id: url.query!)
                .on(value: { celeb in
                    app.keyWindow!.rootViewController!.present(DetailViewController(celebrity: celeb), animated: false, completion: nil)
                })
                .start()
        }
        else if Twitter.sharedInstance().application(app, open:url, options: options) { return true }
        else if FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: nil) { return true }
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard userActivity.activityType == CelebrityStruct.domainIdentifier else { return true }
        guard let id = userActivity.userInfo!["id"] else { return true }
        CelebrityViewModel().getCelebritySignal(id: id as! String)
            .on(value: { celeb in
                application.keyWindow!.rootViewController!.present(DetailViewController(celebrity: celeb), animated: false, completion: nil)
            })
            .start()
        return true
    }
}
