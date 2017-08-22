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
         UIApplication.shared.statusBarStyle = .lightContent
       
        //Realm
        let config = Realm.Configuration(
            schemaVersion: 49,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 41 {
                    migration.enumerateObjects(ofType: CelebrityModel.className()) { oldObject, newObject in
                        newObject!["kingName"] = ""
                    }
                }
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
        
        let pinpointConfig: AWSPinpointConfiguration = AWSPinpointConfiguration.init(appId: "ef0864d6aecb4206b0a518b43bacb836", launchOptions: launchOptions)
        pinpoint = AWSPinpoint(configuration: pinpointConfig)
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in }
        UIApplication.shared.registerForRemoteNotifications()
        
        let configurationAnonymous = AWSServiceConfiguration(region: .USEast1, credentialsProvider: AWSAnonymousCredentialsProvider())
        JUCelScoreAPIClient.registerClient(withConfiguration: configurationAnonymous!, forKey: "anonymousAccess")
        
        //UI
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let nav: NavigationDrawerController = NavigationDrawerController(rootViewController: MasterViewController(), leftViewController: SettingsViewController())
        nav.contentViewController.view.backgroundColor = .clear
        self.window!.rootViewController = nav
        let statusView = UIView(frame: Constants.kStatusViewRect)
        statusView.backgroundColor = Constants.kBlueShade
        window!.rootViewController!.view.addSubview(statusView)
        self.window!.backgroundColor = Constants.kBlueShade
        self.window!.makeKeyAndVisible()

        Twitter.sharedInstance().start(withConsumerKey: "EKczkoEeUbMNkBplemTY7rypt", consumerSecret: "Vldif166LG2VOdgMBmlVqsS0XaN071JqEMZTXqut7cL7pVZPFm")
        Fabric.with([Twitter.self, AWSCognito.self, Crashlytics.self])
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
         print("didRegisterForRemoteNotificationsWithDeviceToken")
        pinpoint!.notificationManager.interceptDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification")
        pinpoint!.notificationManager.interceptDidReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print("userNotificationCenter")
        pinpoint!.notificationManager.interceptDidReceiveRemoteNotification(response.notification.request.content.userInfo) { (UIBackgroundFetchResult) in}
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.absoluteString.contains("TheScore://") {
            CelebrityViewModel().getCelebritySignal(id: url.query!)
                .flatMapError { _ in .empty }
                .startWithValues({ celeb in
                let celebST = CelebrityStruct(
                    id: celeb.id,
                    imageURL: celeb.picture3x,
                    nickName: celeb.nickName,
                    kingName: celeb.kingName,
                    prevScore: celeb.prevScore,
                    prevWeek: celeb.prevWeek,
                    prevMonth: celeb.prevMonth,
                    index: celeb.index,
                    sex: celeb.sex,
                    isFollowed: celeb.isFollowed,
                    isTrending: celeb.isTrending)
                application.keyWindow!.rootViewController!.present(DetailViewController(celebrityST: celebST), animated: false, completion: nil)
            })
        }
        else { FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if url.absoluteString.contains("TheScore://") {
            CelebrityViewModel().getCelebritySignal(id: url.query!)
                .flatMapError { _ in .empty }
                .startWithValues({ celeb in
                let celebST = CelebrityStruct(
                    id: celeb.id,
                    imageURL: celeb.picture3x,
                    nickName: celeb.nickName,
                    kingName: celeb.kingName,
                    prevScore: celeb.prevScore,
                    prevWeek: celeb.prevWeek,
                    prevMonth: celeb.prevMonth,
                    index: celeb.index,
                    sex: celeb.sex,
                    isFollowed: celeb.isFollowed,
                    isTrending: celeb.isTrending)
                app.keyWindow!.rootViewController!.present(DetailViewController(celebrityST: celebST), animated: false, completion: nil)
            })
        }
        else if Twitter.sharedInstance().application(app, open:url, options: options) { return true }
        else if FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: nil) { return true }
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard userActivity.activityType == CelebrityStruct.domainIdentifier else { return true }
        guard let id = userActivity.userInfo!["id"] else { return true }
        
        let celebST = CelebrityStruct(
            id: id as! String,
            imageURL: userActivity.userInfo!["imageURL"] as! String,
            nickName: userActivity.userInfo!["nickname"] as! String,
            kingName: userActivity.userInfo!["kingName"] as! String,
            prevScore: userActivity.userInfo!["prevScore"] as! Double,
            prevWeek: userActivity.userInfo!["prevWeek"] as! Double,
            prevMonth: userActivity.userInfo!["prevMonth"] as! Double,
            index: userActivity.userInfo!["index"] as! Int,
            sex: userActivity.userInfo!["sex"] as! Bool,
            isFollowed: userActivity.userInfo!["isFollowed"] as! Bool,
            isTrending: userActivity.userInfo!["isTrending"] as! Bool)
        
        application.keyWindow!.rootViewController!.present(DetailViewController(celebrityST: celebST), animated: false, completion: nil)
        return true
    }
}
