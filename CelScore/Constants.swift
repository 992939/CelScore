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
    
    //MARK: Properties
    static let cognitoIdentityPoolId = "us-east-1:d08ddeeb-719b-4459-9a8f-91cb108a216c"
    static let S3BucketName: String = "celeb3x"
    static let S3DownloadKeyName: String = "dmx@3x.jpg"
    
    static let kScreenWidth: CGFloat = UIScreen.mainScreen().bounds.width
    static let kScreenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    static let kSettingsViewWidth: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? (0.625 * UIScreen.mainScreen().bounds.width) : 250
    static let kPickerViewHeight: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 160 : 100
    static let kNavigationPadding: CGFloat = 80.0
    static let kCellPadding: CGFloat = 9.0
    static let kMinimumVoteValue: CGFloat = 1.0
    static let kMaximumVoteValue: CGFloat = 5.0
    static let kMiddleVoteValue: CGFloat = 3.0
    
    static let kBackgroundColor: UIColor = MaterialColor.grey.lighten3
    static let kMainGreenColor: UIColor = MaterialColor.green.lighten1
    static let kMainVioletColor: UIColor = MaterialColor.purple.lighten2
    
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
        "If you wish to be loved, love.",
        "Only fools throw ice cubes at the sun.",
        "Everything has beauty but not everyone sees it.",
        "Best to light a candle than curse the darkness.",
        "Expect a cow where there is grass.",
        "Every fool is pleased with his own folly.", // 0 to 14 - Negative
        "The revolution will not be televised.",
        "From caring comes courage.",
        "The greatest virtues are those useful to others.",
        "If you can't reward, make sure to thank.",
        "First duty of a citizen is to question authority.",
        "A life lived for others is a life worth living.",
        "Social change first requires ethical change.",
        "Where the judgement's weak, prejudice is strong.",
        "Great acts are made up of small deeds.",
        "The future belongs to those who shape it today.",
        "The time is always right to do what is right.",
        "Culture resides in the hearts of the people.",
        "Voting is breathing life into values.",
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
        "Individuality is freedom lived.",
        "We all boil at different degrees.",
        "The opposite of courage is conformity.",
        "It's weird not to be weird.",
        "The map is not the territory.",
        "Power only steps back facing more power.",
        "As above so below, as below so above.",
        "Knowledge is power."]
}