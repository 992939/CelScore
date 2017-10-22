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
    fileprivate let celebrity: CelebrityModel
    fileprivate let pulseView: View
    internal var delegate: DetailSubViewable?
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrity: CelebrityModel) {
        self.celebrity = celebrity
        self.pulseView = View(frame: Constants.kBottomViewRect)
        super.init(node: ASDisplayNode())
        self.view.isHidden = true
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let birthdate: Date = dateFormatter.date(from: self.celebrity.birthdate)!
        
        let calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .year, .hour])
        let components = calendar.dateComponents(unitFlags, from: birthdate)
        let now = calendar.dateComponents(unitFlags, from: Date())
        
        let age: Int = (now.month! < components.month! || (now.month! == components.month! && now.day! < components.day!)) ? (now.year! - (components.year!+1)) : (now.year! - components.year!)
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        
        RatingsViewModel().getCelScoreSignal(ratingsId: celebrity.id)
            .on(value: { score in
                for (index, quality) in Info.getAll().enumerated() {
                    let barHeight = UIDevice.getPulseBarHeight()
                    let qualityView: PulseView = PulseView(frame: CGRect(x: 0, y: CGFloat(index) * (Constants.kBottomHeight / 10) + Constants.kPadding, width: Constants.kMaxWidth, height: barHeight))
                    qualityView.tag = index+1
                    let qualityLabel: UILabel = self.setupLabel(title: quality, frame: CGRect(x: Constants.kPadding, y: 3, width: UIDevice.getLabelWidth(), height: barHeight - 5))
                    let days = self.celebrity.daysOnThrone == 1 ? " Day" : " Days"
                    var infoLabelText: String = ""
                    switch quality {
                    case Info.firstName.name(): infoLabelText = self.celebrity.firstName
                    case Info.middleName.name(): infoLabelText = self.celebrity.middleName
                    case Info.lastName.name(): infoLabelText = self.celebrity.lastName
                    case Info.from.name(): infoLabelText = self.celebrity.from
                    case Info.birthdate.name(): infoLabelText = formatter.string(from: birthdate as Date) + String(" (\(age))")
                    case Info.height.name(): infoLabelText = self.celebrity.height
                    case Info.zodiac.name(): infoLabelText = birthdate.zodiacSign().name()
                    case Info.status.name(): infoLabelText = self.celebrity.status
                    case Info.throne.name(): infoLabelText = String(self.celebrity.daysOnThrone) + days
                    case Info.networth.name(): infoLabelText = self.celebrity.netWorth
                    default: infoLabelText = ""
                    }
                    
                    let infoLabel = self.setupLabel(title: infoLabelText, frame: CGRect(x: qualityLabel.width, y: 3, width: Constants.kMaxWidth - (qualityLabel.width + Constants.kPadding), height: barHeight - 5))
                    infoLabel.textAlignment = .right
                    infoLabel.adjustsFontSizeToFitWidth = true
                    if case Info.throne.name() = quality {
                        infoLabel.textColor = self.celebrity.daysOnThrone > 0 ? Constants.kBlueLight : Constants.kRedLight
                    }
                    
                    qualityView.depthPreset = .depth2
                    qualityView.layer.cornerRadius = 5.0
                    qualityView.backgroundColor = Constants.kGreyBackground
                    qualityView.addSubview(qualityLabel)
                    qualityView.addSubview(infoLabel)
                    self.pulseView.addSubview(qualityView)
                }
            })
            .start()
        self.pulseView.backgroundColor = Color.clear
        self.view = self.pulseView
    }
}
