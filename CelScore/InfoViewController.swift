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
                            let qualityLabel: UILabel = self.setupLabel(title: quality, frame: CGRect(x: Constants.kPadding, y: 3, width: 122, height: barHeight - 5))
                            
                            var infoLabelText: String = ""
                            switch quality {
                            case Info.firstName.name(): infoLabelText = celeb.firstName
                            case Info.middleName.name(): infoLabelText = celeb.middleName
                            case Info.lastName.name(): infoLabelText = celeb.lastName
                            case Info.from.name(): infoLabelText = celeb.from
                            case Info.birthdate.name(): infoLabelText = formatter.string(from: birthdate as Date) + String(" (\(age))")
                            case Info.height.name(): infoLabelText = celeb.height
                            case Info.zodiac.name(): infoLabelText = (celeb.birthdate.date(inFormat:"MM/dd/yyyy")?.zodiacSign().name())!
                            case Info.status.name(): infoLabelText = celeb.status
                            case Info.throne.name(): infoLabelText = String(celeb.daysOnThrone) + " Day(s)"
                            case Info.networth.name(): infoLabelText = celeb.netWorth
                            default: infoLabelText = ""
                            }
                            
                            let infoLabel = self.setupLabel(title: infoLabelText, frame: CGRect(x: qualityLabel.width, y: 3, width: Constants.kMaxWidth - (qualityLabel.width + Constants.kPadding), height: barHeight - 5))
                            infoLabel.textAlignment = .right
                            if case Info.throne.name() = quality {
                                infoLabel.textColor = celeb.daysOnThrone > 0 ? Constants.kBlueLight : Constants.kRedLight
                            }
                        
                            qualityView.depthPreset = .depth1
                            qualityView.backgroundColor = Constants.kGreyBackground
                            qualityView.addSubview(qualityLabel)
                            qualityView.addSubview(infoLabel)
                            self.pulseView.addSubview(qualityView)
                        }
                    })
            })
        self.pulseView.backgroundColor = Color.clear
        self.view = self.pulseView
    }
}
