//
//  CelScoreNode.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/26/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import LMGaugeView
import AIRTimer


final class CelScoreNode: ASCellNode, LMGaugeViewDelegate {
    
    //MARK: Properties
    let gaugeNode: ASDisplayNode
    var velocity: CGFloat = 0.0
    var acceleration: CGFloat = 5.0
    
    //MARK: Initializer
    init(celebrityST: CelebrityStruct) {
        
        let gaugeView = LMGaugeView()
        gaugeView.minValue = 0
        gaugeView.maxValue = 5
        gaugeView.limitValue = 2.5
        self.gaugeNode = ASDisplayNode(viewBlock: { () -> UIView in return gaugeView })
        
        super.init()
        
//        RatingsViewModel(celebrityId: celebrityST.id).getCelScoreSignal()
//            .on(next: { score in
//                
//            })
//            .start()
        
        AIRTimer.every(0.05) { timer in
            print("hey \(timer)")
            self.updateGauge(gaugeView) }
        
        self.addSubnode(self.gaugeNode)
    }
    
    //MARK: Methods
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsetsMake(Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding, Constants.kCellPadding),
            child: ASStackLayoutSpec()),
            background: nil)
    }
    
    func updateGauge(gaugeView: LMGaugeView) {
        velocity += 0.05 * acceleration
        if (velocity > gaugeView.maxValue) {
            velocity = gaugeView.maxValue
            acceleration = -5
        }
        if (velocity < gaugeView.minValue) {
            velocity = gaugeView.minValue
            acceleration = 5
        }
        gaugeView.value = velocity;
    }
    
    //MARK: LMGaugeViewDelegate
    func gaugeView(gaugeView: LMGaugeView!, ringStokeColorForValue value: CGFloat) -> UIColor! {
        if value >= gaugeView.limitValue { return Constants.kMainGreenColor }
        else { return Constants.kMainVioletColor }
    }
}