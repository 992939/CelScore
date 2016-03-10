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
    static let kAPIKey: String = "0XwE760Ybs2iA9rYfl9ya898OeAJMYnd2T9jK5uP"
    
    static let kMaxFollowedCelebrities: Int = 10
    static let kNetworkRetry: Int = 2
    static let kFontSize: CGFloat = 16.0
    static let kScreenWidth: CGFloat = UIScreen.mainScreen().bounds.width
    static let kScreenHeight: CGFloat = UIScreen.mainScreen().bounds.height
    static let kMaxWidth: CGFloat = kScreenWidth - 2 * kPadding
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
    
    static func setupLabel(title title: String, frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = title
        label.textColor = MaterialColor.white
        label.font = UIFont(name: label.font.fontName, size: kFontSize)
        return label
    }
    
    static func setUpSocialButton(menuView: MenuView, controller: UIViewController, origin: CGPoint, buttonColor: UIColor) {
        let btn1: FabButton = FabButton()
        btn1.depth = .Depth2
        btn1.pulseScale = false
        btn1.backgroundColor = buttonColor
        btn1.tintColor = MaterialColor.white
        btn1.setImage(UIImage(named: "ic_add_black"), forState: .Disabled)
        btn1.setImage(UIImage(named: "ic_add_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        btn1.setImage(UIImage(named: "ic_add_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Highlighted)
        btn1.addTarget(controller, action: "handleMenu:", forControlEvents: .TouchUpInside)
        menuView.addSubview(btn1)
        
        var image = UIImage(named: "facebooklogo")
        let btn2: FabButton = FabButton()
        btn2.tag = 1
        btn2.clipsToBounds = true
        btn2.contentMode = .ScaleToFill
        btn2.depth = .Depth1
        btn2.pulseColor = MaterialColor.white
        btn2.backgroundColor = MaterialColor.indigo.darken1
        btn2.borderColor = MaterialColor.white
        btn2.borderWidth = 2
        btn2.setImage(image, forState: .Normal)
        btn2.setImage(image, forState: .Highlighted)
        btn2.addTarget(controller, action: "socialButton:", forControlEvents: .TouchUpInside)
        menuView.addSubview(btn2)
        
        image = UIImage(named: "twitterlogo")
        let btn3: FabButton = FabButton()
        btn3.tag = 2
        btn3.contentMode = .ScaleToFill
        btn3.clipsToBounds = true
        btn3.depth = .Depth1
        btn3.backgroundColor = MaterialColor.lightBlue.base
        btn3.pulseColor = MaterialColor.white
        btn3.borderColor = MaterialColor.white
        btn3.borderWidth = 2
        btn3.setImage(image, forState: .Normal)
        btn3.setImage(image, forState: .Highlighted)
        btn3.addTarget(controller, action: "socialButton:", forControlEvents: .TouchUpInside)
        menuView.addSubview(btn3)
        
        menuView.menu.origin = origin
        menuView.menu.baseViewSize = CGSize(width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        menuView.menu.direction = .Up
        menuView.menu.views = [btn1, btn2, btn3]
        menuView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //Star Wars
    typealias Distance = CGFloat
    typealias Region = CGPoint -> Bool
    
    static func drawStarsBackground(diameter diameter: CGFloat) -> UIView {
        var sky: Array<CGSize> = []
        let numberOfStars: Int = Int(arc4random_uniform(UInt32(15))) + 15
        for _ in 1...numberOfStars {
            let size = Int(arc4random_uniform(UInt32(3))) + 1
            let rect: CGSize?
            switch size {
            case 1: rect = CGSize(width: 10, height: 10)
            case 2: rect = CGSize(width: 30, height: 30)
            default: rect = CGSize(width: 60, height: 60)
            }
            sky.append(rect!)
        }
        let numberOfFrontStars: Int = Int(arc4random_uniform(UInt32(7))) + 3
        let numberOfSecondStars: Int = (numberOfStars - numberOfFrontStars) / 2
        print("front: \(numberOfFrontStars) second: \(numberOfSecondStars) total: \(numberOfStars) sky: \(sky)")
        return UIView()
    }
    
    static func circle(radius: Distance) -> Region {
        return { point in point.length <= radius }
    }
    
    static func shift(region: Region, offset: CGPoint) -> Region {
        return { point in region(point.minus(offset)) }
    }
    
    static func invert(region: Region) -> Region {
        return { point in !region(point) }
    }
   
    static func intersection(region1: Region, region2: Region) -> Region {
        return { point in region1(point) && region2(point) }
    }
    
    static func difference(region: Region, minus: Region) -> Region {
        return intersection(region, region2: invert(minus))
    }
    
//    static func union(region1: Region, region2: Region) -> Region -> Region {
//        return { point in region1(point) || region2(point) }
//    }
    
    //MasterVC
    static let kCelebrityTableViewRect: CGRect = CGRect(x: kPadding, y: 124, width: kScreenWidth - 2 * kPadding, height: kScreenHeight - 124)
    static let kSegmentedControlRect: CGRect = CGRect(x: 0, y: kNavigationBarRect.height, width: kScreenWidth, height: 48)
    
    //SettingsVC
    static let kSettingsViewWidth: CGFloat = 280 < 0.75 * UIScreen.mainScreen().bounds.width ? (0.75 * UIScreen.mainScreen().bounds.width) : 280
    static let kPickerViewHeight: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 160 : 100
    static let kPickerY: CGFloat = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 30 : 10
    
    //CelebrityTableViewCell
    static let kStarMargin: Double = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 1.2 : 0.7
    static let kStarSize: Double = 250 < 0.625 * UIScreen.mainScreen().bounds.width ? 16.0 : 14.0
    
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
        "They do not know it but they are doing it.",
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
        "Neutral men are the Devil's allies.",
        "If you can't reward, make sure to thank.",
        "Fire burns brighter in the darkness.",
        "Where the judgement is weak, prejudice is strong.",
        "The devil is in the details.",
        "The time is always right to do what is right. Right?",
        "One must walk in darkness so others may see the light.",
        "People lie numbers don't.",
        "Only fools lend light to the sun.",
        "Thank who gives you and give who thanks you.",
        "Outward judgment often fails, inward never.",
        "Wisdom does not come overnight.",
        "To get lost is to learn the way.",
        "He who learns, teaches.",
        "When you stare into the abyss, the abyss stares back.",
        "Sticks in a bundle are unbreakable.",
        "Many hands make light work.",
        "True knowledge is knowing you know nothing.",
        "Speak the truth, but leave immediately after.",
        "A little axe can cut down a big tree.",
        "The leopard does not change his spots.",
        "Relativity applies to physics, not ethics.",
        "The television will not be revolutionized.",
        "We rise by lifting others.",
        "We all boil at different degrees.",
        "Better little thant too little.",
        "If you're going through Hell, keep going.",
        "The map is not the territory.",
        "Power only steps back in the face of more power.",
        "The same shoe does not fit every foot.",
        "Wherever you go, there you are.",
        "We are all made of stars.",
        "E Pluribus Unum: Out of many, one.",
        "One for all, and all for one.",
        "The consensus is the eyes and ears of public opinion.",
        "The consensus is the echo chamber of public opinion.",
        "The whole is greater than the sum of its parts."]
}