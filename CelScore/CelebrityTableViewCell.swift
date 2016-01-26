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


final class CelebrityTableViewCell: ASCellNode {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let nameNode: ASTextNode
    let profilePicNode: ASNetworkImageNode
    let ratingsNode: ASDisplayNode
    let switchNode: ASDisplayNode
    
    //MARK: Initializer
    init(celebrityStruct: CelebrityStruct) {
        self.celebST = celebrityStruct
        
        self.nameNode = ASTextNode()
        self.nameNode.attributedString = NSMutableAttributedString(string:"\(celebST.nickname)")
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.truncationMode = .ByTruncatingTail
        
        self.profilePicNode = ASNetworkImageNode(webImage: ())
        self.profilePicNode.URL = NSURL(string: celebST.imageURL)
        self.profilePicNode.contentMode = UIViewContentMode.ScaleAspectFit
        self.profilePicNode.preferredFrameSize = CGSizeMake(50, 50)
        self.profilePicNode.imageModificationBlock = { (originalImage: UIImage) -> UIImage? in
            return ASImageNodeRoundBorderModificationBlock(9.0, UIColor.redColor())(originalImage)
        }
        
        let cosmosView = CosmosView()
        cosmosView.settings.starSize = 15
        cosmosView.settings.starMargin = 3
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.colorFilled = UIColor.orangeColor()
        cosmosView.settings.borderColorEmpty = UIColor.orangeColor()
        self.ratingsNode = ASDisplayNode.init(viewBlock: { () -> UIView in return cosmosView })
        self.ratingsNode.preferredFrameSize = CGSizeMake(10, 20)
        
        let followSwitch = JTMaterialSwitch.init(size: JTMaterialSwitchSizeSmall, state: JTMaterialSwitchStateOff)
        followSwitch.center = CGPointMake(360, 20)
        self.switchNode = ASDisplayNode.init(viewBlock: { () -> UIView in return followSwitch })
        self.switchNode.preferredFrameSize = CGSizeMake(20, 20)
        
        super.init()
        
        self.addSubnode(self.profilePicNode)
        self.addSubnode(self.nameNode)
        self.addSubnode(self.ratingsNode)
        self.addSubnode(self.switchNode)
    }
    
    //MARK: Methods
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.profilePicNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.12)
        self.nameNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.48)
        self.ratingsNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.2)
        self.switchNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.2)
        
        //self.profilePicNode.backgroundColor = UIColor.greenColor()
        //self.nameNode.backgroundColor = UIColor.redColor()
        //self.ratingsNode.backgroundColor = UIColor.blueColor()
        //self.switchNode.backgroundColor = UIColor.yellowColor()
        
        let horizontalStack = ASStackLayoutSpec(
            direction: .Horizontal,
            spacing: Constants.kCellPadding,
            justifyContent: .Start,
            alignItems: .Center,
            children: [self.profilePicNode, self.nameNode, self.ratingsNode])
        horizontalStack.flexBasis = ASRelativeDimension(type: .Percent, value: 0.9)
        
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsetsMake(Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding),
            child: horizontalStack),
            background: nil)
    }
    
    func getId() -> String { return celebST.id }
}
