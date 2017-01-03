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
import ReactiveSwift
import Result


final class InfoViewController: ASViewController<ASDisplayNode>, Labelable {
    
    //MARK: Properties
    fileprivate let celebST: CelebrityStruct
    fileprivate let pulseView: View
    internal var delegate: DetailSubViewable?
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.pulseView = View(frame: Constants.kBottomViewRect)
        super.init(node: ASDisplayNode())
        self.view.isHidden = true
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        CelebrityViewModel().getCelebritySignal(id: self.celebST.id)
            .flatMapError { error -> SignalProducer<CelebrityModel, NoError> in return .empty }
            .startWithValues({ celeb in
                let birthdate: Date = celeb.birthdate.date(inFormat: "MM/dd/yyyy")!
                let age: Int = (Date().month < birthdate.month || (Date().month == birthdate.month && Date().day < birthdate.day)) ? (Date().year - (birthdate.year+1)) : (Date().year - birthdate.year)
                let formatter = DateFormatter()
                formatter.dateStyle = DateFormatter.Style.long
                
                RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id)
                    .flatMapError { error -> SignalProducer<Double, NoError> in return .empty }
                    .startWithValues({ score in
                        for (index, quality) in Info.getAll().enumerated() {
                            let barHeight = UIDevice.getPulseBarHeight()
                            let qualityView: PulseView = PulseView(frame: CGRect(x: 0, y: CGFloat(index) * (Constants.kBottomHeight / 10) + Constants.kPadding, width: Constants.kMaxWidth, height: barHeight))
                            qualityView.tag = index+1
                            let qualityLabel: UILabel = self.setupLabel(title: quality, frame: CGRect(x: Constants.kPadding, y: 3, width: 120, height: barHeight - 5))
                            
                            var infoLabelText: String = ""
                            var attributedText: NSAttributedString = NSAttributedString()
                            switch quality {
                            case Info.firstName.name(): infoLabelText = celeb.firstName
                            case Info.middleName.name(): infoLabelText = celeb.middleName
                            case Info.lastName.name(): infoLabelText = celeb.lastName
                            case Info.from.name(): infoLabelText = celeb.from
                            case Info.birthdate.name(): infoLabelText = formatter.string(from: birthdate as Date) + String(" (\(age))")
                            case Info.height.name(): infoLabelText = celeb.height
                            case Info.zodiac.name(): infoLabelText = (celeb.birthdate.date(inFormat:"MM/dd/yyyy")?.zodiacSign().name())!
                            case Info.status.name(): infoLabelText = celeb.status
                            case Info.celScore.name(): attributedText = self.createCelScoreText(score)
                            case Info.networth.name(): infoLabelText = celeb.netWorth
                            default: infoLabelText = ""
                            }
                            
                            let infoLabel: UILabel?
                            if case Info.celScore.name() = quality {
                                infoLabel = UILabel(frame: CGRect(x: qualityLabel.width, y: 3, width: Constants.kMaxWidth - (qualityLabel.width + Constants.kPadding), height: barHeight - 5))
                                infoLabel!.attributedText = attributedText
                                infoLabel!.backgroundColor = Constants.kGreyBackground
                            } else {
                                infoLabel = self.setupLabel(title: infoLabelText, frame: CGRect(x: qualityLabel.width, y: 3, width: Constants.kMaxWidth - (qualityLabel.width + Constants.kPadding), height: barHeight - 5))
                            }
                            infoLabel!.textAlignment = .right
                        
                            qualityView.depthPreset = .depth1
                            qualityView.backgroundColor = Constants.kGreyBackground
                            qualityView.addSubview(qualityLabel)
                            qualityView.addSubview(infoLabel!)
                            SettingsViewModel().getSettingSignal(settingType: .publicService)
                                .observe(on: UIScheduler())
                                .startWithValues({ status in
                                if (status as! Bool) == true {
                                    qualityView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(InfoViewController.longPress(_:)))) }
                            })
                            self.pulseView.addSubview(qualityView)
                        }
                    })
            })
        self.pulseView.backgroundColor = Color.clear
        self.view = self.pulseView
    }
    
    func createCelScoreText(_ score: Double) -> NSAttributedString {
        var attributedText = NSMutableAttributedString()
        let percent: Double = (score/self.celebST.prevScore) * 100 - 100
        let percentage: String = "(" + (percent < 0 ? String(percent.roundToPlaces(places: 2)) : "+" + String(percent.roundToPlaces(places: 2))) + "%)"
        let attr1 = [NSFontAttributeName: UIFont.systemFont(ofSize: 13.0), NSForegroundColorAttributeName : percent >= 0 ? Constants.kBlueText : Constants.kRedText]
        attributedText = NSMutableAttributedString(string: percentage, attributes: attr1)
        let attr2 = [NSFontAttributeName: UIFont.systemFont(ofSize: Constants.kFontSize), NSForegroundColorAttributeName : score >= 80 ? Constants.kBlueText : Constants.kRedText]
        let attrString = NSAttributedString(string: String(format: " %.1f", score)+"%", attributes: attr2)
        attributedText.append(attrString)
        return attributedText
    }
    
    func longPress(_ gesture: UIGestureRecognizer) {
        let celebIndex = gesture.view!.tag - 1
        let quality = Info(rawValue: celebIndex)!.text()
        
        CelebrityViewModel().getCelebritySignal(id: self.celebST.id)
            .flatMapError { error -> SignalProducer<CelebrityModel, NoError> in return .empty }
            .startWithValues({ celeb in
                let birthdate: Date = celeb.birthdate.date(inFormat:"MM/dd/yyyy")!
                let age: Int = (Date().month < birthdate.month || (Date().month == birthdate.month && Date().day < birthdate.day)) ? (Date().year - (birthdate.year+1)) : (Date().year - birthdate.year)
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                
                let infoText: String
                switch quality {
                case Info.firstName.text(): infoText = celeb.firstName
                case Info.middleName.text(): infoText = celeb.middleName
                case Info.lastName.text(): infoText = celeb.lastName
                case Info.from.text(): infoText = celeb.from
                case Info.birthdate.text(): infoText = formatter.string(from: birthdate as Date) + String(" (\(age))")
                case Info.height.text(): infoText = celeb.height
                case Info.zodiac.text(): infoText = (celeb.birthdate.date(inFormat:"MM/dd/yyyy")?.zodiacSign().name())!
                case Info.status.text(): infoText = celeb.status
                case Info.celScore.text(): infoText = String(format: "%.2f", celeb.prevScore)
                case Info.networth.text(): infoText = celeb.netWorth
                default: infoText = "n/a"
                }
                let who = self.celebST.nickname.characters.last == "s" ? "\(self.celebST.nickname)'" : "\(self.celebST.nickname)'s"
                self.delegate!.socialSharing(message: "\(who) \(quality) \(infoText)")
            })
    }
}
