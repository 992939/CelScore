//
//  SMBasicSegment.swift
//  SMSegmentViewController
//
//  Created by mlaskowski on 01/10/15.
//  Copyright © 2015 si.ma. All rights reserved.
//

import Foundation
import UIKit


class SMBasicSegment : UIView {
    internal(set) var index: Int = 0
    internal(set) weak var segmentView: SMBasicSegmentView?
    private(set) var isSelected: Bool = false
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(frame: CGRect) { super.init(frame: frame) }
    
    // MARK: Selections
    internal func setSelected(selected: Bool, inView view: SMBasicSegmentView) {
        self.isSelected = selected
    }
    
    func orientationChangedTo(mode: SegmentOrganiseMode){}
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if self.isSelected == false{
            self.segmentView?.selectSegmentAtIndex(self.index)
        }
    }
}