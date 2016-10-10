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
import ReactiveSwift
import FBSDKCoreKit
import SafariServices


@UIApplicationMain

final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Property
    var window: UIWindow?
    
    //MARK: Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         UIApplication.shared.statusBarStyle = .lightContent
        
        //BuddyBuild
        BuddyBuildSDK.setup()
        
//        //ArmChair
//        Armchair.appID("783417076")
       
        //Realm
        let config = Realm.Configuration(
            schemaVersion: 26,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 26 {
                    migration.enumerateObjects(ofType: CelebrityModel.className()) { oldObject, newObject in
                        newObject!["daysOnThrone"] = 0
                    }
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        //AWS
        AWSLogger.default().logLevel = .error
        let configuration = AWSServiceConfiguration(region: .usEast1, credentialsProvider: Constants.kCredentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let configurationAnonymous = AWSServiceConfiguration(region: .usEast1, credentialsProvider: AWSAnonymousCredentialsProvider())
        CACelScoreAPIClient.register(with: configurationAnonymous, forKey: "anonymousAccess")
        
        //UI
        CelScoreViewModel().getFromAWSSignal(dataType: .list).start()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let nav: NavigationDrawerController = NavigationDrawerController(rootViewController: MasterViewController(), leftViewController: SettingsViewController())
        nav.contentViewController.view.backgroundColor = UIColor.clear
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

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.absoluteString.contains("TheScore://") {
            CelebrityViewModel().getCelebritySignal(id: url.query!)
                .flatMapError { _ in SignalProducer.empty }
                .startWithValues({ celeb in
                let celebST = CelebrityStruct(
                    id: celeb.id,
                    imageURL: celeb.picture3x,
                    nickname: celeb.nickName,
                    prevScore: celeb.prevScore,
                    sex: celeb.sex,
                    isFollowed: celeb.isFollowed)
                application.keyWindow!.rootViewController!.present(DetailViewController(celebrityST: celebST), animated: false, completion: nil)
            })
        }
        else { FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if url.absoluteString.contains("TheScore://") {
            CelebrityViewModel().getCelebritySignal(id: url.query!)
                .flatMapError { _ in SignalProducer.empty }
                .startWithValues({ celeb in
                let celebST = CelebrityStruct(
                    id: celeb.id,
                    imageURL: celeb.picture3x,
                    nickname: celeb.nickName,
                    prevScore: celeb.prevScore,
                    sex: celeb.sex,
                    isFollowed: celeb.isFollowed)
                app.keyWindow!.rootViewController!.present(DetailViewController(celebrityST: celebST), animated: false, completion: nil)
            })
        }
        else if Twitter.sharedInstance().application(app, open:url, options: options) { return true }
        else if FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as! String, annotation: nil) { return true }
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard userActivity.activityType == CelebrityStruct.domainIdentifier else { return true }
        guard let id = userActivity.userInfo!["id"] else { return true }
        
        let celebST = CelebrityStruct(
            id: id as! String,
            imageURL: userActivity.userInfo!["imageURL"] as! String,
            nickname: userActivity.userInfo!["nickname"] as! String,
            prevScore: userActivity.userInfo!["prevScore"] as! Double,
            sex: userActivity.userInfo!["sex"] as! Bool,
            isFollowed: userActivity.userInfo!["isFollowed"]as! Bool)
        
        application.keyWindow!.rootViewController!.present(DetailViewController(celebrityST: celebST), animated: false, completion: nil)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        RateLimit.execute(name: "updateRatings", limit: Constants.kUpdateRatings) { CelScoreViewModel().getFromAWSSignal(dataType: .ratings).start() }
    }
    func applicationWillResignActive(_ application: UIApplication) { }
    func applicationDidEnterBackground(_ application: UIApplication) { }
    func applicationWillEnterForeground(_ application: UIApplication) { }
}
