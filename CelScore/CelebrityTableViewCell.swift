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
    let pictureNode: ASImageNode //TODO: ASMultiplexImageNode/ASNetworkImageNode
    let ratingsNode: ASImageNode
    let followSwitch: UISwitch
    
    //MARK: Initializer
    init(celebrityStruct: CelebrityStruct) {
        self.celebST = celebrityStruct
        self.nameNode = ASTextNode()
        self.pictureNode = ASImageNode()
        self.ratingsNode = ASImageNode()
        self.nameNode.layerBacked = true
        self.pictureNode.layerBacked = true
        self.ratingsNode.layerBacked = true
        self.followSwitch = UISwitch()
        
        super.init()
        
        self.backgroundColor = UIColor.whiteColor()
        self.nameNode.attributedString = NSMutableAttributedString(string:"\(celebST.nickname)")
        self.nameNode.placeholderEnabled = true;
        self.addSubnode(self.nameNode)
    }
    
    //MARK: Methods
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(
            child: ASInsetLayoutSpec(
                insets: UIEdgeInsetsMake(15, 15, 15, 15),
                child: self.nameNode),
            background: nil)
    }
    
    func getId() -> String { return celebST.id }
}
