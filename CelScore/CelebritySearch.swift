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
    
    var userActivityUserInfo: [String: AnyObject] {
        return ["id": id as AnyObject,
         "imageURL": imageURL as AnyObject,
         "nickname": nickname as AnyObject,
         "prevScore": prevScore as AnyObject,
         "sex":sex as AnyObject,
         "isFollowed": isFollowed as AnyObject] }
    
    var userActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: CelebrityStruct.domainIdentifier)
        activity.title = nickname
        activity.userInfo = userActivityUserInfo
        activity.keywords = [nickname, "celebrity", "stars", "consensus", "celscore", "news", "score"]
        activity.contentAttributeSet = attributeSet
        activity.isEligibleForSearch = true
        activity.isEligibleForPublicIndexing = true
        return activity
    }
    var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContact as String)
        attributeSet.title = nickname
        let gender: String = sex == true ? "him" : "her"
        attributeSet.contentDescription = "CelScore:\(prevScore.roundToPlaces(places: 2)).\nVote for \(gender) on the Courthouse of Public Opinion."
        attributeSet.thumbnailData = try? Data(contentsOf: URL(string: imageURL)!)
        attributeSet.supportsPhoneCall = false
        attributeSet.keywords = [String(prevScore)]
        return attributeSet
    }
}


