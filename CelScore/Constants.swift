//
//  Constants.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/23/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Material
import AWSCognito
import Keys


struct Constants {
    
    //Universal
    static let kCognitoIdentityPoolId: String = CelscoreKeys().kCognitoIdentityPoolId()
    static let kAPIKey: String = CelscoreKeys().kAPIKey()
    static let kCredentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: kCognitoIdentityPoolId)
    
    static let kTrollingWarning: CGFloat = 1.9
    static let kTrollingThreshold: CGFloat = 1.5
    static let kOneDay: NSTimeInterval = 86400.0
    static let kUpdateRatings: NSTimeInterval = 30.0
    static let kMaxFollowedCelebrities: Int = 10
    static let kTimeout: NSTimeInterval = 5.0
    static let kNetworkRetry: Int = 2
    static let kFontSize: CGFloat = UIDevice.getFontSize()
    static let kScreenWidth: CGFloat = UIScreen.mainScreen().bounds.width
    static let kScreenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    static let kMaxWidth: CGFloat = kScreenWidth - kPadding
    static let kMaxHeight: CGFloat = kScreenHeight - 2 * kPadding
    static let kPadding: CGFloat = 10.0
    static let kIsOriginalIphone: Bool = kScreenWidth > 320 ? false : true
    
    static let kIPhone4_height: CGFloat = 480
    static let kIPhone5_height: CGFloat = 568
    static let kIPhone6_height: CGFloat = 667
    static let kIPhone6Plus_height: CGFloat = 736
    
    static let kDarkShade: UIColor = MaterialColor.blueGrey.darken4
    static let kMainShade: UIColor = MaterialColor.blueGrey.base
    static let kLightShade: UIColor = MaterialColor.grey.lighten3
    static let kLightGreenShade: UIColor = MaterialColor.teal.accent2
    static let kDarkGreenShade: UIColor = MaterialColor.teal.lighten1
    static let kWineShade: UIColor = MaterialColor.purple.lighten4
    static let kStarRatingShade: UIColor = MaterialColor.yellow.darken1
    
    static let kStatusViewRect: CGRect = CGRect(x: 0, y: 0, width: kScreenWidth, height: 20)
    
    //MasterVC
    static let kNavigationBarRect: CGRect = CGRect(x: 0, y: kStatusViewRect.height, width: kScreenWidth, height: 65)
    static let kCelebrityTableViewRect: CGRect = CGRect(x: kPadding/2, y: 124, width: kMaxWidth, height: kScreenHeight - 124)
    static let kSegmentedControlRect: CGRect = CGRect(x: 0, y: kNavigationBarRect.height, width: kScreenWidth, height: 48)
    static let kSearchListId: String = "0099"
    
    //SettingsVC
    static let kSettingsViewWidth: CGFloat = kIsOriginalIphone ? 280 : (0.80 * kScreenWidth)
    static let kPickerY: CGFloat = kIsOriginalIphone ? -5 : 30
    
    //DetailVC 
    static let kDetailNavigationBarRect: CGRect = CGRect(x: 0, y: kStatusViewRect.height, width: kScreenWidth, height: 45)
    static let kTopViewRect: CGRect = CGRect(x: kPadding/2, y: kDetailNavigationBarRect.bottom + 5, width: kMaxWidth, height: UIDevice.getProfileDiameter() + UIDevice.getProfilePadding())
    static let kSegmentViewRect: CGRect = CGRect(x: kPadding/2, y: kTopViewRect.bottom + 5, width: kMaxWidth, height: UIDevice.getSegmentHeight())
    static let kBottomViewRect = CGRect(x: kPadding/2, y: kSegmentViewRect.bottom - 5, width: kMaxWidth, height: kScreenHeight - kSegmentViewRect.bottom)
    static let kBottomHeight = kBottomViewRect.height - kPadding/2
    static let kFabDiameter: CGFloat = 50.0
    static let kCircleWidth: CGFloat = UIDevice.getGaugeDiameter()
    
    static let kMinimumVoteValue: CGFloat = 1.0
    static let kMaximumVoteValue: CGFloat = 5.0
    static let kMiddleVoteValue: CGFloat = 3.0
}