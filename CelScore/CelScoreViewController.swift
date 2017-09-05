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
        let gaugeHeight = Constants.kBottomHeight - UIDevice.getGaugeHeightLimit()
        self.pulseView.addSubview(getGaugeView(gaugeHeight))
        
        CelebrityViewModel().getCelebritySignal(id: self.celebST.id)
            .on(value: { celebrity in
                let pulseView1 = self.getView(positionY: gaugeHeight + 14, title: "Royalty Yesterday", value: self.celebST.prevScore, past: celebrity.y_index)
                self.pulseView.addSubview(pulseView1)
                let pulseView2 = self.getView(positionY: pulseView1.y + UIDevice.getCelScoreBarHeight() + Constants.kPadding * 0.4, title: "Royalty Last Week", value: self.celebST.prevWeek, past: celebrity.w_index)
                self.pulseView.addSubview(pulseView2)
                let pulseView3 = self.getView(positionY: pulseView2.y + UIDevice.getCelScoreBarHeight() + Constants.kPadding * 0.4, title: "Royalty Last Month", value: self.celebST.prevMonth, past: celebrity.m_index)
                self.pulseView.addSubview(pulseView3)
            }).start()
        self.pulseView.backgroundColor = Color.clear
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

        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id)
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
        let infoLabel: UILabel = self.setupLabel(title: String(value) + "%", frame: CGRect(x: titleLabel.width, y: UIDevice.getCelScoreBarHeight() * 0.1, width: 60, height: UIDevice.getCelScoreBarHeight() - 5))
        
        var changeLabel: UILabel?
        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithValues({ celscore in
            let percent: Double = (celscore - value).roundToPlaces(places: 1)
            let percentage: String = (percent >= 0 ? "+" + String(percent) : String(percent))
            changeLabel = self.setupLabel(title: percentage, frame: CGRect(x: infoLabel.right + UIDevice.getCelScoreSpacing(), y: UIDevice.getCelScoreBarHeight() * 0.1, width: 70, height: UIDevice.getCelScoreBarHeight() - 5))
            changeLabel?.textColor = percent >= 0 ? Constants.kBlueLight : Constants.kRedLight
        })
        
        let paddingMultiplier: CGFloat = Constants.kIsOriginalIphone ? 3.0 : 3.5
        let pastSize: CGFloat = UIDevice.getCelScorePast()
        let pastNode = ASImageNode()
        pastNode.frame = CGRect(x: Constants.kMaxWidth - paddingMultiplier * Constants.kPadding, y: UIDevice.getCelScoreBarHeight() * 0.1, width: pastSize + 2, height: pastSize + 2)
        pastNode.image = R.image.past_circle()!
        
        let pastLabel = UILabel(frame: CGRect(x: Constants.kMaxWidth - (paddingMultiplier - 0.1) * Constants.kPadding, y: UIDevice.getCelScoreBarHeight() * 0.15, width: pastSize, height: pastSize))
        pastLabel.text = String(past)
        pastLabel.textAlignment = .center
        pastLabel.font = R.font.droidSerifBold(size: 12)!
        pastLabel.textColor = Constants.kRedShade
        
        let taggedView = PulseView(frame: CGRect(x: 0, y: positionY, width: Constants.kMaxWidth, height: UIDevice.getCelScoreBarHeight()))
        taggedView.depthPreset = .depth2
        taggedView.layer.cornerRadius = 5.0
        taggedView.backgroundColor = Constants.kGreyBackground
        taggedView.pulseAnimation = .centerWithBacking
        taggedView.addSubview(titleLabel)
        taggedView.addSubview(infoLabel)
        taggedView.addSubview(changeLabel!)
        taggedView.addSubview(pastNode.view)
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
