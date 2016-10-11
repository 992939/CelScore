//
//  CelScoreViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/8/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material
import SwiftyTimer
import ReactiveCocoa
import ReactiveSwift


final class CelScoreViewController: ASViewController<ASDisplayNode>, LMGaugeViewDelegate, Labelable {
    
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
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let gaugeHeight = Constants.kBottomHeight - 105
        self.pulseView.addSubview(getGaugeView(gaugeHeight))
        
        self.pulseView.addSubview(getView(positionY: gaugeHeight + 13.5, title: "Since Yesterday", value: String("\(self.celebST.prevScore)"), tag: 2))
        
        CelebrityViewModel().getCelebritySignal(id: self.celebST.id)
            .flatMapError { _ in SignalProducer.empty }
            .startWithValues({ celeb in
            self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 47.5, title: "Since Last Week", value: String(celeb.prevWeek), tag: 3))
            self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 81.5, title: "On The Throne", value: String(celeb.daysOnThrone) + " Day(s)", tag: 4))
        })
        
        self.pulseView.backgroundColor = Color.clear
        self.view = self.pulseView
    }
    
    func getGaugeView(_ gaugeHeight: CGFloat) -> PulseView {
        let gaugeView: PulseView = PulseView(frame: CGRect(x: 0, y: Constants.kPadding, width: Constants.kMaxWidth, height: gaugeHeight))
        
        SettingsViewModel().getSettingSignal(settingType: .publicService)
            .observe(on: UIScheduler())
            .startWithValues({ status in
                if (status as! Bool) == true {
                    gaugeView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CelScoreViewController.longPress(_:)))) }
            })
        gaugeView.depthPreset = .depth1
        gaugeView.tag = 1
        gaugeView.backgroundColor = Constants.kGreyBackground
        gaugeView.pulseAnimation = .none
        let gauge: LMGaugeView = LMGaugeView()
        gauge.minValue = Constants.kMinimumVoteValue
        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithValues({ celscore in gauge.maxValue = CGFloat(celscore.roundToPlaces(places: 2)) })
        gauge.limitValue = Constants.kMiddleVoteValue
        let gaugeWidth: CGFloat = UIDevice.getGaugeDiameter()
        gauge.frame = CGRect(x: (Constants.kMaxWidth - gaugeWidth)/2, y: (gaugeView.height - gaugeWidth)/2, width: gaugeWidth, height: gaugeWidth)
        gauge.subDivisionsColor = Constants.kBlueShade
        gauge.divisionsColor = Color.black
        gauge.valueTextColor = Color.black
        gauge.unitOfMeasurementTextColor = Color.black
        gauge.ringBackgroundColor = Constants.kBlueShade
        gauge.backgroundColor = Constants.kGreyBackground
        gauge.delegate = self
        let firstSlow: CGFloat = (gauge.maxValue / 10) * 9.6
        let secondSlow: CGFloat = (gauge.maxValue / 10) * 9.8
        let thirdSlow: CGFloat = (gauge.maxValue / 10) * 9.9
        let finalSlow: CGFloat = (gauge.maxValue / 10) * 9.94
        var timer: Timer?
        
        Timer.after(1.5.seconds) { _ in timer = Timer.every(100.ms){ timer in self.updateGauge(gauge, timer: timer, firstSlow: firstSlow, secondSlow: secondSlow, thirdSlow: thirdSlow, finalSlow: finalSlow) } }
        
        Timer.every(30.seconds) { timer in
            timer?.invalidate()
            let diceRoll = Int(arc4random_uniform(2) + 7)
            gauge.unitOfMeasurement = GaugeFace(rawValue: diceRoll)!.emoji()
            Timer.after(2.seconds) { _ in timer?.restart() }
        }
        gaugeView.addSubview(gauge)
        return gaugeView
    }
    
    func getView(positionY: CGFloat, title: String, value: String, tag: Int) -> PulseView {
        let titleLabel: UILabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 3, width: 180, height: 25))
        let infoLabel: UILabel = self.setupLabel(title: value, frame: CGRect(x: titleLabel.width, y: 3, width: Constants.kMaxWidth - (titleLabel.width + Constants.kPadding), height: 25))
        if tag < 4 {
            RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithValues({ celscore in
                var attributedText = NSMutableAttributedString()
                let percent: Double = (celscore/Double(value)!) * 100 - 100
                let percentage: String = "(" + (percent < 0 ? String(percent.roundToPlaces(places: 2)) : "+" + String(percent.roundToPlaces(places: 2))) + "%)"
                let attr1 = [NSFontAttributeName: UIFont.systemFont(ofSize: 13.0), NSForegroundColorAttributeName : percent >= 0 ? Constants.kBlueText : Constants.kRedText]
                attributedText = NSMutableAttributedString(string: percentage, attributes: attr1)
                let attr2 = [NSFontAttributeName: UIFont.systemFont(ofSize: Constants.kFontSize), NSForegroundColorAttributeName : Color.black]
                let attrString = NSAttributedString(string: String(format: " %.2f", Double(value)!), attributes: attr2)
                attributedText.append(attrString)
                infoLabel.attributedText = attributedText
            })
        }
        else if tag == 4 {
            infoLabel.text = value
            infoLabel.lineBreakMode = .byWordWrapping
            infoLabel.textColor = Constants.kBlueLight
        }
        infoLabel.textAlignment = .right
        let taggedView = PulseView(frame: CGRect(x: 0, y: positionY, width: Constants.kMaxWidth, height: 30))
        SettingsViewModel().getSettingSignal(settingType: .publicService)
            .observe(on: UIScheduler())
            .startWithValues({ status in
            if (status as! Bool) == true { taggedView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CelScoreViewController.longPress(_:)))) } })
        taggedView.tag = tag
        taggedView.depthPreset = .depth1
        taggedView.backgroundColor = Constants.kGreyBackground
        taggedView.pulseAnimation = .centerWithBacking
        taggedView.addSubview(titleLabel)
        taggedView.addSubview(infoLabel)
        return taggedView
    }
    
    func longPress(_ gesture: UIGestureRecognizer) {
        let who: String = self.celebST.nickname.characters.last == "s" ? "\(self.celebST.nickname)'" : "\(self.celebST.nickname)'s"
        switch gesture.view!.tag {
        case 1: RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithValues { celscore in
                self.delegate!.socialSharing(message: "\(who) \(Info.celScore.text()) \(String(format: "%.2f", celscore))") }
        case 2: self.delegate!.socialSharing(message: "\(who) score yesterday was \(String(format: "%.2f", self.celebST.prevScore))")
        default: RatingsViewModel().getConsensusSignal(ratingsId: self.celebST.id).startWithValues { consensus in
                self.delegate!.socialSharing(message: "\(who) general consensus is \(String(format: "%.2f", consensus))%") }
        }
    }
    
    func updateGauge(_ gaugeView: LMGaugeView, timer: Timer, firstSlow: CGFloat, secondSlow: CGFloat, thirdSlow: CGFloat, finalSlow: CGFloat) {
        if gaugeView.value > finalSlow { gaugeView.value += 0.0005 }
        else if gaugeView.value > thirdSlow { gaugeView.value += 0.0015 }
        else if gaugeView.value > secondSlow { gaugeView.value += 0.0035 }
        else if gaugeView.value > firstSlow { gaugeView.value += 0.007 }
        else if gaugeView.value < gaugeView.maxValue { gaugeView.value += 0.05 }
        else { timer.invalidate() }
    }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(_ gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        switch value {
        case 4.5..<5.1: gaugeView.unitOfMeasurement = GaugeFace.grin.emoji()
        case 3.5..<4.5: gaugeView.unitOfMeasurement = GaugeFace.bigSmile.emoji()
        case 3.0..<3.5: gaugeView.unitOfMeasurement = GaugeFace.smile.emoji()
        case 2.5..<3.0: gaugeView.unitOfMeasurement = GaugeFace.noSmile.emoji()
        case 2.0..<2.5: gaugeView.unitOfMeasurement = GaugeFace.sadFace.emoji()
        case 1.0..<2.0: gaugeView.unitOfMeasurement = GaugeFace.angry.emoji()
        default: gaugeView.unitOfMeasurement = GaugeFace.awaking.emoji()
        }
        return Constants.kRedShade
    }
}
