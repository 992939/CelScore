//
//  CelScoreViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import ReactiveCocoa
import WillowTreeReachability
import AIRTimer
import Social

final class CelScoreViewModel: NSObject {
    
    //MARK: Properties
    let okFacebook: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
    let okTwitter: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    let okWeibo: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeSinaWeibo)
    let timeNotifier = MutableProperty<String>("")
    enum periodSetting: NSTimeInterval { case Every_Minute = 60.0, Daily = 86400.0 }
    enum SocialNetwork: Int { case Twitter = 0, Facebook, Weibo }
    enum AWSDataType { case Celebrity, List, Ratings }
    
    
    //MARK: Initializers
    override init() { super.init() }
    
    
    //MARK: Methods
    func checkNetworkConnectivitySignal() -> SignalProducer<ReachabilityStatus, NoError> {
        return SignalProducer { sink, _ in
            
            let reachability = Monitor()
            reachability!.startMonitoring()
            sendNext(sink, (reachability?.reachabilityStatus)!)
        }
    }
    
    func getFromAWSSignal(dataType dataType: AWSDataType, timeInterval: NSTimeInterval = 10) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: Constants.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            let serviceClient = CSCelScoreAPIClient.defaultClient()
        
            let awsCall : AWSTask
            switch dataType {
            case .Celebrity: awsCall = serviceClient.celebinfoscanservicePost()
            case .List: awsCall = serviceClient.celeblistsservicePost()
            case .Ratings: awsCall = serviceClient.celebratingservicePost()
            }
            
            AIRTimer.every(timeInterval, userInfo: nil) { timer in
                awsCall.continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                    guard task.error == nil else { sendError(sink, task.error); return task }
                    guard task.cancelled == false else { sendInterrupted(sink); return task }
                    
                    let myData = task.result as! String
                    let json = JSON(data: myData.dataUsingEncoding(NSUTF8StringEncoding)!)
                    json["Items"].arrayValue.forEach({ data in
                        let awsObject : Object
                        switch dataType {
                        case .Celebrity: awsObject = CelebrityModel(dictionary: data.dictionaryObject!)
                        case .List: awsObject = ListsModel(dictionary: data.dictionaryObject!)
                        case .Ratings: awsObject = RatingsModel(dictionary: data.dictionaryObject!)
                        }
                        let realm = try! Realm()
                        realm.beginWrite()
                        realm.add(awsObject, update: true)
                        try! realm.commitWrite()
                        print(awsObject)
                    })
                    sendNext(sink, task.result)
                    return task
                })
            }
        }
    }
    
    func shareVoteOnSignal(socialNetwork socialNetwork: SocialNetwork) -> SignalProducer<SLComposeViewController, NoError> {
        return SignalProducer { sink, _ in
            
            var socialVC: SLComposeViewController
            switch socialNetwork {
            case .Twitter: socialVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            case .Facebook: socialVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            case .Weibo: socialVC = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo)
            }
            socialVC.setInitialText("Sharing CelScore")
            //TODO: socialVC.addImage()
            
            sendNext(sink, socialVC)
            sendCompleted(sink)
        }
    }
}
