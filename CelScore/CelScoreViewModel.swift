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
import AWSS3


final class CelScoreViewModel: NSObject {
    
    //MARK: Properties
    let isFacebookAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
    let isTwitterAvailable: Bool = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    enum periodSetting: NSTimeInterval { case Every_Minute = 60.0, Daily = 86400.0 }
    enum SocialNetwork: Int { case Twitter = 0, Facebook }
    enum AWSDataType { case Celebrity, List, Ratings }
    enum CookieType: String { case Positive, Negative }
    
    //MARK: Initializer
    override init() { super.init() }
    
    //MARK: Methods
    func checkNetworkStatusSignal() -> SignalProducer<Bool, NoError> {
        return SignalProducer { sink, _ in
            sendNext(sink, Reachability.isConnectedToNetwork())
        }
    }
    
    func getFromAWSSignal(dataType dataType: AWSDataType, timeInterval: NSTimeInterval = 10) -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in

            let serviceClient = PROCelScoreAPIClient.defaultClient()
            serviceClient.APIKey = "0XwE760Ybs2iA9rYfl9ya898OeAJMYnd2T9jK5uP" //TODO: encrypt
        
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
    
    func getImagesFromS3Signal() -> SignalProducer<AnyObject, NSError> {
        return SignalProducer { sink, _ in
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.cognitoIdentityPoolId)
            let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
            
            let completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = { (task, location, data, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { if ((error) != nil){ NSLog("Error: %@",error!) }})
                NSLog("Done!")
            }

            let expression = AWSS3TransferUtilityDownloadExpression()
            let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
            
            transferUtility?.downloadToURL(nil, bucket: Constants.S3BucketName, key: Constants.S3DownloadKeyName, expression: expression, completionHander: completionHandler).continueWithBlock { (task) -> AnyObject! in
                if let error = task.error { NSLog("Error: %@", error.localizedDescription) }
                if let exception = task.exception { NSLog("Exception: %@",exception.description) }
                if let _ = task.result { NSLog("Download Starting!") }
                return nil;
            }
        }
    }

    
    func getFortuneCookieSignal(cookieType cookieType: CookieType) -> SignalProducer<String, NSError> {
        return SignalProducer { sink, _ in
            
            let fortuneCookieSays: String?
            var newCookies = Constants.fortuneCookies
            if case .Positive = cookieType { newCookies = Array(newCookies[15..<newCookies.count]) }
            else { newCookies = Array(newCookies[0..<14]) }
            
            let realm = try! Realm()
            realm.beginWrite()
            let predicate = NSPredicate(format: "id = %@", cookieType.rawValue)
            let cookieList = realm.objects(CookieModel).filter(predicate).first as CookieModel?
            
            if let oldCookies = cookieList {
                let eightyPercent = Int(0.8 * Double(newCookies.count))
                oldCookies.list.forEach({ (chip) -> () in newCookies.removeAtIndex(chip.index) })
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
            sendNext(sink, "\(fortuneCookieSays!) Thanks for voting.")
            sendCompleted(sink)
        }
    }
    
    func shareVoteOnSignal(socialNetwork socialNetwork: SocialNetwork) -> SignalProducer<SLComposeViewController, NoError> {
        return SignalProducer { sink, _ in
            
            var socialVC: SLComposeViewController
            switch socialNetwork {
            case .Twitter: socialVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            case .Facebook: socialVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            }
            socialVC.setInitialText("Sharing CelScore")
            //TODO: socialVC.addImage()
            
            sendNext(sink, socialVC)
            sendCompleted(sink)
        }
    }
}
