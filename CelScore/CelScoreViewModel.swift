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

final class CelScoreViewModel: NSObject {
    
    //MARK: Properties
    let cognitoIdentityPoolId = "us-east-1:7201b11b-c8b4-443b-9918-cf6913c05a21"
    let timeNotifier = MutableProperty<String>("")

    enum periodSetting: NSTimeInterval {
        case Every_Minute = 60.0
        case Daily = 86400.0
    }
    
    enum AWSDataType {
        case Celebrity
        case List
        case Ratings
    }
    
    //MARK: Initializers
    override init() {
        super.init()
        
        //self.timeNotifier <~ self.timerSignal()
        
        self.timeNotifier.producer
            .promoteErrors(NSError.self)
            .flatMap(.Latest) { (token: String) -> SignalProducer<AnyObject!, NSError> in
                return self.getFromAWSSignal(.Celebrity)
            }
            .observeOn(QueueScheduler.mainQueueScheduler)
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("timeNotifier Value: \(value)")
                case let .Error(error):
                    print("timeNotifier Error: \(error)")
                case .Completed:
                    print("timeNotifier Completed")
                case .Interrupted:
                    print("timeNotifier Interrupted")
                }
        }
    }
    
    //MARK: Methods
    func checkNetworkConnectivitySignal() -> SignalProducer<ReachabilityStatus, NSError> {
        return SignalProducer {
            sink, _ in
            
            let reachability = Monitor()
            reachability!.startMonitoring()

            if reachability?.reachabilityStatus == .NotReachable {
                sendError(sink, NSError(domain: "com.CelScore.Network", code: 1, userInfo: nil))
            } else
            {
                sendNext(sink, (reachability?.reachabilityStatus)!)
            }
        }
    }
    
    func getFromAWSSignal(dataType: AWSDataType) -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            //AWSLogger.defaultLogger().logLevel = .Verbose
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            let serviceClient = CSCelScoreAPIClient.defaultClient()
        
            let awsCall : AWSTask
            switch dataType {
            case .Celebrity: awsCall = serviceClient.celebinfoscanservicePost()
            case .List: awsCall = serviceClient.celeblistsservicePost()
            case .Ratings: awsCall = serviceClient.celebratingservicePost()
            }

            awsCall.continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else {
                    sendError(sink, task.error)
                    return task
                }
                guard task.cancelled == false else {
                    sendInterrupted(sink)
                    return task
                }
                
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
                })
                
                sendNext(sink, task.result)
                sendCompleted(sink)
                return task
            })
        }
    }
    
    func timerSignal() -> SignalProducer<String, NoError> {
        var count = 0
        return SignalProducer {
            sink, _ in
            
            AIRTimer.every(5, userInfo: "FIRE!!") { timer in
                sendNext(sink, "tick #\(count++)")
            }
        }
    }
}
