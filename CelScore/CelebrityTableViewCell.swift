//
//  CelebrityTableViewCell.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 5/23/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit


final class CelebrityTableViewCell: ASCellNode {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let nameNode: ASTextNode
    let profilePicNode: ASImageNode //TODO: ASMultiplexImageNode/ASNetworkImageNode/ASLazyImageNode
    let ratingsNode: ASImageNode
    let followSwitch: UISwitch
    
    //MARK: Initializer
    init(celebrityStruct: CelebrityStruct) {
        self.celebST = celebrityStruct
        
        self.nameNode = ASTextNode()
        self.nameNode.attributedString = NSMutableAttributedString(string:"\(celebST.nickname)")
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.truncationMode = .ByTruncatingTail
        self.nameNode.placeholderEnabled = true;
        self.nameNode.layerBacked = true
        
        self.profilePicNode = ASImageNode()
        self.profilePicNode.frame = CGRectMake(10.0, 10.0, 40.0, 40.0)
        self.profilePicNode.layerBacked = true
//        self.profilePicNode.imageModificationBlock = {
//            input in return input
//        }
        
        self.ratingsNode = ASImageNode()
        self.ratingsNode.frame = CGRectMake(10.0, 10.0, 60.0, 40.0)
        self.ratingsNode.layerBacked = true
        
        self.followSwitch = UISwitch()
        
        super.init()
        
        self.backgroundColor = UIColor.whiteColor()
        self.addSubnode(self.profilePicNode)
        self.addSubnode(self.nameNode)
        self.addSubnode(self.ratingsNode)
        //self.view.addSubview(self.followSwitch)
    }
    
    //MARK: Methods
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let horizontalStack = ASStackLayoutSpec(
            direction: .Horizontal,
            spacing: Constants.cellPadding,
            justifyContent: .Start,
            alignItems: .Center,
            children: [self.profilePicNode, self.nameNode, self.ratingsNode])
        horizontalStack.flexBasis = ASRelativeDimension(type: .Percent, value: 1.0)
        
        self.profilePicNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.2)
        self.profilePicNode.backgroundColor = UIColor.greenColor()
        //self.profilePicNode.flexShrink = false
        
        self.nameNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.5)
        self.nameNode.backgroundColor = UIColor.redColor()
        //self.nameNode.flexShrink = false
        
        self.ratingsNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.3)
        self.ratingsNode.backgroundColor = UIColor.blueColor()
        //self.ratingsNode.flexShrink = false
        
        return ASBackgroundLayoutSpec(
            child: ASInsetLayoutSpec(
                insets: UIEdgeInsetsMake(Constants.cellPadding, Constants.cellPadding, Constants.cellPadding, Constants.cellPadding),
                child: horizontalStack),
            background: nil)
    }
    
    func getId() -> String { return celebST.id }
}
