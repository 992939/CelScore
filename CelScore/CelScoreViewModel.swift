//
//  CelScoreViewModel.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/20/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AWSCore
import SwiftyJSON
import ObjectMapper
import RealmSwift
import ReactiveCocoa
import ReactiveSwift
import Social
import Result
import Accounts


struct CelScoreViewModel {
    
    func getFromAWSSignal(dataType: AWSDataType) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            let serviceClient = JUCelScoreAPIClient(configuration: AWSServiceConfiguration(region: .USEast1, credentialsProvider: AWSAnonymousCredentialsProvider()))
            serviceClient.apiKey = Constants.kAPIKey
            let awsCall : AWSTask<AnyObject>
            switch dataType {
            case .celebrity: awsCall = serviceClient.celebinfoscanservicePost() as! AWSTask<AnyObject>
            case .list: awsCall = serviceClient.celeblistsservicePost() as! AWSTask<AnyObject>
            case .ratings: awsCall = serviceClient.celebratingservicePost() as! AWSTask<AnyObject>
            }
            
            awsCall.continueWith(block: { (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { observer.send(error: task.error! as NSError); return task }
                guard task.isCancelled == false else { observer.sendInterrupted(); return task }
                
                let realm = try! Realm()
                realm.beginWrite()
                
                switch dataType {
                case .celebrity:
                    let celebService: CelebrityService = task.result as! CelebrityService
                    realm.add(celebService.items!, update: true)
                case .list:
                    let celebService: ListsService = task.result as! ListsService
                    realm.add(celebService.items!, update: true)
                case .ratings:
                    let celebService: RatingsService = task.result as! RatingsService
                    realm.add(celebService.items!, update: true)
                }
                try! realm.commitWrite()
                realm.refresh()
                observer.send(value: task.result!)
                observer.sendCompleted()
                return task
            })
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
