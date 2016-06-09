//
//  CosmosSettings.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/9/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit


struct CosmosSettings {
    var borderColorEmpty = CosmosDefaultSettings.borderColorEmpty
    var borderWidthEmpty: Double = CosmosDefaultSettings.borderWidthEmpty
    var colorEmpty = CosmosDefaultSettings.colorEmpty
    var colorFilled = CosmosDefaultSettings.colorFilled
    var userRatingMode = CosmosDefaultSettings.userRatingMode
    var previousRating = CosmosDefaultSettings.previousRating
    var starMargin: Double = CosmosDefaultSettings.starMargin
    var starPoints: [CGPoint] = CosmosDefaultSettings.starPoints
    var starSize: Double = CosmosDefaultSettings.starSize
    var totalStars = CosmosDefaultSettings.totalStars
    var minTouchRating: Double = CosmosDefaultSettings.minTouchRating
    var updateOnTouch = CosmosDefaultSettings.updateOnTouch
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

