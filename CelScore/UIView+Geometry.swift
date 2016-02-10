//
//  UIView+Geometry.swift
//  Geometry
//
//  Created by Tuomas Artman on 7.9.2014.
//  Copyright (c) 2014 Tuomas Artman. All rights reserved.
//

import Foundation
import UIKit


extension CGRect: StringLiteralConvertible {
    
    //MARK: Properties
    public var top: CGFloat {
        get { return origin.y }
        set(value) { origin.y = value }
    }
    
    public var left: CGFloat {
        get { return origin.x }
        set(value) { origin.x = value }
    }
    
    public var bottom: CGFloat {
        get { return origin.y + size.height }
        set(value) { origin.y = value - size.height }
    }
    
    public var right: CGFloat {
        get { return origin.x + size.width }
        set(value) { origin.x = value - size.width }
    }
    
    public var width: CGFloat {
        get { return size.width }
        set(value) { size.width = value }
    }
    
    public var height: CGFloat {
        get { return size.height }
        set(value) { size.height = value }
    }
    
    public var centerX: CGFloat {
        get { return origin.x + size.width / 2 }
        set (value) { origin.x = value - size.width / 2 }
    }
    
    public var centerY: CGFloat {
        get { return origin.y + size.height / 2 }
        set (value) { origin.y = value - size.height / 2 }
    }
    
    public var center: CGPoint {
        get { return CGPoint(x: centerX, y: centerY) }
        set (value) { centerX = value.x; centerY = value.y }
    }
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

    //MARK: Initializers
    public init(stringLiteral value: StringLiteralType) {
        self.init()
        let rect: CGRect
        if value[value.startIndex] != "{" {
            let comp = value.componentsSeparatedByString(",")
            if comp.count == 4 { rect = CGRectFromString("{{\(comp[0]),\(comp[1])}, {\(comp[2]), \(comp[3])}}") }
            else { rect = CGRectZero }
        } else {
            rect = CGRectFromString(value)
        }
        
        self.size = rect.size;
        self.origin = rect.origin;
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public typealias UnicodeScalarLiteralType = StringLiteralType

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
}

extension CGPoint: StringLiteralConvertible {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init()
        
        let point:CGPoint;
        if value[value.startIndex] != "{" {
            point = CGPointFromString("{\(value)}")
        } else {
            point = CGPointFromString(value)
        }
        self.x = point.x;
        self.y = point.y;
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public typealias UnicodeScalarLiteralType = StringLiteralType

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
}

extension UIView {
    
    //MARK: Properties
    public var top: CGFloat {
        get { return frame.top }
        set(value) {
            var frame = self.frame
            frame.top = value
            self.frame = frame
        }
    }
    
    public var left: CGFloat {
        get { return frame.left }
        set(value) {
            var frame = self.frame
            frame.left = value
            self.frame = frame
        }
    }
    
    public var bottom: CGFloat {
        get { return frame.bottom }
        set(value) {
            var frame = self.frame
            frame.bottom = value
            self.frame = frame
        }
    }
    
    public var right: CGFloat {
        get { return frame.right }
        set(value) {
            var frame = self.frame
            frame.right = value
            self.frame = frame
        }
    }
    
    public var width: CGFloat {
        get { return frame.width }
        set(value) {
            var frame = self.frame
            frame.width = value
            self.frame = frame
        }
    }
    
    public var height: CGFloat {
        get { return frame.height }
        set(value) {
            var frame = self.frame
            frame.height = value
            self.frame = frame
        }
    }
    
    public var centerX: CGFloat {
        get { return frame.centerX }
        set(value) {
            var frame = self.frame
            frame.centerX = value
            self.frame = frame
        }
    }
    
    public var centerY: CGFloat {
        get { return frame.centerY }
        set(value) {
            var frame = self.frame
            frame.centerY = value
            self.frame = frame
        }
    }
}
