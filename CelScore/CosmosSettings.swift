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
    public var userRatingMode = CosmosDefaultSettings.userRatingMode
    public var previousRating = CosmosDefaultSettings.previousRating
    public var starMargin: Double = CosmosDefaultSettings.starMargin
    public var starPoints: [CGPoint] = CosmosDefaultSettings.starPoints
    public var starSize: Double = CosmosDefaultSettings.starSize
    public var totalStars = CosmosDefaultSettings.totalStars
    public var minTouchRating: Double = CosmosDefaultSettings.minTouchRating
    public var updateOnTouch = CosmosDefaultSettings.updateOnTouch
}

struct CosmosDefaultSettings {
    static let defaultColor = UIColor.whiteColor()
    static let borderColorEmpty = defaultColor
    static let borderWidthEmpty: Double = 1 / Double(UIScreen.mainScreen().scale)
    static let colorEmpty = UIColor.clearColor()
    static let colorFilled = defaultColor
    static let userRatingMode = false
    static let previousRating = 3
    static let rating: Double = 2.718281828
    static let starMargin: Double = 2
    static let starPoints: [CGPoint] = [
        CGPoint(x: 49.5,  y: 0.0),
        CGPoint(x: 60.5,  y: 35.0),
        CGPoint(x: 99.0,  y: 35.0),
        CGPoint(x: 67.5,  y: 58.0),
        CGPoint(x: 78.5,  y: 92.0),
        CGPoint(x: 49.5,  y: 71.0),
        CGPoint(x: 20.5,  y: 92.0),
        CGPoint(x: 31.5,  y: 58.0),
        CGPoint(x: 0.0,   y: 35.0),
        CGPoint(x: 38.5,  y: 35.0)
    ]
    static var starSize: Double = 20
    static let totalStars = 5
    static let minTouchRating: Double = 1
    static let updateOnTouch = true
}

