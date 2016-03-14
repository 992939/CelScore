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
    
    //MARK: Properties
    private let isFacebookAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) //TODO: remove?
    private let isTwitterAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    
    //MARK: Methods
    func checkNetworkStatusSignal() -> SignalProducer<Bool, NoError> {
        return SignalProducer { observer, disposable in
            observer.sendNext(Reachability.isConnectedToNetwork())
        }
    }
    
    func getFromAWSSignal(dataType dataType: AWSDataType, timeInterval: NSTimeInterval = 10) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration

            let serviceClient = PROCelScoreAPIClient.defaultClient()
            serviceClient.APIKey = Constants.kAPIKey
        
            let awsCall : AWSTask
            switch dataType {
            case .Celebrity: awsCall = serviceClient.celebinfoscanservicePost()
            case .List: awsCall = serviceClient.celeblistsservicePost()
            case .Ratings: awsCall = serviceClient.celebratingservicePost()
            }
            
            let block = awsCall.continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { print(task.error!); observer.sendFailed(task.error!); return task }
                guard task.cancelled == false else { observer.sendInterrupted(); return task }
                
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
                    //print(awsObject)
                })
                observer.sendNext(task.result!)
                return task
            })
            AIRTimer.every(timeInterval) { timer in block }
            block
        }
    }
    
    func getFortuneCookieSignal(cookieType cookieType: CookieType) -> SignalProducer<String, NoError> {
        return SignalProducer { observer, disposable in
            let fortuneCookieSays: String?
            let cookies = Constants.fortuneCookies
            var newCookies = cookieType == .Positive ? Array(cookies[15..<cookies.count]) : Array(cookies[0..<14])
            
            let realm = try! Realm()
            realm.beginWrite()
            let cookieList = realm.objects(CookieModel).filter("id = %@", cookieType.rawValue).first as CookieModel?
            if cookieList?.list.count > 0 {
                let randomPick = Int(arc4random_uniform(UInt32(cookieList!.list.count)))
                let cookie: Chip = cookieList!.list.removeAtIndex(randomPick)
                realm.add(cookieList!, update: true)
                fortuneCookieSays = newCookies[cookie.index]
            } else {
                let randomPick = Int(arc4random_uniform(UInt32(newCookies.count)))
                fortuneCookieSays = newCookies.removeAtIndex(randomPick)
                let list = CookieModel()
                for(index, _) in newCookies.enumerate() { list.list.append(Chip(index: index)) }
                realm.add(list, update: true)
            }
            try! realm.commitWrite()
            observer.sendNext("\"\(fortuneCookieSays!) Thank you for voting.\"")
            observer.sendCompleted()
        }
    }
    
    func shareVoteOnSignal(socialNetwork socialNetwork: SocialNetwork, message: String) -> SignalProducer<SLComposeViewController, NoError> {
        return SignalProducer { observer, disposable in
            let socialVC: SLComposeViewController?
            switch socialNetwork {
            case .Twitter: socialVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            case .Facebook: socialVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            }
            socialVC!.setInitialText("#PSA: \(message) #PLND")
            observer.sendNext(socialVC!)
            observer.sendCompleted()
        }
    }
}
