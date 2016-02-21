//
//  Constants.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/23/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import Material


struct Constants {
    
    //Universal
    static let cognitoIdentityPoolId = "us-east-1:d08ddeeb-719b-4459-9a8f-91cb108a216c"
    static let S3BucketName: String = "celeb3x"
    static let S3DownloadKeyName: String = "dmx@3x.jpg"
    
    static let kScreenWidth: CGFloat = UIScreen.mainScreen().bounds.width
    static let kScreenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    static let kMaxWidth: CGFloat = kScreenWidth - 2 * kPadding
    static let kMaxHeight: CGFloat = kScreenHeight - 2 * kPadding
    static let kPadding: CGFloat = 10.0
    
    static let kBackgroundColor: UIColor = MaterialColor.grey.lighten3
    static let kDarkShade: UIColor = MaterialColor.blueGrey.darken4
    static let kMainShade: UIColor = MaterialColor.blueGrey.base
    static let kLightShade: UIColor = MaterialColor.grey.lighten3
    static let kWineShade: UIColor = MaterialColor.purple.lighten4 //MaterialColor.red.accent2
    static let kBrightShade: UIColor = MaterialColor.lightBlue.lighten3 //MaterialColor.cyan.accent2
    static let kYellowShade: UIColor = MaterialColor.yellow.accent3
    static let kStarRatingShade: UIColor = MaterialColor.yellow.accent3
    
    static let kNavigationBarRect: CGRect = CGRect(x: 0, y: 0, width: kScreenWidth, height: 70)
    
    //MasterVC
    static let kCelebrityTableViewRect: CGRect = CGRect(x: kPadding, y: 124, width: kScreenWidth - 2 * kPadding, height: kScreenHeight - 124)
    static let kSegmentedControlRect: CGRect = CGRect(x: 0, y: kNavigationBarRect.height, width: kScreenWidth, height: 48)
    
    //SettingsVC
    static let kSettingsViewWidth: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? (0.625 * UIScreen.mainScreen().bounds.width) : 250
    static let kPickerViewHeight: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 160 : 100
    static let kPickerY: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 30 : 10
    
    //CelebrityTableViewCell
    static let kStarMargin: Double = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 1.2 : 0.7
    static let kStarSize: Double = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 16.0 : 14.0
    static let kAnimationInterval: NSTimeInterval = 10.0
    
    //DetailVC
    static let kDetailWidth = kMaxWidth - 2 * kPadding
    static let kTopViewRect: CGRect = CGRect(x: 2 * kPadding, y: kNavigationBarRect.bottom + 10, width: kDetailWidth, height: 220)
    static let kSegmentViewRect: CGRect = CGRect(x: 2 * kPadding, y: kTopViewRect.bottom + 1, width: kDetailWidth, height: 40)
    static let kBottomViewRect = CGRect(x: 2 * kPadding, y: kSegmentViewRect.bottom, width: kDetailWidth, height: kScreenHeight - (kSegmentViewRect.bottom + kPadding))
    static let kBottomHeight = kBottomViewRect.height - 2 * kPadding
    static let kFabDiameter: CGFloat = 43.0
    
    static let kMinimumVoteValue: CGFloat = 1.0
    static let kMaximumVoteValue: CGFloat = 5.0
    static let kMiddleVoteValue: CGFloat = 3.0
    static let kDetailViewTag: Int = 10
    
    static let fortuneCookies: [String] = [
        "Only dead fish go with the flow.",
        "It's all in a state of mind.",
        "Life is a tale told by an idiot.",
        "In a closed mouth, flies do not enter.",
        "To err is human. To forgive, unlikely.",
        "To err is human. To forgive, divine.",
        "The well bred horse ignores the barking dog.",
        "What harms, often teaches.",
        "As above so below, as within so without.",
        "Two wrongs don't make a right.",
        "Only fools throw ice cubes at the sun.",
        "Everything has beauty but not everyone sees it.",
        "Best to light a candle than curse the darkness.",
        "Expect a cow where there is grass.",
        "Slander by the stream will be heard by the frogs.", // 0 to 14 - Negative
        "The revolution will not be televised.",
        "What do we want? Justice. When do we want it? Now.",
        "In Heaven, all the interesting people are missing.",
        "Neutral men are the Devil's allies.",
        "If you can't reward, make sure to thank.",
        "Everything we see is a perspective, not a fact.",
        "Everything we hear is an opinion, not a fact.",
        "Fire burns brighter in the darkness.",
        "Where the judgement is weak, prejudice is strong.",
        "Hell hath no fury like a mind unshackled.",
        "The devil is in the details.",
        "The time is always right to do what is right. Right?",
        "One must walk in darkness so others may see the light.",
        "You're looking for justice, what you'll find is just us.",
        "Only fools lend light to the sun.",
        "Thank who gives you and give who thanks you.",
        "Outward judgment often fails, inward never.",
        "There are no facts, only interpretations.",
        "Wisdom does not come overnight.",
        "To get lost is to learn the way.",
        "He who learns, teaches.",
        "When you stare into the abyss, the abyss stares back.",
        "Sticks in a bundle are unbreakable.",
        "Many hands make light work.",
        "Hell is empty, all the devils are here.",
        "There is no smoke without fire.",
        "True knowledge is knowing that you know nothing.",
        "Speak the truth, but leave immediately after.",
        "A little axe can cut down a big tree.",
        "The leopard does not change his spots.",
        "Relativity applies to physics, not ethics.",
        "The television will not be revolutionized.",
        "We rise by lifting others.",
        "Even the lion protects himself against flies.",
        "We all boil at different degrees.",
        "Better little thant too little.",
        "If you're going through Hell, keep going.",
        "The map is not the territory.",
        "Power steps back in the face of more power.",
        "As above so below, as below so above.",
        "The same shoe does not fit every foot.",
        "Wherever you go, there you are.",
        "Hell is other people."]
}