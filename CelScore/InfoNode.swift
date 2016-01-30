//
//  InfoNode.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/26/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit


final class InfoNode: ASCellNode {
    
    //MARK: Properties
    let celebrityVM: CelebrityViewModel
    let ratingsVM: RatingsViewModel
    
    //MARK: Initializer
    init(celebrityST: CelebrityStruct) {
        self.celebrityVM = CelebrityViewModel(celebrityId: celebrityST.id)
        self.ratingsVM = RatingsViewModel(celebrityId: celebrityST.id)
        
        super.init()
        
        
//        self.celebrityVM.getCelebritySignal(id: self.celebST.id)
//            .on(next: { celeb in
//                
//                self.nickNameTextNode.attributedString = NSMutableAttributedString(string:"\(celeb.nickName)")
//                let zodiac = (celeb.birthdate.dateFromFormat("MM/dd/yyyy")?.zodiacSign().name())!
//                self.zodiacTextNode.attributedString = NSMutableAttributedString(string:"\(zodiac)")
//                let birthdate = celeb.birthdate.dateFromFormat("MM/dd/yyyy")
//                var age = 0
//                if NSDate().month < birthdate!.month || (NSDate().month == birthdate!.month && NSDate().day < birthdate!.day )
//                { age = NSDate().year - (birthdate!.year+1) } else { age = NSDate().year - birthdate!.year }
//                self.ageTextNode.attributedString = NSMutableAttributedString(string: "\(age)")
//            })
//            .start()
    }
    
    //MARK: Method
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsetsMake(Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding),
            child: ASStackLayoutSpec()),
            background: nil)
    }
}
