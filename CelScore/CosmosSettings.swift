//
//  CosmosSettings.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/9/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit


public struct CosmosSettings {
    init() {}
    
    public var borderColorEmpty = CosmosDefaultSettings.borderColorEmpty
    public var borderWidthEmpty: Double = CosmosDefaultSettings.borderWidthEmpty
    public var colorEmpty = CosmosDefaultSettings.colorEmpty
    public var colorFilled = CosmosDefaultSettings.colorFilled
    public var fillMode = CosmosDefaultSettings.fillMode
    
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

