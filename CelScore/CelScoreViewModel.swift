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
    let cognitoIdentityPoolId = "us-east-1:d08ddeeb-719b-4459-9a8f-91cb108a216c"
    var displayedCelebrityListVM : CelebrityListViewModel
    var searchedCelebrityListVM : CelebrityListViewModel
    let timeNotifier = MutableProperty("")

    enum periodSetting: NSTimeInterval {
        case Every_Minute = 60.0
        case Daily = 86400.0
    }
    
    //MARK: Initializers
    override init() {
        self.displayedCelebrityListVM = CelebrityListViewModel()
        self.searchedCelebrityListVM = CelebrityListViewModel(searchToken: "")

        super.init()
        
        self.timeNotifier <~ self.createSignal()
        
        self.timeNotifier.producer
            .promoteErrors(NSError.self)
            .flatMap(.Latest) { (token: String) -> SignalProducer<AnyObject!, NSError> in
                return self.getCelebsInfoFromAWSSignal()
            }
            .observeOn(QueueScheduler.mainQueueScheduler).start(Event.sink(error: {
                print("BIG MISTAKE \($0)")
                },
                next: {
                    response in
                    print("Search results: \(response)")
            }))
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
    
    func getCelebsInfoFromAWSSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            let serviceClient = CSCelScoreAPIClient.defaultClient()
            serviceClient.celebinfoscanservicePost().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
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
                json["Items"].arrayValue.forEach({ celeb in
                    
                    let celebrity = CelebrityModel(dictionary: celeb.dictionaryObject!)

                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.add(celebrity, update: true)
                    try! realm.commitWrite()
                })
                
                sendNext(sink, task.result)
                sendCompleted(sink)
                return task
            })
        }
    }
    
    func getCelebRatingsFromAWSSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            let serviceClient = CSCelScoreAPIClient.defaultClient()
            serviceClient.celebratingservicePost().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
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
                json["Items"].arrayValue.forEach({ celebRatings in
                    
                    let ratings = RatingsModel(dictionary: celebRatings.dictionaryObject!)
                    
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.add(ratings, update: true)
                    try! realm.commitWrite()
                })
                
                sendNext(sink, task.result)
                sendCompleted(sink)
                return task
            })
        }
    }
    
    func getCelebListsFromAWSSignal() -> SignalProducer<AnyObject!, NSError> {
        return SignalProducer {
            sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: self.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            let serviceClient = CSCelScoreAPIClient.defaultClient()
            serviceClient.celeblistsservicePost().continueWithBlock({ (task: AWSTask!) -> AnyObject! in
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
                json["Items"].arrayValue.forEach({ list in
                    
                    let celebList = ListsModel(dictionary: list.dictionaryObject!)
                    
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.add(celebList, update: true)
                    try! realm.commitWrite()
                })
                
                sendNext(sink, task.result)
                sendCompleted(sink)
                return task
            })
        }
    }
    
    func createSignal() -> SignalProducer<String, NoError> {
        var count = 0
        return SignalProducer {
            sink, _ in
            
            AIRTimer.every(5, userInfo: "FIRE!!") { timer in
                sendNext(sink, "tick #\(count++)")
            }
        }
    }
}
