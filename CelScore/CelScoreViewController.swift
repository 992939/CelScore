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


final class CelScoreViewController: ASViewController, LMGaugeViewDelegate, Labelable {
    
    //MARK: Properties
    private let celebST: CelebrityStruct
    private let pulseView: MaterialView
    var delegate: DetailSubViewable?
    
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
        let gaugeHeight = Constants.kBottomHeight - 80
        self.pulseView.addSubview(getGaugeView(gaugeHeight))
        RatingsViewModel().getConsensusSignal(ratingsId: self.celebST.id)
            .startWithNext({ consensus -> () in
                let percentage = String(consensus.roundToPlaces(2)) + "%"
                self.pulseView.addSubview(self.getView(y: gaugeHeight, title: "General Consensus", value: percentage, tag: 2))
            })
        self.pulseView.addSubview(getView(y: gaugeHeight + 37, title: "Yesterday's Score", value: String("\(self.celebST.prevScore.roundToPlaces(2))"), tag: 3))
        self.pulseView.backgroundColor = MaterialColor.clear
        self.view = self.pulseView
    }
    
    func getGaugeView(gaugeHeight: CGFloat) -> MaterialPulseView {
        let gaugeView = MaterialPulseView(frame: CGRect(x: 0, y: Constants.kPadding, width: Constants.kMaxWidth, height: gaugeHeight))
        gaugeView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CelScoreViewController.longPress(_:))))
        gaugeView.depth = .Depth1
        gaugeView.tag = 1
        gaugeView.backgroundColor = Constants.kMainShade
        gaugeView.pulseScale = false
        let gauge = LMGaugeView()
        gauge.minValue = Constants.kMinimumVoteValue
        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithNext({ celscore in gauge.maxValue = CGFloat(celscore.roundToPlaces(2)) })
        gauge.limitValue = Constants.kMiddleVoteValue
        let gaugeWidth: CGFloat = 250
        gauge.frame = CGRect(x: (Constants.kMaxWidth - gaugeWidth)/2, y: (gaugeView.height - gaugeWidth)/2, width: gaugeWidth, height: gaugeWidth)
        gauge.subDivisionsColor = Constants.kDarkShade
        gauge.divisionsColor = Constants.kLightShade
        gauge.valueTextColor = MaterialColor.white
        gauge.unitOfMeasurementTextColor = MaterialColor.white
        gauge.ringBackgroundColor = Constants.kLightShade
        gauge.delegate = self
        AIRTimer.after(0.5) { _ in AIRTimer.every(0.1){ timer in self.updateGauge(gauge, timer: timer) } }
        gaugeView.addSubview(gauge)
        return gaugeView
    }
    
    func getView(y positionY: CGFloat, title: String, value: String, tag: Int) -> MaterialPulseView {
        let consensusLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 3, width: 160, height: 25))
        let infoLabel = self.setupLabel(title: value, frame: CGRect(x: consensusLabel.width, y: 3, width: Constants.kMaxWidth - (consensusLabel.width + Constants.kPadding), height: 25))
        infoLabel.textAlignment = .Right
        let consensusView = MaterialPulseView(frame: CGRect(x: 0, y: positionY + 17, width: Constants.kMaxWidth, height: 30))
        SettingsViewModel().getSettingSignal(settingType: .PublicService)
            .observeOn(UIScheduler())
            .startWithNext({ status in
            if (status as! Bool) == true {
                consensusView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CelScoreViewController.longPress(_:)))) }
        })
        consensusView.tag = tag
        consensusView.depth = .Depth1
        consensusView.backgroundColor = Constants.kMainShade
        consensusView.pulseScale = true
        consensusView.addSubview(consensusLabel)
        consensusView.addSubview(infoLabel)
        return consensusView
    }
    
    func longPress(gesture: UIGestureRecognizer) {
        switch gesture.view!.tag {
        case 1:
            RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithNext({ celscore in
                self.delegate!.socialSharing(message: "\(self.celebST.nickname)'s \(Info.CelScore.text()) \(String(format: "%.2f", celscore))")
            })
        case 2:
            RatingsViewModel().getConsensusSignal(ratingsId: self.celebST.id).startWithNext({ consensus in
                self.delegate!.socialSharing(message: "\(self.celebST.nickname)'s general consensus is \(String(format: "%.2f", consensus))%")
            })
        case 3: self.delegate!.socialSharing(message: "\(self.celebST.nickname)'s score yesterday was \(String(format: "%.2f", self.celebST.prevScore))")
        default: self.delegate!.socialSharing(message: "\(self.celebST.nickname)'s score yesterday was \(String(format: "%.2f", self.celebST.prevScore))")
        }
    }
    
    func updateGauge(gaugeView: LMGaugeView, timer: AIRTimer) {
        if gaugeView.value < gaugeView.maxValue { gaugeView.value += 0.05 }
        else { timer.invalidate() }
    }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        if value >= gaugeView.limitValue { return Constants.kLightGreenShade }
        else { return Constants.kWineShade }
    }
}