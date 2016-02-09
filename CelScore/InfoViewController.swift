//
//  InfoViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/1/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material


final class InfoViewController: ASViewController {
    
    //MARK: Properties
    let ratingsVM: RatingsViewModel
    let pulseView: MaterialPulseView
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct, frame: CGRect) {
        self.ratingsVM = RatingsViewModel(celebrityId: celebrityST.id)
        self.pulseView = MaterialPulseView(frame: frame)
        super.init(node: ASDisplayNode())
        self.view.tag = Constants.kDetailViewTag
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let maxHeight = self.pulseView.frame.height - 2 * Constants.kCellPadding
        let maxWidth = self.pulseView.frame.width - 2 * Constants.kCellPadding
        
        for (index, quality) in Qualities.getAll().enumerate() {
            let qualityLabel = ShuffleTextLabel()
            qualityLabel.text = quality
            qualityLabel.frame = CGRect(x: Constants.kCellPadding, y: CGFloat(index) * (maxHeight / 10) + Constants.kCellPadding, width: maxWidth, height: 30)
            self.pulseView.addSubview(qualityLabel)
        }
        
        self.pulseView.backgroundColor = MaterialColor.white
        self.view = self.pulseView
    }
}




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