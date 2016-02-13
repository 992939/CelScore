//
//  CosmosSettings.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/9/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit


public struct CosmosSettings {
    public var borderColorEmpty = CosmosDefaultSettings.borderColorEmpty
    public var borderWidthEmpty: Double = CosmosDefaultSettings.borderWidthEmpty
    public var colorEmpty = CosmosDefaultSettings.colorEmpty
    public var colorFilled = CosmosDefaultSettings.colorFilled
    public var fillMode = CosmosDefaultSettings.fillMode
    public var userRatingMode = CosmosDefaultSettings.userRatingMode
    public var previousRating = CosmosDefaultSettings.previousRating
    
    public var starMargin: Double = CosmosDefaultSettings.starMargin
    public var starPoints: [CGPoint] = CosmosDefaultSettings.starPoints
    public var starSize: Double = CosmosDefaultSettings.starSize
    public var totalStars = CosmosDefaultSettings.totalStars
    
    public var textColor = CosmosDefaultSettings.textColor
    public var textFont = CosmosDefaultSettings.textFont
    public var textMargin: Double = CosmosDefaultSettings.textMargin
    
    public var minTouchRating: Double = CosmosDefaultSettings.minTouchRating
    public var updateOnTouch = CosmosDefaultSettings.updateOnTouch
}

struct CosmosDefaultSettings {
    static let defaultColor = UIColor(red: 1, green: 149/255, blue: 0, alpha: 1)
    static let borderColorEmpty = defaultColor
    static let borderWidthEmpty: Double = 1 / Double(UIScreen.mainScreen().scale)
    static let colorEmpty = UIColor.clearColor()
    static let colorFilled = defaultColor
    static let fillMode = StarFillMode.Full
    static let userRatingMode = false
    static let previousRating = 3
    static let rating: Double = 2.718281828
    static let starMargin: Double = 5
    static let starPoints: [CGPoint] = [
        CGPoint(x: 49.5,  y: 0.0),
        CGPoint(x: 60.5,  y: 35.0),
        CGPoint(x: 99.0, y: 35.0),
        CGPoint(x: 67.5,  y: 58.0),
        CGPoint(x: 78.5,  y: 92.0),
        CGPoint(x: 49.5,    y: 71.0),
        CGPoint(x: 20.5,  y: 92.0),
        CGPoint(x: 31.5,  y: 58.0),
        CGPoint(x: 0.0,   y: 35.0),
        CGPoint(x: 38.5,  y: 35.0)
    ]
    static var starSize: Double = 20
    
    static let totalStars = 5
    
    static let textColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 1)
    static let textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    static let textMargin: Double = 5
    static var textSize: Double { get { return Double(textFont.pointSize) } }
    
    static let minTouchRating: Double = 1
    static let updateOnTouch = true
}
