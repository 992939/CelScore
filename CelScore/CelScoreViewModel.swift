//
//  CelScoreViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import SwiftyJSON

class CelScoreViewModel: NSObject {
    
    //MARK: Properties
    let cognitoIdentityPoolId = "us-east-1:7201b11b-c8b4-443b-9918-cf6913c05a21"
    dynamic var displayedCelebrityListVM : CelebrityListViewModel
    dynamic var searchedCelebrityListVM : CelebrityListViewModel

    enum periodSetting: NSTimeInterval {
        case Every_Minute = 60.0
        case Daily = 86400.0
    }
    
    //MARK: Initializers
    override init() {
        
        displayedCelebrityListVM = CelebrityListViewModel(listName: "#CelScore")
        searchedCelebrityListVM = CelebrityListViewModel(searchToken: "")

        super.init()
    }
    
//    //MARK: Methods
//    func checkNetworkConnectivitySignal() -> RACSignal {
//        return RACSignal.createSignal({
//            (subscriber: RACSubscriber!) -> RACDisposable! in
//            if IJReachability.isConnectedToNetwork() {
//                print("Connected!.")
//                subscriber.sendNext(1)
//                subscriber.sendCompleted()
//            } else
//            {
//                print("Not connected!")
//                subscriber.sendError(NSError())
//            }
//            return nil
//        })
//    }
    
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
                    let celebrity = CelebrityModel(value: celeb.dictionaryObject!)
                    print(celebrity)
                    
                    let realm = RLMRealm.defaultRealm()
                    realm.beginWriteTransaction()
                    celebrity.isSynced = true
                    realm.addOrUpdateObject(celebrity)
                    try! realm.commitWriteTransaction()
                })
                
                sendNext(sink, task.result)
                sendCompleted(sink)
                return task
            })
        }
    }

    
    func recurringUpdateDataStoreSignal(classTypeName classTypeName: String, frequency: NSTimeInterval) -> RACSignal {
        let scheduler : RACScheduler =  RACScheduler(priority: RACSchedulerPriorityDefault)
        let recurringSignal = RACSignal.interval(frequency, onScheduler: scheduler).startWith(NSDate())
        
        return recurringSignal.flattenMap({ (text: AnyObject!) -> RACStream! in
            return RACSignal() //self.updateLocalDataStoreSignal(classTypeName: classTypeName)
            })
    }
    
    func updateCelebritiesCelScore() -> RACSignal {
        return RACSignal.createSignal({
            (subscriber: RACSubscriber!) -> RACDisposable! in
//            var query = PFQuery(className: "Celebrity")
//            query.includeKey("celebrity_ratings")
//            query.findObjectsInBackgroundWithBlock({ (celebrityArray: [AnyObject]?, error: NSError?) -> Void in
//                if error == nil {
//                    for celebrity in celebrityArray! {
//                        let celeb = celebrity as! PFObject
//                        var ratings: PFObject = celeb["celebrity_ratings"] as! PFObject
//                        ratings.removeObjectForKey("voteNumber")
//                        let ratingKeys = ratings.allKeys()
//                        let ratingValues = ratingKeys.map({ratings[$0 as! String]! as! Double})
//                        let sumOfRatings = ratingValues.reduce(0){ return $0 + $1}
//                        let newCelScore : Double = sumOfRatings / 10
//                        
//                        celebrity.setObject(newCelScore, forKey: "currentScore")
//                    }
//                    subscriber.sendNext(celebrityArray)
//                    subscriber.sendCompleted()
//                } else
//                {
//                    subscriber.sendError(NSError.init(domain: "com.celscore", code: 1, userInfo: nil))
//                }
//            })
            return nil
        })
    }
    
    func recurringUpdateCelebritiesCelScoreSignal(frequency frequency: NSTimeInterval) -> RACSignal {
        let scheduler : RACScheduler =  RACScheduler(priority: RACSchedulerPriorityDefault)
        let recurringSignal = RACSignal.interval(frequency, onScheduler: scheduler).startWith(NSDate())
        
        return recurringSignal.flattenMap({ (text: AnyObject!) -> RACStream! in
            return self.updateCelebritiesCelScore()
        })
    }
}
