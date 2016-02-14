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
    static let kLightShade: UIColor = MaterialColor.blueGrey.lighten3
    static let kWineShade: UIColor = MaterialColor.red.lighten1
    static let kBrightShade: UIColor = MaterialColor.cyan.base
    
    static let kNavigationBarRect: CGRect = CGRect(x: 0, y: 0, width: kScreenWidth, height: 70)
    
    //MasterVC
    static let kCelebrityTableViewRect: CGRect = CGRect(x: kPadding, y: 124, width: kScreenWidth - 2 * kPadding, height: kScreenHeight - 124)
    static let kSegmentedControlRect: CGRect = CGRect(x: 0, y: kNavigationBarRect.height, width: kScreenWidth, height: 48)
    
    //SettingsVC
    static let kSettingsViewWidth: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? (0.625 * UIScreen.mainScreen().bounds.width) : 250
    static let kPickerViewHeight: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 160 : 100
    static let kPickerY: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 30 : 10
    
    //CelebrityTableViewCell
    static let kStarMargin: Double = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 3.0 : 0.8
    static let kStarSize: Double = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 15.0 : 10.0
    
    //DetailVC
    static let kDetailWidth = kMaxWidth - 2 * kPadding
    static let kTopViewRect: CGRect = CGRect(x: 2 * kPadding, y: kNavigationBarRect.bottom + 10, width: kDetailWidth, height: 220)
    static let kSegmentViewRect: CGRect = CGRect(x: 2 * kPadding, y: kTopViewRect.bottom + 1, width: kDetailWidth, height: 40)
    static let kBottomViewRect = CGRect(x: 2 * kPadding, y: kSegmentViewRect.bottom, width: kDetailWidth, height: kScreenHeight - (kSegmentViewRect.bottom + kPadding))
    static let kBottomHeight = kBottomViewRect.height - 2 * kPadding
    
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
        "From caring comes courage.",
        "The greatest virtues are those useful to others.",
        "If you can't reward, make sure to thank.",
        "First duty of a citizen is to question authority.",
        "A life lived for others is a life worth living.",
        "Social change first requires ethical change.",
        "Where the judgement's weak, prejudice is strong.",
        "Great acts are made up of small deeds.",
        "Time is the only critic without ambition.",
        "The time is always right to do what is right.",
        "Culture resides in the hearts of the people.",
        "Voting is like breathing life into values.",
        "Only fools lend light to the sun.",
        "Thank who gives you and give who thanks you.",
        "Outward judgment often fails, inward never.",
        "I am what I am because of who we all are.",
        "Wisdom does not come overnight.",
        "To get lost is to learn the way.",
        "He who learns, teaches.",
        "It takes a village to raise a child.",
        "Sticks in a bundle are unbreakable.",
        "Many hands make light work.",
        "What you give you get, ten times over.",
        "As a man thinks in his heart, so is he.",
        "Riches add to the house, virtues to the man.",
        "Speak the truth, but leave immediately after.",
        "A little axe can cut down a big tree.",
        "The leopard does not change his spots.",
        "Be the change you wish to see in the world.",
        "Relativity applies to physics, not ethics.",
        "The television will not be revolutionized.",
        "We rise by lifting others.",
        "Even the lion protects himself against flies.",
        "We all boil at different degrees.",
        "Better little thant too little.",
        "It's weird not to be weird.",
        "The map is not the territory.",
        "Power steps back in the face of more power.",
        "As above so below, as below so above.",
        "The same shoe does not fit every foot.",
        "Hell is other people."]
}