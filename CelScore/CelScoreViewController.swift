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
    let pulseView: MaterialPulseView
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.celebST = celebrityST
        self.pulseView = MaterialPulseView(frame: Constants.bottomViewRect)
        super.init(node: ASDisplayNode())
        self.view.tag = Constants.kDetailViewTag
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let maxHeight = self.pulseView.height - 2 * Constants.kCellPadding
        let maxWidth = self.pulseView.width - 2 * Constants.kCellPadding
        
        let gaugeView = LMGaugeView()
        gaugeView.minValue = Constants.kMinimumVoteValue
        gaugeView.maxValue = Constants.kMaximumVoteValue
        gaugeView.limitValue = Constants.kMiddleVoteValue
        let gaugeWidth: CGFloat = 0.75 * maxHeight
        gaugeView.frame = CGRect(x: (maxWidth - gaugeWidth)/2, y: 20, width: gaugeWidth, height: gaugeWidth)
        gaugeView.delegate = self
        AIRTimer.every(0.1){ timer in self.updateGauge(gaugeView, timer: timer) }
        
        let consensusLabel = UILabel()
        consensusLabel.text = "Social Consensus: 80%"
        consensusLabel.font = UIFont(name: consensusLabel.font.fontName, size: 15)
        consensusLabel.frame = CGRect(x: Constants.kCellPadding, y: maxHeight - 30, width: maxWidth, height: 30)
        consensusLabel.textAlignment = .Center
        consensusLabel.textColor = MaterialColor.black
        
        self.pulseView.depth = .Depth2
        self.pulseView.backgroundColor = MaterialColor.white
        self.pulseView.addSubview(gaugeView)
        self.pulseView.addSubview(consensusLabel)
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