//
//  CelScoreViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/1/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import LMGaugeView
import AIRTimer


final class CelScoreViewController: ASViewController, LMGaugeViewDelegate {
    
    //MARK: Properties
    let gaugeView: LMGaugeView
    var velocity: CGFloat = 0.0
    var acceleration: CGFloat = 5.0
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init(celebrityST: CelebrityStruct) {
        self.gaugeView = LMGaugeView()
        super.init(node: ASDisplayNode())
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gaugeView.minValue = 0
        self.gaugeView.maxValue = 120
        self.gaugeView.limitValue = 50
        
        self.view.addSubview(self.gaugeView)
        AIRTimer.every(1/24) { timer in self.updateGauge(self.gaugeView) }
    }
    
    func updateGauge(gaugeView: LMGaugeView) {
        velocity += 0.05 * acceleration
        if (velocity > gaugeView.maxValue) { velocity = gaugeView.maxValue; acceleration = -5 }
        if (velocity < gaugeView.minValue) { velocity = gaugeView.minValue; acceleration = 5 }
        gaugeView.value = velocity;
    }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        if value >= gaugeView.limitValue { return Constants.kMainGreenColor }
        else { return Constants.kMainVioletColor }
    }
}





