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
        self.nameNode.placeholderEnabled = true;
        self.nameNode.layerBacked = true
        
        self.profilePicNode = ASImageNode()
        self.profilePicNode.layerBacked = true
//        self.profilePicNode.imageModificationBlock = {
//            input in return input
//        }
        
        self.ratingsNode = ASImageNode()
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
        return ASBackgroundLayoutSpec(
            child: ASInsetLayoutSpec(
                insets: UIEdgeInsetsMake(Constants.cellPadding, Constants.cellPadding, Constants.cellPadding, Constants.cellPadding),
                child: self.nameNode),
            background: nil)
    }
    
    func getId() -> String { return celebST.id }
}
