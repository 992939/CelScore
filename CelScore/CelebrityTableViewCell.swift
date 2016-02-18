//
//  CelebrityTableViewCell.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 5/23/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import WebASDKImageManager
import JTMaterialSwitch
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
    //let circleLayer = CAShapeLayer()
    
    //MARK: Initializer
    init(celebrityStruct: CelebrityStruct) {
        self.celebST = celebrityStruct
        
        self.nameNode = ASTextNode()
        let attr = [NSFontAttributeName: UIFont.systemFontOfSize(17.0), NSForegroundColorAttributeName : MaterialColor.white]
        self.nameNode.attributedString = NSMutableAttributedString(string: "\(celebST.nickname)", attributes: attr)
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.truncationMode = .ByTruncatingTail
    
        self.profilePicNode = ASNetworkImageNode(webImage: ())
        self.profilePicNode.URL = NSURL(string: celebST.imageURL)
        self.profilePicNode.contentMode = .ScaleAspectFit
        self.profilePicNode.preferredFrameSize = CGSize(width: 50, height: 50)
        self.profilePicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeRoundBorderModificationBlock(12.0, MaterialColor.white)(originalImage)
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
        let followSwitch = JTMaterialSwitch.init(size: JTMaterialSwitchSizeSmall, state: JTMaterialSwitchStateOff)
        followSwitch.center = CGPoint(x: Constants.kScreenWidth - 50, y: 32)
        followSwitch.thumbOnTintColor = Constants.kDarkShade
        followSwitch.trackOnTintColor = Constants.kLightShade
        followSwitch.rippleFillColor = Constants.kMainShade
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
    
    override func didLoad() {
        super.didLoad()
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        AIRTimer.every(10.0){ _ in self.animateProfile() }
    }
    
    func setupCircleLayer() {
        let lineWidth: CGFloat = 2.0
        let radius: CGFloat = self.profilePicNode.frame.width / 2
        let centerX: CGFloat = self.profilePicNode.frame.centerX - 10
        let centerY: CGFloat = self.profilePicNode.frame.centerY - 10
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: 0, endAngle:CGFloat(2 * M_PI), clockwise: true)

        let circleLayer = CAShapeLayer()
        self.profilePicNode.layer.addSublayer(circleLayer)
        circleLayer.path = circlePath.CGPath
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.lineWidth = lineWidth
        circleLayer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5).CGColor
        circleLayer.strokeStart = 0.0
        circleLayer.strokeEnd = 0.6
    }
    
    func animateProfile() {
        print("YO")
        self.setupCircleLayer()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 2.0
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.autoreverses = false
        animation.repeatCount = 0.0
        animation.removedOnCompletion = true
        
        animation.start = {
            print("Woo, the animation starts!")
        }
        
        animation.animating = { progress in
            print("progress: \(progress)")
        }
        
        animation.completion = { finished in
        }
        
        self.profilePicNode.layer.addAnimation(animation, forKey: "strokeEndAnimation")
    }
    
    func getId() -> String { return celebST.id }
    
    func degreeToRadian(degree: CGFloat) -> CGFloat { return CGFloat(M_PI / 180) * degree }
}
