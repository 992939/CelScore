//
//  CelScoreViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/8/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material
import LMGaugeView
import AIRTimer


final class CelScoreViewController: ASViewController, LMGaugeViewDelegate {
    
    //MARK: Properties
    let celebST: CelebrityStruct
    let pulseView: MaterialView
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.pulseView = MaterialView(frame: Constants.kBottomViewRect)
        super.init(node: ASDisplayNode())
        self.view.tag = Constants.kDetailViewTag
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gauge = LMGaugeView()
        gauge.minValue = Constants.kMinimumVoteValue
        gauge.maxValue = Constants.kMaximumVoteValue
        gauge.limitValue = Constants.kMiddleVoteValue
        let gaugeWidth: CGFloat = 0.80 * Constants.kBottomWidth
        gauge.frame = CGRect(x: (Constants.kBottomWidth - gaugeWidth)/2, y: 1.5 * Constants.kPadding, width: gaugeWidth, height: gaugeWidth)
        gauge.delegate = self
        AIRTimer.every(0.1){ timer in self.updateGauge(gauge, timer: timer) }
        
        let gaugeView = MaterialPulseView(frame: CGRect(x: Constants.kPadding, y: Constants.kPadding, width: Constants.kBottomWidth, height: gaugeWidth + 3 * Constants.kPadding))
        gaugeView.depth = .Depth1
        gaugeView.backgroundColor = MaterialColor.white
        gaugeView.pulseScale = false
        gaugeView.addSubview(gauge)
        
        let consensusLabel = UILabel()
        consensusLabel.text = "Social Consensus"
        consensusLabel.frame = CGRect(x: Constants.kPadding, y: 3, width: 160, height: 25)
        
        let infoLabel = UILabel()
        infoLabel.text = "80%"
        infoLabel.frame = CGRect(x: consensusLabel.width, y: 3, width: Constants.kBottomWidth - (consensusLabel.width + Constants.kPadding), height: 25)
        infoLabel.textAlignment = .Right
        
        let consensusView = MaterialPulseView(frame: CGRect(x: Constants.kPadding, y: gaugeView.bottom + Constants.kPadding, width: Constants.kBottomWidth, height: 30))
        consensusView.depth = .Depth1
        consensusView.backgroundColor = MaterialColor.white
        consensusView.pulseScale = false
        consensusView.addSubview(consensusLabel)
        consensusView.addSubview(infoLabel)
        
        self.pulseView.depth = .Depth1
        self.pulseView.backgroundColor = MaterialColor.clear
        self.pulseView.addSubview(gaugeView)
        self.pulseView.addSubview(consensusView)
        self.view = self.pulseView
    }
    
    func updateGauge(gaugeView: LMGaugeView, timer: AIRTimer) {
        if gaugeView.value < gaugeView.maxValue { gaugeView.value += 0.05 }
        else { timer.invalidate() }
    }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        if value > gaugeView.limitValue { return MaterialColor.green.darken3 }
        else { return MaterialColor.green.lighten1 }
    }
}