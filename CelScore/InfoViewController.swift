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
    let celebST: CelebrityStruct
    let ratingsVM: RatingsViewModel
    let pulseView: MaterialPulseView
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct, frame: CGRect) {
        self.celebST = celebrityST
        self.ratingsVM = RatingsViewModel(celebrityId: celebrityST.id)
        self.pulseView = MaterialPulseView(frame: frame)
        super.init(node: ASDisplayNode())
        self.view.tag = Constants.kDetailViewTag
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let maxHeight = self.pulseView.height - 2 * Constants.kCellPadding
        let maxWidth = self.pulseView.width - 2 * Constants.kCellPadding
        
        CelebrityViewModel().getCelebritySignal(id: self.celebST.id)
            .on(next: { celeb in
                
                for (index, quality) in Info.getAll().enumerate() {
                    let qualityView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: CGFloat(index) * (maxHeight / 10) + Constants.kCellPadding, width: maxWidth, height: 30))
                    let qualityLabel = ShuffleTextLabel()
                    qualityLabel.text = quality
                    qualityLabel.frame = CGRect(x: Constants.kCellPadding, y: 3, width: 120, height: 25)
                    let infoLabel = ShuffleTextLabel()
                    infoLabel.text = "@GreyEcologist"
                    infoLabel.frame = CGRect(x: qualityLabel.width, y: 3, width: maxWidth - (qualityLabel.width + Constants.kCellPadding), height: 25)
                    infoLabel.textAlignment = .Right
                    qualityView.depth = .Depth1
                    qualityView.backgroundColor = MaterialColor.white
                    qualityView.addSubview(qualityLabel)
                    qualityView.addSubview(infoLabel)
                    self.pulseView.addSubview(qualityView)
                }
                
                let zodiac = (celeb.birthdate.dateFromFormat("MM/dd/yyyy")?.zodiacSign().name())!
                let birthdate = celeb.birthdate.dateFromFormat("MM/dd/yyyy")
                var age = 0
                if NSDate().month < birthdate!.month || (NSDate().month == birthdate!.month && NSDate().day < birthdate!.day )
                { age = NSDate().year - (birthdate!.year+1) } else { age = NSDate().year - birthdate!.year }
            })
            .start()
        
        self.pulseView.backgroundColor = MaterialColor.clear
        self.view = self.pulseView
    }
}
