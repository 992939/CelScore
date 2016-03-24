//
//  SMAlphaImageSegment.swift
//  SMSegmentViewController
//
//  Created by mlaskowski on 01/10/15.
//  Copyright © 2015 si.ma. All rights reserved.
//

import Foundation
import UIKit


class SMAlphaImageSegment: SMBasicSegment {
    
    // UI Elements
    override var frame: CGRect { didSet { self.resetContentFrame() } }
    var margin: CGFloat = 5.0 { didSet { self.resetContentFrame() } }
    var vertical = false
    var animationDuration: NSTimeInterval = 0.5
    var selectedAlpha: CGFloat = 1.0
    var unselectedAlpha: CGFloat = 0.3
    var pressedAlpha: CGFloat = 0.65
    
    internal(set) var imageView: UIImageView = UIImageView()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(margin: CGFloat, selectedAlpha: CGFloat, unselectedAlpha: CGFloat, pressedAlpha: CGFloat, image: UIImage?) {
        
        self.margin = margin
        self.selectedAlpha = selectedAlpha
        self.unselectedAlpha = unselectedAlpha
        self.pressedAlpha = pressedAlpha
        self.imageView.image = image
        self.imageView.alpha = unselectedAlpha
        
        super.init(frame: CGRectZero)
        self.setupUIElements()
    }
    
    override func orientationChangedTo(mode: SegmentOrganiseMode) {
       self.vertical = mode == .SegmentOrganiseVertical
        //resetContentFrame(vertical)
    }
    
    func setupUIElements() {
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(self.imageView)
    }
    
    
    // MARK: Update Frame
    func resetContentFrame() {
        let margin = self.vertical ? (self.margin * 1.5) : self.margin;
        let imageViewFrame = CGRectMake(margin, margin, self.frame.size.width - margin*2, self.frame.size.height - margin*2)
        
        self.imageView.frame = imageViewFrame
        
    }
    
    // MARK: Selections
    override func setSelected(selected: Bool, inView view: SMBasicSegmentView) {
        super.setSelected(selected, inView: view)
        if selected { self.startAnimationToAlpha(self.selectedAlpha) }
        else { self.startAnimationToAlpha(self.unselectedAlpha) }
    }
    
    func startAnimationToAlpha(alpha: CGFloat){
        UIView.animateWithDuration(self.animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: { () -> Void in
            self.imageView.alpha = alpha
            }, completion: nil)
    }
    
    // MARK: Handle touch
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if self.isSelected == false {
            self.startAnimationToAlpha(self.pressedAlpha)
        }
    }
}