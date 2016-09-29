//
//  CelScoreViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AWSCore
import SwiftyJSON
import RealmSwift
import ReactiveCocoa
import Social
import Result
import Accounts


public typealias NewCelebInfo = (text: String, image: String)


struct CelScoreViewModel {
    
    func getFromAWSSignal(dataType: AWSDataType) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            let serviceClient = CACelScoreAPIClient(forKey: "anonymousAccess")
            serviceClient.APIKey = Constants.kAPIKey
            let awsCall : AWSTask
            switch dataType {
            case .Celebrity: awsCall = serviceClient.celebinfoscanservicePost()
            case .List: awsCall = serviceClient.celeblistsservicePost()
            case .Ratings: awsCall = serviceClient.celebratingservicePost()
            }
            
            awsCall.continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.sendFailed(task.error!); return task }
                guard task.cancelled == false else { observer.sendInterrupted(); return task }
                
                let myData = task.result as! String
                let json = JSON(data: myData.dataUsingEncoding(NSUTF8StringEncoding)!)
                json["Items"].arrayValue.forEach({ data in
                    let awsObject : Object
                    switch dataType {
                    case .Celebrity: awsObject = CelebrityModel(json: data)
                    case .List: awsObject = ListsModel(json: data)
                    case .Ratings: awsObject = RatingsModel(json: data)
                    }
                    
                    dispatch_async(dispatch_get_main_queue()){
                        let realm = try! Realm()
                        realm.beginWrite()
                        realm.add(awsObject, update: true)
                        try! realm.commitWrite()
                    }
                })
                observer.sendNext(task.result!)
                observer.sendCompleted()
                return task
            })
        }
    }
    
    func getNewCelebsSignal() -> SignalProducer<NewCelebInfo, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebs = realm.objects(CelebrityModel).filter("isNew = %@", true)
            guard celebs.count > 0 else { return observer.sendFailed(.NotFound) }

            let message: String?
            if celebs.count == 1 { message = celebs.first!.nickName + " has been added to the score.\n\n" }
            else { message = celebs.first!.nickName + " and \(celebs.count-1) other celeb(s) have been added to the score. " }
            let completeMessage = message! + "All the recently added celebs are available in the \"New\" section."
            guard celebs.count < 100 else { return observer.sendCompleted() }
            observer.sendNext((completeMessage, celebs.first!.picture3x))
            
            celebs.forEach({ celeb in
                realm.beginWrite()
                celeb.isNew = false
                realm.add(celeb, update: true)
                try! realm.commitWrite() })
            observer.sendCompleted()
        }
    }
    
    func shareVoteOnSignal(socialLogin: SocialLogin, message: String, screenshot: UIImage) -> SignalProducer<SLComposeViewController, NoError> {
        return SignalProducer { observer, disposable in
            let socialVC: SLComposeViewController?
            switch socialLogin {
            case .Twitter: socialVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            default: socialVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            }
            socialVC!.setInitialText("\(message) #voteForMoi")
            socialVC!.addImage(screenshot)
            observer.sendNext(socialVC!)
            observer.sendCompleted()
        }
    }
}
