//
//  SMSegmentView.swift
//
//  Created by Si MA on 03/01/2015.
//  Copyright (c) 2015 Si Ma. All rights reserved.
//

import UIKit


let keyContentVerticalMargin = "VerticalMargin"
let keySegmentOnSelectionColour = "OnSelectionBackgroundColour"
let keySegmentOffSelectionColour = "OffSelectionBackgroundColour"
let keySegmentOnSelectionTextColour = "OnSelectionTextColour"
let keySegmentOffSelectionTextColour = "OffSelectionTextColour"
let keySegmentTitleFont = "TitleFont"



class SMSegmentView: SMBasicSegmentView {
    
    var segmentVerticalMargin: CGFloat = 5.0 {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.verticalMargin = self.segmentVerticalMargin
            }
        }
    }
    
   
    // Segment Colour
    var segmentOnSelectionColour: UIColor = UIColor.darkGray {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.onSelectionColour = self.segmentOnSelectionColour
            }
        }
    }
    var segmentOffSelectionColour: UIColor = UIColor.white {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.offSelectionColour = self.segmentOffSelectionColour
            }
        }
    }
    
    // Segment Title Text Colour & Font
    var segmentOnSelectionTextColour: UIColor = UIColor.white {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.onSelectionTextColour = self.segmentOnSelectionTextColour
            }
        }
    }
    var segmentOffSelectionTextColour: UIColor = UIColor.darkGray {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.offSelectionTextColour = self.segmentOffSelectionTextColour
            }
        }
    }
    var segmentTitleFont: UIFont = UIFont.systemFont(ofSize: 17.0) {
        didSet {
            for segment in self.segments as! [SMSegment] {
                segment.titleFont = self.segmentTitleFont
            }
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true
    }
    
    init(frame: CGRect, separatorColour: UIColor, separatorWidth: CGFloat, segmentProperties: Dictionary<String, AnyObject>?) {
        
        super.init(frame: frame)
        
        self.separatorColour = separatorColour
        self.separatorWidth = separatorWidth
        
        if let margin = segmentProperties?[keyContentVerticalMargin] as? Float {
            self.segmentVerticalMargin = CGFloat(margin)
        }
        
        if let onSelectionColour = segmentProperties?[keySegmentOnSelectionColour] as? UIColor {
            self.segmentOnSelectionColour = onSelectionColour
        }
        else {
            self.segmentOnSelectionColour = UIColor.darkGray
        }
        
        if let offSelectionColour = segmentProperties?[keySegmentOffSelectionColour] as? UIColor {
            self.segmentOffSelectionColour = offSelectionColour
        }
        else {
            self.segmentOffSelectionColour = UIColor.white
        }
        
        if let onSelectionTextColour = segmentProperties?[keySegmentOnSelectionTextColour] as? UIColor {
            self.segmentOnSelectionTextColour = onSelectionTextColour
        }
        else {
            self.segmentOnSelectionTextColour = UIColor.white
        }
        
        if let offSelectionTextColour = segmentProperties?[keySegmentOffSelectionTextColour] as? UIColor {
            self.segmentOffSelectionTextColour = offSelectionTextColour
        }
        else {
            self.segmentOffSelectionTextColour = UIColor.darkGray
        }
        
        if let titleFont = segmentProperties?[keySegmentTitleFont] as? UIFont {
            self.segmentTitleFont = titleFont
        }
        else {
            self.segmentTitleFont = UIFont.systemFont(ofSize: 17.0)
        }
        
        self.backgroundColor = UIColor.clear
        self.layer.masksToBounds = true
    }
    
    func addSegmentWithTitle(_ title: String?, onSelectionImage: UIImage?, offSelectionImage: UIImage?) -> SMSegment {
        
        let segment = SMSegment(verticalMargin: self.segmentVerticalMargin, onSelectionColour: self.segmentOnSelectionColour, offSelectionColour: self.segmentOffSelectionColour, onSelectionTextColour: self.segmentOnSelectionTextColour, offSelectionTextColour: self.segmentOffSelectionTextColour, titleFont: self.segmentTitleFont)
        
        segment.title = title
        segment.onSelectionImage = onSelectionImage
        segment.offSelectionImage = offSelectionImage
        
        super.addSegment(segment)
        
        return segment
    }
    
}
