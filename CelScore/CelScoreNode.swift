//
//  CelScoreNode.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/26/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import LMGaugeView


final class CelScoreNode: ASCellNode {
    
    //MARK: Initializer
    init(celebrityST: CelebrityStruct) {
        
        super.init()
        
        RatingsViewModel(celebrityId: celebrityST.id).getCelScoreSignal()
            .on(next: { score in
                let gauge = LMGaugeView()
            })
            .start()
    }
    
    //MARK: Method
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsetsMake(Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding),
            child: ASStackLayoutSpec()),
            background: nil)
    }
}