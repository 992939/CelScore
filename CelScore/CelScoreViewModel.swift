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
import AIRTimer
import Social
import Result


final class CelScoreViewModel: NSObject {
    
    //MARK: Properties
    let isFacebookAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
    let isTwitterAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
    func checkNetworkStatusSignal() -> SignalProducer<Bool, NoError> {
        return SignalProducer { observer, disposable in
            observer.sendNext(Reachability.isConnectedToNetwork())
        }
    }
    
    func getFromAWSSignal(dataType dataType: AWSDataType, timeInterval: NSTimeInterval = 10) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { observer, disposable in

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
                    print(awsObject)
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
            let predicate = NSPredicate(format: "id = %@", cookieType.rawValue)
            let cookieList = realm.objects(CookieModel).filter(predicate).first as CookieModel?
            
            if let oldCookies = cookieList {
                let eightyPercent = Int(0.8 * Double(newCookies.count))
                oldCookies.list.forEach({ (chip) -> () in newCookies.removeAtIndex(chip.index) }) //TODO: out of bounds error
                let index = Int(arc4random_uniform(UInt32(newCookies.count)))
                oldCookies.list.append(Chip(index: index))

                if oldCookies.list.count > eightyPercent {
                    realm.add(CookieModel(id: cookieType.rawValue, chip: Chip(index: index)), update: true)
                } else { realm.add(oldCookies, update: true) }
                fortuneCookieSays = newCookies[index]
            } else
            {
                let index = Int(arc4random_uniform(UInt32(newCookies.count)))
                let newCookie = CookieModel(id: cookieType.rawValue, chip: Chip(index: index))
                realm.add(newCookie, update: true)
                fortuneCookieSays = newCookies[index]
            }
            try! realm.commitWrite()
            observer.sendNext("\"\(fortuneCookieSays!) Thank you for voting.\"")
            observer.sendCompleted()
        }
    }
    
    func shareVoteOnSignal(socialNetwork socialNetwork: SocialNetwork, message: String) -> SignalProducer<SLComposeViewController, NoError> {
        return SignalProducer { observer, disposable in
            
            var socialVC: SLComposeViewController
            switch socialNetwork {
            case .Twitter: socialVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            case .Facebook: socialVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            }
            socialVC.setInitialText("#PSA: \(message) #PLND")
            observer.sendNext(socialVC)
            observer.sendCompleted()
        }
    }
}
