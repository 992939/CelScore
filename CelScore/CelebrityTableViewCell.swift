//
//  CelebrityTableViewCell.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 5/23/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import WebASDKImageManager
import Material
import AIRTimer


final class CelebrityTableViewCell: ASCellNode {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let nameNode: ASTextNode
    let profilePicNode: ASNetworkImageNode
    let ratingsNode: ASDisplayNode
    let switchNode: ASDisplayNode
    let backgroundNode: ASDisplayNode
    let circleLayer = CAShapeLayer()
    
    //MARK: Initializer
    init(celebrityStruct: CelebrityStruct) {
        self.celebST = celebrityStruct
        
        self.nameNode = ASTextNode()
        let attr = [NSFontAttributeName: UIFont.systemFontOfSize(20.0), NSForegroundColorAttributeName : MaterialColor.white]
        self.nameNode.attributedString = NSMutableAttributedString(string: "\(celebST.nickname)", attributes: attr)
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.truncationMode = .ByTruncatingTail
    
        self.profilePicNode = ASNetworkImageNode(webImage: ())
        self.profilePicNode.URL = NSURL(string: celebST.imageURL)
        self.profilePicNode.contentMode = .ScaleAspectFit
        self.profilePicNode.preferredFrameSize = CGSize(width: 50, height: 50)
        self.profilePicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeRoundBorderModificationBlock(12.0, Constants.kWineShade)(originalImage)
        }
        
        let cosmosView = CosmosView()
        cosmosView.settings.starSize = Constants.kStarSize
        cosmosView.settings.starMargin = Constants.kStarMargin
        cosmosView.settings.updateOnTouch = false
        self.ratingsNode = ASDisplayNode(viewBlock: { () -> UIView in return cosmosView })
        self.ratingsNode.preferredFrameSize = CGSize(width: 10, height: 20)
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id)
            .on(next: { (hasRatings:Bool) in
                cosmosView.settings.colorFilled = hasRatings ? Constants.kStarRatingShade : MaterialColor.white
                cosmosView.settings.borderColorEmpty = hasRatings ? Constants.kStarRatingShade : MaterialColor.white
            })
            .start()
        let followSwitch = MaterialSwitch(size: .Small, state: .Off)
        followSwitch.center = CGPoint(x: Constants.kScreenWidth - 50, y: 32)
        followSwitch.buttonOnColor = Constants.kWineShade
        followSwitch.trackOnColor = followSwitch.trackOffColor
        self.switchNode = ASDisplayNode(viewBlock: { () -> UIView in return followSwitch })
        self.switchNode.preferredFrameSize = CGSize(width: 20, height: 20)
        
        let cardView: MaterialView = MaterialView()
        cardView.borderWidth = 2.0
        cardView.borderColor = Constants.kDarkShade
        self.backgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return cardView })
        self.backgroundNode.backgroundColor = Constants.kMainShade
        
        super.init()
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.profilePicNode)
        self.addSubnode(self.nameNode)
        self.addSubnode(self.ratingsNode)
        self.addSubnode(self.switchNode)
    }
    
    //MARK: Methods
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.profilePicNode.flexBasis = ASRelativeDimension(type: .Points, value: 50)
        self.nameNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.42)
        self.ratingsNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.2)
        self.switchNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.12)
        
        let horizontalStack = ASStackLayoutSpec(
            direction: .Horizontal,
            spacing: Constants.kPadding,
            justifyContent: .Start,
            alignItems: .Center,
            children: [self.profilePicNode, self.nameNode, self.ratingsNode])
        horizontalStack.flexBasis = ASRelativeDimension(type: .Percent, value: 0.9)
        
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsetsMake(Constants.kPadding, Constants.kPadding, Constants.kPadding, Constants.kPadding),
            child: horizontalStack),
            background: self.backgroundNode)
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        //self.setupCircleLayer()
        AIRTimer.every(Constants.kAnimationInterval){ _ in self.setupCircleLayer()
            //self.animateProfile() 
        }
    }
    
    func animateProfile() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = Constants.kAnimationInterval
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.animating = { progress in
            self.circleLayer.strokeStart = self.floorToPlaces(progress, places: 2)
            self.circleLayer.strokeEnd = self.floorToPlaces(progress + 0.0002, places: 2)
        }
        //animation.completion = { finished in self.profilePicNode }
        circleLayer.addAnimation(animation, forKey: "strokeEndAnimation")
    }
    
    func setupCircleLayer() {
        let radius: CGFloat = (self.profilePicNode.frame.width - 2) / 2
        let centerX: CGFloat = self.profilePicNode.frame.centerX - 10
        let centerY: CGFloat = self.profilePicNode.frame.centerY - 10
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: degreeToRadian(-90.0), endAngle: degreeToRadian(-90 + 360.0), clockwise: true)
        
        let rectShape1 = CAShapeLayer()
        rectShape1.bounds = CGRect(x: 0, y: 0, width: 8, height: 8)
        rectShape1.path = UIBezierPath(roundedRect: rectShape1.bounds, cornerRadius: 4).CGPath
        rectShape1.fillColor = UIColor.greenColor().CGColor
        
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position"
        animation.path = circlePath.CGPath
        animation.additive = true
        animation.duration = 10
        
        rectShape1.addAnimation(animation, forKey: "strokeEndAnimation")
        
//        circleLayer.lineWidth =  4.0
//        circleLayer.lineCap = "round"
//        circleLayer.path = circlePath.CGPath
//        circleLayer.fillColor = UIColor.clearColor().CGColor
//        circleLayer.strokeColor = Constants.kWineShade.CGColor
        self.profilePicNode.layer.addSublayer(rectShape1)
    }
    
    func ceilToPlaces(value:CGFloat, places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return ceil(value * divisor) / divisor
    }
    
    func floorToPlaces(value:CGFloat, places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return round(value * divisor) / divisor
    }
    
    func degreeToRadian(degree: CGFloat) -> CGFloat { return CGFloat(M_PI / 180) * degree }
    func getId() -> String { return celebST.id }
}
