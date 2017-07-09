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
import ReactiveSwift
import Social
import Result
import Accounts


public typealias NewCelebInfo = (text: String, image: String)


struct CelScoreViewModel {
    
    func getFromAWSSignal(dataType: AWSDataType) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            let serviceClient = CACelScoreAPIClient(forKey: "anonymousAccess")!
            serviceClient.apiKey = Constants.kAPIKey
            let awsCall : AWSTask<AnyObject>
            switch dataType {
            case .celebrity: awsCall = serviceClient.celebinfoscanservicePost()
            case .list: awsCall = serviceClient.celeblistsservicePost()
            case .ratings: awsCall = serviceClient.celebratingservicePost()
            }
            
            awsCall.continueWith(block: { (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.send(error: task.error! as NSError); return task }
                guard task.isCancelled == false else { observer.sendInterrupted(); return task }
                
                let myData = task.result as! String
                let json = JSON(data: myData.data(using: String.Encoding.utf8)!)
                let realm = try! Realm()
                realm.beginWrite()
                
                json["Items"].arrayValue.forEach({ data in
                    switch dataType {
                    case .celebrity: realm.add(CelebrityModel(json: data), update: true)
                    case .list: realm.add(ListsModel(json: data), update: true)
                    case .ratings: realm.add(RatingsModel(json: data), update: true)
                    }
                })
                try! realm.commitWrite()
                realm.refresh()
                observer.send(value: task.result!)
                observer.sendCompleted()
                return task
            })
        }
    }
    
    func getNewCelebsSignal() -> SignalProducer<NewCelebInfo, CelebrityError> {
        return SignalProducer { observer, disposable in
            let realm = try! Realm()
            let celebs = realm.objects(CelebrityModel.self).filter("isNew = %@", true)
            guard celebs.count > 0 else { return observer.send(error: .notFound) }

            let message: String?
            if celebs.count == 1 { message = celebs.first!.nickName + " has been added to the score.\n\n" }
            else { message = celebs.first!.nickName + " and \(celebs.count-1) other celeb(s) have been added to the score. " }
            let completeMessage = message! + "All the recently added celebs are available in the \"New\" section."
            guard celebs.count < 100 else { return observer.sendCompleted() }
            observer.send(value: (completeMessage, celebs.first!.picture3x))
            
            celebs.forEach({ celeb in
                realm.beginWrite()
                celeb.isNew = false
                realm.add(celeb, update: true)
                try! realm.commitWrite() })
            observer.sendCompleted()
        }
    }
    
    func shareVoteOnSignal(socialLogin: SocialLogin, message: String) -> SignalProducer<SLComposeViewController, NoError> {
        return SignalProducer { observer, disposable in
            let socialVC: SLComposeViewController?
            switch socialLogin {
            case .twitter: socialVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            default: socialVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            }
            socialVC!.setInitialText(message)
            observer.send(value: socialVC!)
            observer.sendCompleted()
        }
    }
}
