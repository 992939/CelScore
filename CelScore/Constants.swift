//
//  Constants.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/23/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Material
import AWSCognito

struct Constants {
    
    //Universal
    static let kCognitoIdentityPoolId = "us-east-1:d08ddeeb-719b-4459-9a8f-91cb108a216c"
    static let kAPIKey: String = "0XwE760Ybs2iA9rYfl9ya898OeAJMYnd2T9jK5uP"
    static let kCredentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: kCognitoIdentityPoolId)
    
    static let kTrollingWarning: CGFloat = 2.0
    static let kTrollingThreshold: CGFloat = 1.5
    static let kDayInSeconds: NSTimeInterval = 86400.0
    static let kMaxFollowedCelebrities: Int = 10
    static let kNetworkRetry: Int = 2
    static let kFontSize: CGFloat = 16.0
    static let kScreenWidth: CGFloat = UIScreen.mainScreen().bounds.width
    static let kScreenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    static let kMaxWidth: CGFloat = kScreenWidth - kPadding
    static let kMaxHeight: CGFloat = kScreenHeight - 2 * kPadding
    static let kPadding: CGFloat = 10.0
    
    static let kDarkShade: UIColor = MaterialColor.blueGrey.darken4
    static let kMainShade: UIColor = MaterialColor.blueGrey.base
    static let kLightShade: UIColor = MaterialColor.grey.lighten3
    static let kLightGreenShade: UIColor = MaterialColor.teal.accent2
    static let kDarkGreenShade: UIColor = MaterialColor.teal.lighten1
    static let kWineShade: UIColor = MaterialColor.purple.lighten4
    static let kStarRatingShade: UIColor = MaterialColor.yellow.darken1
    
    static let kNavigationBarRect: CGRect = CGRect(x: 0, y: 0, width: kScreenWidth, height: 70)
    
    static func degreeToRadian(degree: CGFloat) -> CGFloat { return CGFloat(M_PI / 180) * degree }
    
    //MasterVC
    static let kCelebrityTableViewRect: CGRect = CGRect(x: kPadding/2, y: 124, width: kMaxWidth, height: kScreenHeight - 124)
    static let kSegmentedControlRect: CGRect = CGRect(x: 0, y: kNavigationBarRect.height, width: kScreenWidth, height: 48)
    
    //SettingsVC
    static let kSettingsViewWidth: CGFloat = 300 < 0.80 * UIScreen.mainScreen().bounds.width ? (0.75 * UIScreen.mainScreen().bounds.width) : 300
    static let kPickerViewHeight: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 160 : 100
    static let kPickerY: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 30 : 10
    
    //CelebrityTableViewCell
    static let kStarMargin: Double = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 1.2 : 0.7
    static let kStarSize: Double = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 16.0 : 14.0
    
    //DetailVC 
    static let kTopViewRect: CGRect = CGRect(x: kPadding/2, y: kNavigationBarRect.bottom, width: kMaxWidth, height: 220)
    static let kSegmentViewRect: CGRect = CGRect(x: kPadding/2, y: kTopViewRect.bottom + 1, width: kMaxWidth, height: 40)
    static let kBottomViewRect = CGRect(x: kPadding/2, y: kSegmentViewRect.bottom, width: kMaxWidth, height: kScreenHeight - kSegmentViewRect.bottom)
    static let kBottomHeight = kBottomViewRect.height - kPadding
    static let kFabDiameter: CGFloat = 50.0
    static let kCircleWidth: CGFloat = 200.0
    
    static let kMinimumVoteValue: CGFloat = 1.0
    static let kMaximumVoteValue: CGFloat = 5.0
    static let kMiddleVoteValue: CGFloat = 3.0
    static let kDetailViewTag: Int = 10
}