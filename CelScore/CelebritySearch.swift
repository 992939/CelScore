//
//  CelebritySearch.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/23/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices


extension CelebrityModel {
    
    static let domainIdentifier = "com.GreyEcology.CelebrityScore.Celebrity"
    
    var userActivityUserInfo: [String: AnyObject] {
        return ["id": id as AnyObject,
         "imageURL": picture3x as AnyObject,
         "nickName": nickName as AnyObject,
         "prevScore": prevScore as AnyObject,
         "isFollowed": isFollowed as AnyObject] }
    
    var userActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: CelebrityModel.domainIdentifier)
        activity.title = nickName
        activity.userInfo = userActivityUserInfo
        activity.keywords = [nickName, "celebrity", "stars", "crown", "king", "news", "score"]
        activity.contentAttributeSet = attributeSet
        activity.isEligibleForSearch = true
        activity.isEligibleForPublicIndexing = true
        return activity
    }
    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContact as String)
        attributeSet.title = nickName
        attributeSet.contentDescription = "Celeb&Noble: \(nickName) is \(prevScore.roundToPlaces(places: 1))% Hollywood Royalty."
        attributeSet.thumbnailData = try? Data(contentsOf: URL(string: picture3x)!)
        attributeSet.supportsPhoneCall = false
        attributeSet.keywords = [String(prevScore)]
        return attributeSet
    }
}


