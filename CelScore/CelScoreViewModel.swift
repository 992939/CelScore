
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
import Social

final class CelScoreViewModel: NSObject {
    
    //MARK: Properties
    let okFacebook: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
    let okTwitter: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    let okWeibo: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeSinaWeibo)
    let timeNotifier = MutableProperty<String>("")
    enum periodSetting: NSTimeInterval { case Every_Minute = 60.0, Daily = 86400.0 }
    enum SocialNetwork: Int { case Twitter = 0, Facebook, Weibo }
    enum AWSDataType { case Celebrity, List, Ratings }
    enum CookieType: String { case Positive, Negative }
    
    
    //MARK: Initializers
    override init() { super.init() }
    
    
    //MARK: Methods
    func checkNetworkConnectivitySignal() -> SignalProducer<ReachabilityStatus, NoError> {
        return SignalProducer { sink, _ in
            
            let reachability = Monitor()
            reachability!.startMonitoring()
            sendNext(sink, (reachability?.reachabilityStatus)!)
        }
    }
    
    func getFromAWSSignal(dataType dataType: AWSDataType, timeInterval: NSTimeInterval = 10) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in

            let serviceClient = CSCelScoreAPIClient.defaultClient()
            serviceClient.APIKey = "eljwrWL80O2OOXa6ZTdYu6n5p0yJ5f5o2BzG6QNG" //TODO: encrypt
        
            let awsCall : AWSTask
            switch dataType {
            case .Celebrity: awsCall = serviceClient.celebinfoscanservicePost()
            case .List: awsCall = serviceClient.celeblistsservicePost()
            case .Ratings: awsCall = serviceClient.celebratingservicePost()
            }
            
            let block = awsCall.continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                guard task.error == nil else { sendError(sink, task.error!); return task }
                guard task.cancelled == false else { sendInterrupted(sink); return task }
                
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
                sendNext(sink, task.result!)
                return task
            })
            AIRTimer.every(timeInterval, userInfo: nil) { timer in block }
            block
        }
    }
    
    func getFortuneCookieSignal(cookieType cookieType: CookieType) -> SignalProducer<String, NSError> {
        return SignalProducer { sink, _ in
            
            let realm = try! Realm()
            realm.beginWrite()
            let predicate = NSPredicate(format: "id = %@", cookieType.rawValue)
            let cookieList = realm.objects(CookieModel).filter(predicate).first as CookieModel?
            
            
            if let oldCookies = cookieList {
                var newCookies = Constants.fortuneCookies
                oldCookies.list.forEach({ (chip) -> () in newCookies.removeAtIndex(chip.index) })
                let index = Int(arc4random_uniform(UInt32(newCookies.count)))
                oldCookies.list.append(Chip(index: index))
                realm.add(oldCookies, update: true)
                
            } else
            {
                let index = Int(arc4random_uniform(UInt32(Constants.fortuneCookies.count)))
                let newCookie = CookieModel(id: cookieType.rawValue, chip: Chip(index: index))
                realm.add(newCookie, update: true)
            }
            try! realm.commitWrite()
            sendNext(sink, "sush!")
            sendCompleted(sink)
        }
    }
    
    func shareVoteOnSignal(socialNetwork socialNetwork: SocialNetwork) -> SignalProducer<SLComposeViewController, NoError> {
        return SignalProducer { sink, _ in
            
            var socialVC: SLComposeViewController
            switch socialNetwork {
            case .Twitter: socialVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            case .Facebook: socialVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            case .Weibo: socialVC = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo)
            }
            socialVC.setInitialText("Sharing CelScore")
            //TODO: socialVC.addImage()
            
            sendNext(sink, socialVC)
            sendCompleted(sink)
        }
    }
}
