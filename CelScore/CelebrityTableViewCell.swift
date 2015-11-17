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
    let profile: CelebrityProfile
    let nickName: ASTextNode

    
    //MARK: Initializers
    init(profile: CelebrityProfile) {
        self.profile = profile
        self.nickName = ASTextNode()
        
        super.init()
        
        self.nickName.attributedString = NSMutableAttributedString(string:"\(profile.nickname)")
        self.nickName.placeholderEnabled = true;
        self.addSubnode(self.nickName)
    }
    
    
    //MARK: Methods
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        return ASBackgroundLayoutSpec(
            child: ASInsetLayoutSpec(
                insets: UIEdgeInsetsMake(15, 15, 15, 15),
                child: self.nickName),
            background: nil)
    }
}
