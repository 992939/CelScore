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


final class CelebrityTableViewCell: ASCellNode {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let nameNode: ASTextNode
    let profilePicNode: ASNetworkImageNode
    let ratingsNode: ASDisplayNode
    let switchNode: ASDisplayNode
    let backgroundNode: ASDisplayNode
    
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
        cosmosView.settings.colorFilled = MaterialColor.yellow.darken1
        cosmosView.settings.borderColorEmpty = MaterialColor.yellow.darken1
        self.ratingsNode = ASDisplayNode(viewBlock: { () -> UIView in return cosmosView })
        self.ratingsNode.preferredFrameSize = CGSize(width: 10, height: 20)
        
        let followSwitch = JTMaterialSwitch.init(size: JTMaterialSwitchSizeSmall, state: JTMaterialSwitchStateOff)
        followSwitch.center = CGPoint(x: Constants.kScreenWidth - 45, y: 20)
        followSwitch.thumbOnTintColor = Constants.kDarkShade
        followSwitch.trackOnTintColor = Constants.kLightShade
        followSwitch.rippleFillColor = Constants.kMainShade
        self.switchNode = ASDisplayNode(viewBlock: { () -> UIView in return followSwitch })
        self.switchNode.preferredFrameSize = CGSize(width: 20, height: 20)
        
        let cardView: MaterialView = MaterialView()
        cardView.borderWidth = .Border2
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
    
    func getId() -> String { return celebST.id }
}
