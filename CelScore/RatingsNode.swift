//
//  RatingsNode.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/26/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit


final class RatingsNode: ASCellNode {
    
    //MARK: Initializer
    init(celebrityST: CelebrityStruct) {
        super.init()
    }
    
    //MARK: Method
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsetsMake(Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding),
            child: ASStackLayoutSpec()),
            background: nil)
    }
}
