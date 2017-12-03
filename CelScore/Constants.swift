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
    static let kPolicyURL: String = "https://www.iubenda.com/privacy-policy/7872365"
    static let kNoLogin: String = "Log in with Twitter or Facebook."
    static let kAlertAction: String = "Done"
    static let kAlertName: String = "The Blue Castle"
    
    static let kRoyalty: Double = 75.0
    static let kCornerRadius: CGFloat = 11.0
    static let kTrollingWarning: CGFloat = 1.9
    static let kTrollingThreshold: CGFloat = 30.0
    static let kOneDay: TimeInterval = 86400.0
    static let kOneMinute: TimeInterval = 60.0
    static let kMaxFollowedCelebrities: Int = 10
    static let kTimeout: TimeInterval = 10.0
    static let kNetworkRetry: Int = 7
    static let kFontSize: CGFloat = UIDevice.getFontSize()
    static let kScreenWidth: CGFloat = UIScreen.main.bounds.width
    static let kScreenHeight: CGFloat = UIScreen.main.bounds.height
    static let kMaxWidth: CGFloat = kScreenWidth -  2 * kPadding
    static let kMaxHeight: CGFloat = kScreenHeight - 2 * kPadding
    static let kPadding: CGFloat = 10.0
    static let kIsOriginalIphone: Bool = kScreenWidth > 320 ? false : true
    static let kPositiveConsensus: Double = 70.0
    
    static let kIPhone5_height: CGFloat = 568
    static let kIPhone6_height: CGFloat = 667
    static let kIPhone6Plus_height: CGFloat = 736
    static let kIPhoneX: CGFloat = 812
    
    static let kBlueShade: UIColor = Color.blue.lighten2
    static let kBlueText: UIColor = Color.blue.darken1
    static let kBlueLight: UIColor = Color.blue.base
    static let kRedShade: UIColor = Color.red.lighten2
    static let kRedText: UIColor = Color.red.darken1
    static let kRedLight: UIColor = Color.red.base
    static let kStarGoldShade: UIColor = Color.yellow.darken1
    static let kStarGreyShade: UIColor = Color.grey.lighten1
    static let kGreyBackground: UIColor = Color.grey.lighten3
    
    static let kStatusViewRect: CGRect = CGRect(x: 0, y: 0, width: kScreenWidth, height: 20)
    
    //MasterVC
    static let kTopHeight: CGFloat = kIsOriginalIphone ? 47 : 50
    static let kNavigationBarRect: CGRect = CGRect(x: 0, y: kStatusViewRect.height, width: kScreenWidth, height: kTopHeight)
    static let kSegmentedControlRect: CGRect = CGRect(x: 0, y: kNavigationBarRect.bottom, width: kScreenWidth, height: kTopHeight + 3)
    static let kcelebrityTableNodeRect: CGRect = CGRect(x: kPadding, y: kSegmentedControlRect.bottom + kPadding, width: kMaxWidth, height: kScreenHeight - (kSegmentedControlRect.bottom + 2 * kPadding))
    static let kSearchListId: String = "0099"
    
    //SettingsVC
    static let kLogoHeight: CGFloat = kIsOriginalIphone ? 90 : 110
    static let kSettingsViewWidth: CGFloat = kIsOriginalIphone ? 280 : 320
    static let kPickerY: CGFloat = kIsOriginalIphone ? -5 : 30
    
    //DetailVC 
    static let kHeightPadding: CGFloat = kIsOriginalIphone ? 0 : 20
    static let kDetailNavigationBarRect: CGRect = CGRect(x: 0, y: kStatusViewRect.height, width: kScreenWidth, height: kTopHeight)
    static let kTopViewRect: CGRect = CGRect(x: kPadding, y: kDetailNavigationBarRect.bottom + 5, width: kMaxWidth, height: UIDevice.getProfileDiameter() + kHeightPadding)
    static let kSegmentViewRect: CGRect = CGRect(x: kPadding, y: kTopViewRect.bottom + 5, width: kMaxWidth, height: 35)
    static let kBottomViewRect = CGRect(x: kPadding, y: kSegmentViewRect.bottom - 5, width: kMaxWidth, height: kScreenHeight - kSegmentViewRect.bottom)
    static let kBottomHeight = kBottomViewRect.height - kPadding
    static let kFabDiameter: CGFloat = 50.0
    static let kCircleWidth: CGFloat = UIDevice.getGaugeDiameter()
    
    static let kMinimumVoteValue: CGFloat = 20.0
    static let kMaximumVoteValue: CGFloat = 100.0
    static let kMiddleVoteValue: CGFloat = 80.0
    
    //CelebrityTableVC
    static let kMiniCircleDiameter: CGFloat = 18
}
