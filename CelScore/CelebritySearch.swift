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
    
    //MARK: Properties
    public static let domainIdentifier = "com.GreyEcology.CelebrityScore.Celebrity"
    public var userActivityUserInfo: [NSObject: AnyObject] { return ["id": id, "imageURL": imageURL, "nickname": nickname, "height": height, "netWorth": netWorth, "prevScore": prevScore, "isFollowed": isFollowed] }
    public var userActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: CelebrityStruct.domainIdentifier)
        activity.title = nickname
        activity.userInfo = userActivityUserInfo
        activity.keywords = [nickname, "celebrity", "birthday", "score", "height", "net worth", "age", "zodiac"]
        activity.contentAttributeSet = attributeSet
        activity.eligibleForSearch = true
        activity.eligibleForPublicIndexing = true
        return activity
    }
    public var attributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContact as String)
        attributeSet.title = nickname
        attributeSet.contentDescription = "celscore: \(prevScore)"
        //attributeSet.thumbnailData = UIImageJPEGRepresentation(loadPicture(), 0.9)
        attributeSet.supportsPhoneCall = false
        attributeSet.keywords = [String(prevScore)]
        return attributeSet
    }
}


