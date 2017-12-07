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
    fileprivate let celebrity: CelebrityModel
    fileprivate let pulseView: View
    internal var delegate: DetailSubViewable?
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrity: CelebrityModel) {
        self.celebrity = celebrity
        self.pulseView = View(frame: Constants.kBottomViewRect)
        super.init(node: ASDisplayNode())
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gaugeHeight = Constants.kBottomHeight - UIDevice.getGaugeHeightLimit()
        let gaugeView = getGaugeView(gaugeHeight)
        let pulseView1 = self.getView(positionY: gaugeHeight + 14, title: "Royalty Yesterday", value: celebrity.prevScore, past: celebrity.y_index)
        let pulseView2 = self.getView(positionY: pulseView1.y + UIDevice.getCelScoreBarHeight() + Constants.kPadding * 0.4, title: "Royalty Last Week", value: celebrity.prevWeek, past: celebrity.w_index)
        let pulseView3 = self.getView(positionY: pulseView2.y + UIDevice.getCelScoreBarHeight() + Constants.kPadding * 0.4, title: "Royalty Last Month", value: celebrity.prevMonth, past: celebrity.m_index)
        
        self.pulseView.backgroundColor = Color.clear
        self.pulseView.addSubview(pulseView1)
        self.pulseView.addSubview(pulseView2)
        self.pulseView.addSubview(pulseView3)
        self.pulseView.addSubview(gaugeView)
        self.view = self.pulseView
    }
    
    func getGaugeView(_ gaugeHeight: CGFloat) -> PulseView {
        let gaugeView: PulseView = PulseView(frame: CGRect(x: 0, y: Constants.kPadding, width: Constants.kMaxWidth, height: gaugeHeight))
        gaugeView.depthPreset = .depth2
        gaugeView.backgroundColor = Constants.kGreyBackground
        gaugeView.layer.cornerRadius = Constants.kCornerRadius
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
        gauge.valueFont = UIFont(name: "HelveticaNeue-CondensedBold", size: UIDevice.getGaugeFontSize())
        gauge.unitOfMeasurementFont = UIFont(name: "HelveticaNeue", size: UIDevice.getFontSize()-1)
        gauge.unitOfMeasurementTextColor = Color.black
        gauge.ringBackgroundColor = Constants.kBlueShade
        gauge.backgroundColor = Constants.kGreyBackground
        gauge.delegate = self
        gaugeView.addSubview(gauge)

        RatingsViewModel().getCelScoreSignal(ratingsId: celebrity.id)
            .startWithValues({ celscore in
                let score = CGFloat(celscore.roundToPlaces(places: 2))
                Timer.after(1.5, {
                    let firstSlow: CGFloat = score * 0.8
                    let secondSlow: CGFloat = score * 0.9
                    Timer.every(0.05, { (timer: Timer) in
                        self.updateGauge(gauge, timer: timer, firstSlow: firstSlow, secondSlow: secondSlow, stopValue: score)
                    })
                })
            })
        return gaugeView
    }
    
    func getView(positionY: CGFloat, title: String, value: Double, past: Int) -> PulseView {
        let titleLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: UIDevice.getCelScoreBarHeight() * 0.1, width: UIDevice.getCelScoreTitleWidth(), height: UIDevice.getCelScoreBarHeight() - 5))
        let infoLabel: UILabel = self.setupLabel(title: String(value) + "%", frame: CGRect(x: titleLabel.width + 3, y: UIDevice.getCelScoreBarHeight() * 0.1, width: 55, height: UIDevice.getCelScoreBarHeight() - 5))
        
        var changeLabel: UILabel?
        RatingsViewModel().getCelScoreSignal(ratingsId: celebrity.id).startWithValues({ celscore in
            let percent: Double = (celscore - value).roundToPlaces(places: 1)
            let percentage: String = (percent >= 0 ? "+" + String(percent) : String(percent))
            changeLabel = self.setupLabel(title: percentage, frame: CGRect(x: infoLabel.right + UIDevice.getCelScoreSpacing(), y: UIDevice.getCelScoreBarHeight() * 0.1, width: 55, height: UIDevice.getCelScoreBarHeight() - 5))
            changeLabel?.textColor = percent >= 0 ? Constants.kBlueLight : Constants.kRedLight
        })
        
        let pastSize: CGFloat = 45.0
        let pastLabel = self.setupLabel(title: String("#\(past)"), frame: CGRect(x: Constants.kMaxWidth - pastSize, y: UIDevice.getCelScoreBarHeight() * 0.1, width: 35, height: UIDevice.getCelScoreBarHeight() - 5))
        pastLabel.textColor = Constants.kRedLight
        pastLabel.textAlignment = .center
        
        let taggedView = PulseView(frame: CGRect(x: 0, y: positionY, width: Constants.kMaxWidth, height: UIDevice.getCelScoreBarHeight()))
        taggedView.depthPreset = .depth2
        taggedView.layer.cornerRadius = 5.0
        taggedView.backgroundColor = Constants.kGreyBackground
        taggedView.pulseAnimation = .centerWithBacking
        taggedView.addSubview(titleLabel)
        taggedView.addSubview(infoLabel)
        taggedView.addSubview(changeLabel!)
        taggedView.addSubview(pastLabel)
        return taggedView
    }
    
    func updateGauge(_ gaugeView: LMGaugeView, timer: Timer, firstSlow: CGFloat, secondSlow: CGFloat, stopValue: CGFloat) {
        if gaugeView.value > stopValue { timer.invalidate() }
        else if gaugeView.value > secondSlow { gaugeView.value += 0.25 }
        else if gaugeView.value > firstSlow { gaugeView.value += 0.5 }
        else { gaugeView.value += 1 }
    }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(_ gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        return Constants.kRedShade
    }
}
