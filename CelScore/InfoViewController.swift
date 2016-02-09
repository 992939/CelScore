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
    let pulseView: MaterialPulseView
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct, frame: CGRect) {
        self.celebST = celebrityST
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
                
                let birthdate = celeb.birthdate.dateFromFormat("MM/dd/yyyy")
                var age = 0
                if NSDate().month < birthdate!.month || (NSDate().month == birthdate!.month && NSDate().day < birthdate!.day )
                { age = NSDate().year - (birthdate!.year+1) } else { age = NSDate().year - birthdate!.year }
                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.LongStyle
                
                for (index, quality) in Info.getAll().enumerate() {
                    let qualityView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: CGFloat(index) * (maxHeight / 10) + Constants.kCellPadding, width: maxWidth, height: 30))
                    let qualityLabel = UILabel()
                    qualityLabel.text = quality
                    qualityLabel.frame = CGRect(x: Constants.kCellPadding, y: 3, width: 120, height: 25)
                    let infoLabel = ShuffleTextLabel()
                    
                    switch quality {
                    case Info.FirstName.name(): infoLabel.text = celeb.firstName
                    case Info.MiddleName.name(): infoLabel.text = celeb.middleName
                    case Info.LastName.name(): infoLabel.text = celeb.lastName
                    case Info.From.name(): infoLabel.text = celeb.from
                    case Info.Birthdate.name(): infoLabel.text = formatter.stringFromDate(birthdate!) + String(" (\(age))")
                    case Info.Height.name(): infoLabel.text = celeb.height
                    case Info.Zodiac.name(): infoLabel.text = (celeb.birthdate.dateFromFormat("MM/dd/yyyy")?.zodiacSign().name())!
                    case Info.Status.name(): infoLabel.text = celeb.status
                    case Info.CelScore.name(): infoLabel.text = String(format: "%.2f", celeb.prevScore)
                    case Info.Networth.name(): infoLabel.text = celeb.netWorth
                    default: infoLabel.text = "n/a"
                    }
                    
                    infoLabel.frame = CGRect(x: qualityLabel.width, y: 3, width: maxWidth - (qualityLabel.width + Constants.kCellPadding), height: 25)
                    infoLabel.textAlignment = .Right
                    qualityView.depth = .Depth1
                    qualityView.backgroundColor = MaterialColor.white
                    qualityView.addSubview(qualityLabel)
                    qualityView.addSubview(infoLabel)
                    self.pulseView.addSubview(qualityView)
                }
            })
            .start()
        
        self.pulseView.backgroundColor = MaterialColor.clear
        self.view = self.pulseView
    }
}
