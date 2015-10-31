//
//  CelebrityTableViewCell.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 5/23/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import AsyncDisplayKit

final class CelebrityTableViewCell: ASCellNode {
    
    let profile: CelebrityProfile
    let nickName: ASTextNode!
    
    init(profile: CelebrityProfile) {
        self.profile = profile
        self.nickName = ASTextNode()
        
        super.init()
        
        self.nickName.attributedString = NSMutableAttributedString(string:"\(profile.nickname)")
        self.nickName.truncationAttributedString = NSMutableAttributedString(string:"H")
        self.addSubnode(nickName)
    }

}
