//
//  AppDelegate.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: Properties
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        Parse.enableLocalDatastore()
        Parse.setApplicationId("uzf1XbBjfA1xeajeEbsnksn7QhRKIJ4GiQlGDHYa", clientKey:"lN3gZKln1LxwysbYoRuJAaSpNmgOEhZllx9PTjDF")
        update()
        
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.backgroundColor = UIColor.whiteColor()
        window.rootViewController = MasterViewController(viewModel: self.update())
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
    
    // MARK: Initialization Logic
    
    func update () -> CelScoreViewModel
    {
        let celscoreVM = CelScoreViewModel()
        
        /* Daily updates of the LocalDataStore with Celebrity Info */
//                let updateLocalDataStoreWithCelebrityInfoSignal : RACSignal = RACSignal.defer { () -> RACSignal! in
//                    return celscoreVM.recurringUpdateDataStoreSignal(classTypeName: "Celebrity", frequency: CelScoreViewModel.periodSetting.Every_Minute.rawValue)
//                }
//        
//                updateLocalDataStoreWithCelebrityInfoSignal.subscribeNext({ (text: AnyObject!) -> Void in
//                    let celebArray : [PFObject] = ((text as? NSArray) as! Array?)!
//                    //let celeb : PFObject = celebArray[1]
//                    //let rating: PFObject = celeb["celebrity_ratings"] as! PFObject
//                    //println("updateLocalDataStoreWithCelebrityInfoSignal: \(rating)")
//                    PFObject.pinAllInBackground(celebArray, withName: "Celebrity", block: { (success :Bool, error :NSError?) -> Void in
//                        if success {
//                            println("updateLocalDataStoreWithCelebrityInfoSignal success")
//                        } else
//                        {
//                            println("updateLocalDataStoreWithCelebrityInfoSignal error")
//                        }
//                    })
//                    }, error: { (text: AnyObject!) -> Void in
//                        println("executionSignals error: \(text)")
//                })
        
        
        /* Daily updates of the LocalDataStore with List */
//                let updateLocalDataStoreWithListSignal : RACSignal = RACSignal.defer { () -> RACSignal! in
//                    return celscoreVM.recurringUpdateDataStoreSignal(classTypeName: "List", frequency: CelScoreViewModel.periodSetting.Every_Minute.rawValue)
//                }
//        
//                updateLocalDataStoreWithListSignal
//                    .subscribeNext({ (text: AnyObject!) -> Void in
//                        let celebArray : [PFObject] = ((text as? NSArray) as! Array?)!
//                        println("updateLocalDataStoreWithListSignal: \(text)")
//                        PFObject.pinAllInBackground(celebArray, withName: "List", block: { (success :Bool, error :NSError?) -> Void in
//                            if success {
//                                println("updateLocalDataStoreWithListSignal success")
//                            } else
//                            {
//                                println("updateLocalDataStoreWithListSignal error")
//                            }
//                        })
//                        }, error: { (text: AnyObject!) -> Void in
//                            println("executionSignals error: \(text)")
//                    })
        
        
        /* Daily updates of the LocalDataStore with ratings */
//        let updateLocalDataStoreWithRatingsSignal : RACSignal = RACSignal.defer { () -> RACSignal! in
//            return celscoreVM.recurringUpdateDataStoreSignal(classTypeName: "ratings", frequency: CelScoreViewModel.periodSetting.Daily.rawValue)
//        }
//        
//        updateLocalDataStoreWithRatingsSignal
//            .subscribeNext({ (text: AnyObject!) -> Void in
//                let celebArray : [PFObject] = ((text as? NSArray) as! Array?)!
//                println("updateLocalDataStoreWithListSignal: \(text)")
//                PFObject.pinAllInBackground(celebArray, withName: "ratings", block: { (success :Bool, error :NSError?) -> Void in
//                    if success {
//                        println("updateLocalDataStoreWithRatingsSignal success")
//                    } else
//                    {
//                        println("updateLocalDataStoreWithRatingsSignal error")
//                    }
//                })
//                }, error: { (text: AnyObject!) -> Void in
//                    println("executionSignals error: \(text)")
//            })
        
        return celscoreVM
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}
