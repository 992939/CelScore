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


extension CelebrityStruct {
    
    static let domainIdentifier = "com.GreyEcology.CelebrityScore.Celebrity"
    
    var userActivityUserInfo: [NSObject: AnyObject] {
        return ["id": id,
         "imageURL": imageURL,
         "nickname": nickname,
         "prevScore": prevScore,
         "sex":sex,
         "isFollowed": isFollowed] }
    
    var userActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: CelebrityStruct.domainIdentifier)
        activity.title = nickname
        activity.userInfo = userActivityUserInfo
        activity.keywords = [nickname, "celebrity", "stars", "consensus", "celscore", "news", "score"]
        activity.contentAttributeSet = attributeSet
        activity.eligibleForSearch = true
        activity.eligibleForPublicIndexing = true
        return activity
    }
    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContact as String)
        attributeSet.title = nickname
        let gender: String = sex == true ? "him" : "her"
        attributeSet.contentDescription = "Celscore: \(prevScore.roundToPlaces(2))\nVote for \(gender) on the courthouse of Public Opinion."
        attributeSet.thumbnailData = NSData(contentsOfURL: NSURL(string: imageURL)!)
        attributeSet.supportsPhoneCall = false
        attributeSet.keywords = [String(prevScore)]
        return attributeSet
    }
}


