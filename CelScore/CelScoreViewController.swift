//
//  CelScoreViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/8/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material
import AIRTimer
import ReactiveCocoa


final class CelScoreViewController: ASViewController, LMGaugeViewDelegate, Labelable {
    
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
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let gaugeHeight = Constants.kBottomHeight - 105
        self.pulseView.addSubview(getGaugeView(gaugeHeight))
        self.pulseView.addSubview(getView(positionY: gaugeHeight + 13.5, title: "Yesterday's Score", value: String("\(self.celebST.prevScore.roundToPlaces(2))"), tag: 2))
        RatingsViewModel().getConsensusSignal(ratingsId: self.celebST.id).startWithNext({ consensus in
            let percentage = String(consensus.roundToPlaces(2))
            self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 47.5, title: "Consensus of Opinion", value: percentage, tag: 3)) })
        RatingsViewModel().getMoneyShotSignal(ratingsId: self.celebST.id)
            .on(failed: { _ in self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 81.5, title: "Claim to Fame", value: "n/a", tag: 4)) })
            .on(next: { index in  self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 81.5, title: "Claim to Fame", value: Qualities(rawValue: index)!.name(isMale: self.celebST.sex), tag: 4))})
            .start()
        
        self.pulseView.backgroundColor = MaterialColor.clear
        self.view = self.pulseView
    }
    
    func getGaugeView(gaugeHeight: CGFloat) -> MaterialPulseView {
        let gaugeView: MaterialPulseView = MaterialPulseView(frame: CGRect(x: 0, y: Constants.kPadding, width: Constants.kMaxWidth, height: gaugeHeight))
        
        SettingsViewModel().getSettingSignal(settingType: .PublicService)
            .observeOn(UIScheduler())
            .startWithNext({ status in
                if (status as! Bool) == true {
                    gaugeView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CelScoreViewController.longPress(_:)))) }
            })
        gaugeView.depth = .Depth1
        gaugeView.tag = 1
        gaugeView.backgroundColor = Constants.kGreyBackground
        gaugeView.pulseAnimation = .None
        let gauge: LMGaugeView = LMGaugeView()
        gauge.minValue = Constants.kMinimumVoteValue
        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithNext({ celscore in gauge.maxValue = CGFloat(celscore.roundToPlaces(2)) })
        gauge.limitValue = Constants.kMiddleVoteValue
        let gaugeWidth: CGFloat = UIDevice.getGaugeDiameter()
        gauge.frame = CGRect(x: (Constants.kMaxWidth - gaugeWidth)/2, y: (gaugeView.height - gaugeWidth)/2, width: gaugeWidth, height: gaugeWidth)
        gauge.subDivisionsColor = Constants.kBlueShade
        gauge.divisionsColor = MaterialColor.black
        gauge.valueTextColor = MaterialColor.black
        gauge.unitOfMeasurementTextColor = MaterialColor.black
        gauge.ringBackgroundColor = Constants.kBlueShade
        gauge.backgroundColor = Constants.kGreyBackground
        gauge.delegate = self
        let firstSlow: CGFloat = (gauge.maxValue / 10) * 9.2
        let secondSlow: CGFloat = (gauge.maxValue / 10) * 9.6
        let thirdSlow: CGFloat = (gauge.maxValue / 10) * 9.8
        let finalSlow: CGFloat = (gauge.maxValue / 10) * 9.93
        var timer: AIRTimer?
        AIRTimer.after(1.5) { _ in timer = AIRTimer.every(0.1){ timer in self.updateGauge(gauge, timer: timer, firstSlow: firstSlow, secondSlow: secondSlow, thirdSlow: thirdSlow, finalSlow: finalSlow) } }
        AIRTimer.every(30) { _ in
            timer?.invalidate()
            let diceRoll = Int(arc4random_uniform(2) + 7)
            gauge.unitOfMeasurement = GaugeFace(rawValue: diceRoll)!.emoji()
            AIRTimer.after(2) { _ in timer?.restart() }
        }
        gaugeView.addSubview(gauge)
        return gaugeView
    }
    
    func getView(positionY positionY: CGFloat, title: String, value: String, tag: Int) -> MaterialPulseView {
        let titleLabel: UILabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 3, width: 180, height: 25))
        let infoLabel: UILabel = self.setupLabel(title: value, frame: CGRect(x: titleLabel.width, y: 3, width: Constants.kMaxWidth - (titleLabel.width + Constants.kPadding), height: 25))
        if tag == 4 { infoLabel.textColor = Constants.kBlueText }
        else if tag == 3 {
            infoLabel.text = value + "%"
            infoLabel.textColor = Double(value) >= Constants.kPositiveConsensus ? Constants.kBlueText : Constants.kRedText
        }
        infoLabel.textAlignment = .Right
        let taggedView = MaterialPulseView(frame: CGRect(x: 0, y: positionY, width: Constants.kMaxWidth, height: 30))
        SettingsViewModel().getSettingSignal(settingType: .PublicService)
            .observeOn(UIScheduler())
            .startWithNext({ status in
            if (status as! Bool) == true { taggedView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CelScoreViewController.longPress(_:)))) } })
        taggedView.tag = tag
        taggedView.depth = .Depth1
        taggedView.backgroundColor = Constants.kGreyBackground
        taggedView.pulseAnimation = .CenterWithBacking
        taggedView.addSubview(titleLabel)
        taggedView.addSubview(infoLabel)
        return taggedView
    }
    
    func longPress(gesture: UIGestureRecognizer) {
        let who: String = self.celebST.nickname.characters.last == "s" ? "\(self.celebST.nickname)'" : "\(self.celebST.nickname)'s"
        switch gesture.view!.tag {
        case 1: RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithNext { celscore in
                self.delegate!.socialSharing(message: "\(who) \(Info.CelScore.text()) \(String(format: "%.2f", celscore))") }
        case 2: self.delegate!.socialSharing(message: "\(who) score yesterday was \(String(format: "%.2f", self.celebST.prevScore))")
        default: RatingsViewModel().getConsensusSignal(ratingsId: self.celebST.id).startWithNext { consensus in
                self.delegate!.socialSharing(message: "\(who) general consensus is \(String(format: "%.2f", consensus))%") }
        }
    }
    
    func updateGauge(gaugeView: LMGaugeView, timer: AIRTimer, firstSlow: CGFloat, secondSlow: CGFloat, thirdSlow: CGFloat, finalSlow: CGFloat) {
        if gaugeView.value > finalSlow { gaugeView.value += 0.0005 }
        else if gaugeView.value > thirdSlow { gaugeView.value += 0.0015 }
        else if gaugeView.value > secondSlow { gaugeView.value += 0.0035 }
        else if gaugeView.value > firstSlow { gaugeView.value += 0.007 }
        else if gaugeView.value < gaugeView.maxValue { gaugeView.value += 0.05 }
        else { timer.invalidate() }
    }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        switch value {
        case 4.5..<5.1: gaugeView.unitOfMeasurement = GaugeFace.Grin.emoji()
        case 3.5..<4.5: gaugeView.unitOfMeasurement = GaugeFace.BigSmile.emoji()
        case 3.0..<3.5: gaugeView.unitOfMeasurement = GaugeFace.Smile.emoji()
        case 2.5..<3.0: gaugeView.unitOfMeasurement = GaugeFace.NoSmile.emoji()
        case 2.0..<2.5: gaugeView.unitOfMeasurement = GaugeFace.SadFace.emoji()
        case 1.0..<2.0: gaugeView.unitOfMeasurement = GaugeFace.Angry.emoji()
        default: gaugeView.unitOfMeasurement = GaugeFace.Awaking.emoji()
        }
        return Constants.kRedShade
    }
}