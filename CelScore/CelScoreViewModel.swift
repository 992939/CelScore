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
import AIRTimer
import Social
import Result


public typealias NewCelebInfo = (text: String, image: String)


struct CelScoreViewModel {
    
    func getFromAWSSignal(dataType dataType: AWSDataType) -> SignalProducer<AnyObject, NSError> {
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
            print("getNewCelebsSignal A")
            let realm = try! Realm()
            let celebs = realm.objects(CelebrityModel).filter("isNew = %@", true)
            guard celebs.count > 0 else { return observer.sendFailed(.NotFound) }

            var message: String = celebs.first!.nickName + " has been added to the score!\n\n"
            if celebs.count == 2 { message = message + "\(celebs.count-1) more star has been added to the score. " }
            else if celebs.count > 2 { message = message + "\(celebs.count-1) more stars have been added to the score. " }
            message = message + "All the recently added stars are available in the \"New\" section."
            guard celebs.count < 100 else { return observer.sendCompleted() }
            observer.sendNext((message, celebs.first!.picture3x))
            print("getNewCelebsSignal B")
            
            celebs.forEach({ celeb in
                realm.beginWrite()
                celeb.isNew = false
                realm.add(celeb, update: true)
                try! realm.commitWrite() })
            observer.sendCompleted()
        }
    }

    
    func shareVoteOnSignal(socialLogin socialLogin: SocialLogin, message: String, screenshot: UIImage) -> SignalProducer<SLComposeViewController, NoError> {
        return SignalProducer { observer, disposable in
            let socialVC: SLComposeViewController?
            switch socialLogin {
            case .Twitter: socialVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            default: socialVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            }
            socialVC!.setInitialText("\(message) #PLND")
            socialVC!.addImage(screenshot)
            observer.sendNext(socialVC!)
            observer.sendCompleted()
        }
    }
}
