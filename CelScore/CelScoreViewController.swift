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
        self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 13.5, title: "Yesterday", value: celebST.prevScore.getRoyalty(), tag: 2))
        self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 47.5, title: "Last Week", value: celebST.prevWeek.getRoyalty(), tag: 3))
        self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 81.5, title: "Last Month", value: celebST.prevMonth.getRoyalty(), tag: 4))
        self.pulseView.backgroundColor = Color.clear
        self.view = self.pulseView
    }
    
    func getGaugeView(_ gaugeHeight: CGFloat) -> PulseView {
        let gaugeView: PulseView = PulseView(frame: CGRect(x: 0, y: Constants.kPadding, width: Constants.kMaxWidth, height: gaugeHeight))
        
        SettingsViewModel().getSettingSignal(settingType: .onSocialSharing)
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
        let firstSlow: CGFloat = (gauge.maxValue / 10) * 9
        let secondSlow: CGFloat = (gauge.maxValue / 10) * 9.5
        let thirdSlow: CGFloat = (gauge.maxValue / 10) * 9.8
        let finalSlow: CGFloat = (gauge.maxValue / 10) * 9.9
        
        Timer.after(1.5.seconds) { _ in Timer.every(50.ms){ timer in self.updateGauge(gauge, timer: timer, firstSlow: firstSlow, secondSlow: secondSlow, thirdSlow: thirdSlow, finalSlow: finalSlow) } }
        
        gaugeView.addSubview(gauge)
        return gaugeView
    }
    
    func getView(positionY: CGFloat, title: String, value: Double, tag: Int) -> PulseView {
        let titleLabel: UILabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 3, width: 180, height: 25))
        let infoLabel: UILabel = self.setupLabel(title: String(value), frame: CGRect(x: titleLabel.width, y: 3, width: Constants.kMaxWidth - (titleLabel.width + Constants.kPadding), height: 25))

        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithValues({ celscore in
            var attributedText = NSMutableAttributedString()
            let percent: Double = (celscore / value * 100 - 100).roundToPlaces(places: 1)
            let percentage: String = "(" + (percent < 0 ? String(percent) : "+" + String(percent)) + "%) "
            let attr1 = [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName : percent >= 0 ? Constants.kBlueText : Constants.kRedText]
            attributedText = NSMutableAttributedString(string: percentage, attributes: attr1)
            let attr2 = [NSFontAttributeName: UIFont.systemFont(ofSize: Constants.kFontSize), NSForegroundColorAttributeName : value >= 80 ? Constants.kBlueText : Constants.kRedText]
            let attrString = NSAttributedString(string: String(value) + "%", attributes: attr2)
            attributedText.append(attrString)
            infoLabel.attributedText = attributedText
        })
        
        infoLabel.textAlignment = .right
        let taggedView = PulseView(frame: CGRect(x: 0, y: positionY, width: Constants.kMaxWidth, height: 30))
        SettingsViewModel().getSettingSignal(settingType: .onSocialSharing)
            .observe(on: UIScheduler())
            .startWithValues({ status in
            if (status as! Bool) == true { taggedView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CelScoreViewController.longPress(_:)))) } })
        taggedView.depthPreset = .depth1
        taggedView.tag = tag
        taggedView.backgroundColor = Constants.kGreyBackground
        taggedView.pulseAnimation = .centerWithBacking
        taggedView.addSubview(titleLabel)
        taggedView.addSubview(infoLabel)
        return taggedView
    }
    
    func longPress(_ gesture: UIGestureRecognizer) {
        let who: String = self.celebST.nickname
        switch gesture.view!.tag {
        case 1: RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithValues { celscore in
            self.delegate!.socialSharing(message: "\(who) is \(String(format: "%.1f", celscore))% Hollywood Royalty today.") }
        case 2: self.delegate!.socialSharing(message: "\(who) was \(String(format: "%.1f", self.celebST.prevScore.getRoyalty()))% Hollywood Royalty yesterday.")
        case 3: self.delegate!.socialSharing(message: "\(who) was \(String(format: "%.1f", self.celebST.prevWeek.getRoyalty()))% Hollywood Royalty last week.")
        default: self.delegate!.socialSharing(message: "\(who) was \(String(format: "%.1f", self.celebST.prevMonth.getRoyalty()))% Hollywood Royalty last month.")
        }
    }
    
    func updateGauge(_ gaugeView: LMGaugeView, timer: Timer, firstSlow: CGFloat, secondSlow: CGFloat, thirdSlow: CGFloat, finalSlow: CGFloat) {
        if gaugeView.value > finalSlow { gaugeView.value += 0.5 }
        else if gaugeView.value > thirdSlow { gaugeView.value += 0.1 }
        else if gaugeView.value > secondSlow { gaugeView.value += 0.15 }
        else if gaugeView.value > firstSlow { gaugeView.value += 0.25 }
        else if gaugeView.value < gaugeView.maxValue { gaugeView.value += 0.5 }
        else { timer.invalidate() }
    }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(_ gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        return Constants.kRedShade
    }
}
