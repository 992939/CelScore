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
    let cognitoIdentityPoolId = "us-east-1:7201b11b-c8b4-443b-9918-cf6913c05a21"
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        Parse.enableLocalDatastore()
        Parse.setApplicationId("uzf1XbBjfA1xeajeEbsnksn7QhRKIJ4GiQlGDHYa", clientKey:"lN3gZKln1LxwysbYoRuJAaSpNmgOEhZllx9PTjDF")
        
        let credentialsProvider : AWSCredentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: cognitoIdentityPoolId)
        let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        
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
        let userVM = UserViewModel(username: "Gary", password: "myPassword", email: "gmensah@gmail.com")
        
        /* Daily updates of the LocalDataStore with Celebrity Info */
//                let updateLocalDataStoreWithCelebrityInfoSignal : RACSignal = RACSignal.defer { () -> RACSignal! in
//                    return celscoreVM.recurringUpdateDataStoreSignal(classTypeName: "Celebrity", frequency: CelScoreViewModel.periodSetting.Daily.rawValue)
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
//                    return celscoreVM.recurringUpdateDataStoreSignal(classTypeName: "List", frequency: CelScoreViewModel.periodSetting.Daily.rawValue)
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
        
        /* Daily storage of ratings on AWS S3 */
        let updateAWSS3WithUserRatingsSignal : RACSignal = RACSignal.defer { () -> RACSignal! in
            return userVM.recurringUpdateAWSS3Signal(frequency: CelScoreViewModel.periodSetting.Daily.rawValue)
        }
        
        
        return celscoreVM
    }
}
