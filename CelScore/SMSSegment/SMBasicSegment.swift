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
    fileprivate(set) var isSelected: Bool = false
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(frame: CGRect) { super.init(frame: frame) }
    
    // MARK: Selections
    internal func setSelected(_ selected: Bool, inView view: SMBasicSegmentView) {
        self.isSelected = selected
    }
    
    func orientationChangedTo(_ mode: SegmentOrganiseMode){}
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if self.isSelected == false{
            self.segmentView?.selectSegmentAtIndex(self.index)
        }
    }
}
