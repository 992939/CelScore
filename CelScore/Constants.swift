//
//  Constants.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/23/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import Material
import AWSCognito

struct Constants {
    
    //Universal
    static let kCognitoIdentityPoolId = "us-east-1:d08ddeeb-719b-4459-9a8f-91cb108a216c"
    static let kAPIKey: String = "0XwE760Ybs2iA9rYfl9ya898OeAJMYnd2T9jK5uP"
    static let kCredentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: kCognitoIdentityPoolId)
    
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
    
    //functions
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
    
    static func drawStarsBackground(frame frame: CGRect) -> UIView {
        let skyLayer = UIView(frame: frame)
        skyLayer.clipsToBounds = true
        let numberOfStars: Int = Int(arc4random_uniform(UInt32(20))) + 60
        for _ in 1...numberOfStars {
            let size = Int(arc4random_uniform(UInt32(3))) + 1
            let rect: CGSize?
            switch size {
            case 1: rect = CGSize(width: 5, height: 5)
            case 2: rect = CGSize(width: 10, height: 10)
            default: rect = CGSize(width: 20, height: 20)
            }
            let circleLayer = CAShapeLayer()
            let radius: CGFloat = rect!.width
            circleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius), cornerRadius: radius).CGPath
            circleLayer.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(frame.width))), y: CGFloat(arc4random_uniform(UInt32(frame.height))))
            circleLayer.fillColor = Int(arc4random_uniform(UInt32(2))) == 1 ? kLightGreenShade.CGColor : kWineShade.CGColor
            circleLayer.opacity = (Float(arc4random_uniform(UInt32(3))) + 2) / 10
            skyLayer.layer.addSublayer(circleLayer)
        }
        return skyLayer
    }
    
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
    static let kTopViewRect: CGRect = CGRect(x: 2 * kPadding, y: kNavigationBarRect.bottom, width: kDetailWidth, height: 220)
    static let kSegmentViewRect: CGRect = CGRect(x: 2 * kPadding, y: kTopViewRect.bottom + 1, width: kDetailWidth, height: 40)
    static let kBottomViewRect = CGRect(x: 2 * kPadding, y: kSegmentViewRect.bottom, width: kDetailWidth, height: kScreenHeight - (kSegmentViewRect.bottom + kPadding))
    static let kBottomHeight = kBottomViewRect.height - 2 * kPadding
    static let kFabDiameter: CGFloat = 43.0
    
    static let kMinimumVoteValue: CGFloat = 1.0
    static let kMaximumVoteValue: CGFloat = 5.0
    static let kMiddleVoteValue: CGFloat = 3.0
    static let kDetailViewTag: Int = 10
}