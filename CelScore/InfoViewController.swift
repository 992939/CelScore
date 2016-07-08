//
//  InfoViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/1/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import UIKit
import Material
import ReactiveCocoa


final class InfoViewController: ASViewController, Labelable {
    
    //MARK: Properties
    private let celebST: CelebrityStruct
    private let pulseView: MaterialView
    internal var delegate: DetailSubViewable?
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.pulseView = MaterialView(frame: Constants.kBottomViewRect)
        super.init(node: ASDisplayNode())
        self.view.hidden = true
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        CelebrityViewModel().getCelebritySignal(id: self.celebST.id)
            .on(next: { celeb in
                
                let birthdate: NSDate = celeb.birthdate.dateFromFormat("MM/dd/yyyy")!
                let age: Int = (NSDate().month < birthdate.month || (NSDate().month == birthdate.month && NSDate().day < birthdate.day)) ? (NSDate().year - (birthdate.year+1)) : (NSDate().year - birthdate.year)
                let formatter = NSDateFormatter()
                formatter.dateStyle = .LongStyle
                
                RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id)
                    .startWithNext({ score in
                        for (index, quality) in Info.getAll().enumerate() {
                            let barHeight = UIDevice.getPulseBarHeight()
                            let qualityView: MaterialPulseView = MaterialPulseView(frame: CGRect(x: 0, y: CGFloat(index) * (Constants.kBottomHeight / 10) + Constants.kPadding, width: Constants.kMaxWidth, height: barHeight))
                            qualityView.tag = index+1
                            let qualityLabel: UILabel = self.setupLabel(title: quality, frame: CGRect(x: Constants.kPadding, y: 3, width: 120, height: barHeight - 5))
                            
                            var infoLabelText: String = ""
                            var attributedText: NSAttributedString = NSAttributedString()
                            switch quality {
                            case Info.FirstName.name(): infoLabelText = celeb.firstName
                            case Info.MiddleName.name(): infoLabelText = celeb.middleName
                            case Info.LastName.name(): infoLabelText = celeb.lastName
                            case Info.From.name(): infoLabelText = celeb.from
                            case Info.Birthdate.name(): infoLabelText = formatter.stringFromDate(birthdate) + String(" (\(age))")
                            case Info.Height.name(): infoLabelText = celeb.height
                            case Info.Zodiac.name(): infoLabelText = (celeb.birthdate.dateFromFormat("MM/dd/yyyy")?.zodiacSign().name())!
                            case Info.Status.name(): infoLabelText = celeb.status
                            case Info.CelScore.name(): attributedText = self.createCelScoreText(score)
                            case Info.Networth.name(): infoLabelText = celeb.netWorth
                            default: infoLabelText = ""
                            }
                            
                            let infoLabel: UILabel?
                            if case Info.CelScore.name() = quality {
                                infoLabel = UILabel(frame: CGRect(x: qualityLabel.width, y: 3, width: Constants.kMaxWidth - (qualityLabel.width + Constants.kPadding), height: barHeight - 5))
                                infoLabel!.attributedText = attributedText
                                infoLabel!.backgroundColor = Constants.kGreyBackground
                            } else {
                                infoLabel = self.setupLabel(title: infoLabelText, frame: CGRect(x: qualityLabel.width, y: 3, width: Constants.kMaxWidth - (qualityLabel.width + Constants.kPadding), height: barHeight - 5))
                            }
                            infoLabel!.textAlignment = .Right
                        
                            qualityView.depth = .Depth1
                            qualityView.backgroundColor = Constants.kGreyBackground
                            qualityView.addSubview(qualityLabel)
                            qualityView.addSubview(infoLabel!)
                            SettingsViewModel().getSettingSignal(settingType: .PublicService)
                                .observeOn(UIScheduler())
                                .startWithNext({ status in
                                if (status as! Bool) == true {
                                    qualityView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(InfoViewController.longPress(_:)))) }
                            })
                            self.pulseView.addSubview(qualityView)
                        }
                    })
            })
            .start()
        self.pulseView.backgroundColor = MaterialColor.clear
        self.view = self.pulseView
    }
    
    func createCelScoreText(score: Double) -> NSAttributedString {
        var attributedText = NSMutableAttributedString()
        let percent: Double = (score/self.celebST.prevScore) * 100 - 100
        let percentage: String = "(" + (percent < 0 ? String(percent.roundToPlaces(2)) : "+" + String(percent.roundToPlaces(2))) + "%)"
        let attr1 = [NSFontAttributeName: UIFont.systemFontOfSize(13.0), NSForegroundColorAttributeName : percent >= 0 ? Constants.kBlueText : Constants.kRedText]
        attributedText = NSMutableAttributedString(string: percentage, attributes: attr1)
        let attr2 = [NSFontAttributeName: UIFont.systemFontOfSize(Constants.kFontSize), NSForegroundColorAttributeName : percent >= 0 ? Constants.kBlueText : Constants.kRedText]
        let attrString = NSAttributedString(string: String(format: " %.2f", score), attributes: attr2)
        attributedText.appendAttributedString(attrString)
        return attributedText
    }
    
    func longPress(gesture: UIGestureRecognizer) {
        let celebIndex = gesture.view!.tag - 1
        let quality = Info(rawValue: celebIndex)!.text()
        
        CelebrityViewModel().getCelebritySignal(id: self.celebST.id)
            .startWithNext({ celeb in
                let birthdate: NSDate = celeb.birthdate.dateFromFormat("MM/dd/yyyy")!
                let age: Int = (NSDate().month < birthdate.month || (NSDate().month == birthdate.month && NSDate().day < birthdate.day)) ? (NSDate().year - (birthdate.year+1)) : (NSDate().year - birthdate.year)
                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.LongStyle
                
                let infoText: String
                switch quality {
                case Info.FirstName.text(): infoText = celeb.firstName
                case Info.MiddleName.text(): infoText = celeb.middleName
                case Info.LastName.text(): infoText = celeb.lastName
                case Info.From.text(): infoText = celeb.from
                case Info.Birthdate.text(): infoText = formatter.stringFromDate(birthdate) + String(" (\(age))")
                case Info.Height.text(): infoText = celeb.height
                case Info.Zodiac.text(): infoText = (celeb.birthdate.dateFromFormat("MM/dd/yyyy")?.zodiacSign().name())!
                case Info.Status.text(): infoText = celeb.status
                case Info.CelScore.text(): infoText = String(format: "%.2f", celeb.prevScore)
                case Info.Networth.text(): infoText = celeb.netWorth
                default: infoText = "n/a"
                }
                let who = self.celebST.nickname.characters.last == "s" ? "\(self.celebST.nickname)'" : "\(self.celebST.nickname)'s"
                self.delegate!.socialSharing(message: "\(who) \(quality) \(infoText)")
            })
    }
}
