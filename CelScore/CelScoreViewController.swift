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
        self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 14, title: "Yesterday", value: celebST.prevScore.getRoyalty(), tag: 2))
        self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 48, title: "Last Week", value: celebST.prevWeek.getRoyalty(), tag: 3))
        self.pulseView.addSubview(self.getView(positionY: gaugeHeight + 82, title: "Last Month", value: celebST.prevMonth.getRoyalty(), tag: 4))
        self.pulseView.backgroundColor = Color.clear
        self.view = self.pulseView
    }
    
    func getGaugeView(_ gaugeHeight: CGFloat) -> PulseView {
        let gaugeView: PulseView = PulseView(frame: CGRect(x: 0, y: Constants.kPadding, width: Constants.kMaxWidth, height: gaugeHeight))
        gaugeView.depthPreset = .depth1
        gaugeView.tag = 1
        gaugeView.backgroundColor = Constants.kGreyBackground
        gaugeView.pulseAnimation = .none
        let gauge: LMGaugeView = LMGaugeView()
        gauge.minValue = Constants.kMinimumVoteValue
        gauge.maxValue = Constants.kMaximumVoteValue
        gauge.limitValue = Constants.kMaximumVoteValue
        let gaugeWidth: CGFloat = UIDevice.getGaugeDiameter()
        gauge.frame = CGRect(x: (Constants.kMaxWidth - gaugeWidth)/2, y: (gaugeView.height - gaugeWidth)/2, width: gaugeWidth, height: gaugeWidth)
        gauge.subDivisionsColor = Constants.kBlueShade
        gauge.divisionsColor = Color.black
        gauge.valueTextColor = Color.black
        gauge.unitOfMeasurementTextColor = Color.black
        gauge.ringBackgroundColor = Constants.kBlueShade
        gauge.backgroundColor = Constants.kGreyBackground
        gauge.delegate = self
        gaugeView.addSubview(gauge)

        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id)
            .startWithValues({ celscore in
                let score = CGFloat(celscore.roundToPlaces(places: 2))
                Timer.after(1.5, {
                    let firstSlow: CGFloat = score * 0.8
                    let secondSlow: CGFloat = score * 0.9
                    Timer.every(0.01, { (timer: Timer) in
                        self.updateGauge(gauge, timer: timer, firstSlow: firstSlow, secondSlow: secondSlow, stopValue: score)
                    })
                })
            })
        return gaugeView
    }
    
    func getView(positionY: CGFloat, title: String, value: Double, tag: Int) -> PulseView {
        let titleLabel: UILabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 3, width: 180, height: 25))
        let infoLabel: UILabel = self.setupLabel(title: String(value), frame: CGRect(x: titleLabel.width, y: 3, width: Constants.kMaxWidth - (titleLabel.width + Constants.kPadding), height: 25))

        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithValues({ celscore in
            var attributedText = NSMutableAttributedString()
            let percent: Double = (celscore / value * 100 - 100).roundToPlaces(places: 1)
            let percentage: String = (percent >= 0 ? "+" + String(percent) : String(percent)) + "% "
            let attr1 = [NSFontAttributeName: UIFont.systemFont(ofSize: 12.0), NSForegroundColorAttributeName : percent >= 0 ? Constants.kBlueText : Constants.kRedText]
            attributedText = NSMutableAttributedString(string: percentage, attributes: attr1)
            let attr2 = [NSFontAttributeName: UIFont.systemFont(ofSize: Constants.kFontSize), NSForegroundColorAttributeName : value >= Constants.kRoyalty ? Constants.kBlueText : Constants.kRedText]
            let attrString = NSAttributedString(string: " " + String(value) + "%", attributes: attr2)
            attributedText.append(attrString)
            infoLabel.attributedText = attributedText
        })
        
        infoLabel.textAlignment = .right
        let taggedView = PulseView(frame: CGRect(x: 0, y: positionY, width: Constants.kMaxWidth, height: 30))
        taggedView.depthPreset = .depth1
        taggedView.tag = tag
        taggedView.backgroundColor = Constants.kGreyBackground
        taggedView.pulseAnimation = .centerWithBacking
        taggedView.addSubview(titleLabel)
        taggedView.addSubview(infoLabel)
        return taggedView
    }
    
    func updateGauge(_ gaugeView: LMGaugeView, timer: Timer, firstSlow: CGFloat, secondSlow: CGFloat, stopValue: CGFloat) {
        if gaugeView.value > stopValue { timer.invalidate() }
        else if gaugeView.value > secondSlow { gaugeView.value += 0.05 }
        else if gaugeView.value > firstSlow { gaugeView.value += 0.1 }
        else { gaugeView.value += 0.3 }
    }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(_ gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        return Constants.kRedShade
    }
}
