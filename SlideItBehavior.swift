//
//  SlideItBehavior.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/16/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit

class SlideItBehavior: UIDynamicBehavior {

    //MARK: Properties
    let gravity = UIGravityBehavior()
    let collider = UICollisionBehavior()
    
    override init() {
        super.init()
        self.gravity.gravityDirection = CGVector(dx: 0.7, dy: 0.0)
        self.collider.addBoundaryWithIdentifier("barrier",
            fromPoint: CGPoint(x: Constants.kDetailWidth, y: 0),
            toPoint: CGPoint(x: Constants.kDetailWidth, y: Constants.kScreenHeight))
        addChildBehavior(gravity)
        addChildBehavior(collider)
    }
    
    func addSlide(slide: UIView) {
        dynamicAnimator?.referenceView?.addSubview(slide)
        gravity.addItem(slide)
        collider.addItem(slide)
    }
    
    func removeSlide(slide: UIView) {
        gravity.removeItem(slide)
        collider.removeItem(slide)
        slide.removeFromSuperview()
    }
}
