//
//  CelScoreViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import SwiftyJSON
import RealmSwift
import ReactiveCocoa
import AIRTimer
import Social
import Result


struct CelScoreViewModel {
    
    func checkNetworkStatusSignal() -> SignalProducer<Bool, NoError> {
        return SignalProducer { observer, disposable in
            observer.sendNext(Reachability.isConnectedToNetwork())
        }
    }
    
    func getFromAWSSignal(dataType dataType: AWSDataType, timeInterval: NSTimeInterval = 10) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            
            let serviceClient = BECelScoreAPIClient(forKey: "anonymousAccess")
            serviceClient.APIKey = Constants.kAPIKey
        
            let awsCall : AWSTask
            switch dataType {
            case .Celebrity: awsCall = serviceClient.celebinfoscanservicePost()
            case .List: awsCall = serviceClient.celeblistsservicePost()
            case .Ratings: awsCall = serviceClient.celebratingservicePost()
            }
            
            let block = awsCall.continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.sendFailed(task.error!); return task }
                guard task.cancelled == false else { observer.sendInterrupted(); return task }
                
                let myData = task.result as! String
                let json = JSON(data: myData.dataUsingEncoding(NSUTF8StringEncoding)!)
                json["Items"].arrayValue.forEach({ data in
                    let awsObject : Object
                    switch dataType {
                    case .Celebrity:
                        awsObject = CelebrityModel(json: data)
                    case .List: awsObject = ListsModel(json: data)
                    case .Ratings: awsObject = RatingsModel(json: data)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()){
                        let realm = try! Realm()
                        realm.beginWrite()
                        realm.add(awsObject, update: true)
                        try! realm.commitWrite()
                        //print(awsObject)
                    }
                })
                observer.sendNext(task.result!)
                return task
            })
            AIRTimer.every(timeInterval) { timer in block }
            block
        }
    }
    
    func shareVoteOnSignal(socialLogin socialLogin: SocialLogin, message: String) -> SignalProducer<SLComposeViewController, NoError> {
        return SignalProducer { observer, disposable in
            let socialVC: SLComposeViewController?
            switch socialLogin {
            case .Twitter: socialVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            default: socialVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            }
            socialVC!.setInitialText("\(message) #PeopleLieNumbersDont")
            observer.sendNext(socialVC!)
            observer.sendCompleted()
        }
    }
}
