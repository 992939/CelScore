//
//  CosmosLayers.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/9/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import Material


final class CosmosLayers {

    //MARK: Methods
    class func createStarLayers(_ rating: Double, settings: CosmosSettings) -> [CALayer] {
        var ratingRemander = CosmosRating.numberOfFilledStars(rating, totalNumberOfStars: settings.totalStars)
        var starLayers = [CALayer]()

        for index in (0..<settings.totalStars) {
            let fillLevel = CosmosRating.starFillLevel(ratingRemainder: ratingRemander)
            let starLayer = createCompositeStarLayer(fillLevel, settings: settings, index: index)
            starLayers.append(starLayer)
            ratingRemander -= 1
        }
        positionStarLayers(starLayers, starMargin: settings.starMargin)
        return starLayers
    }
    
    //MARK: Private Methods
    fileprivate class func createCompositeStarLayer(_ starFillLevel: Double, settings: CosmosSettings, index: Int) -> CALayer {
        if starFillLevel >= 1 { return createStarLayer(true, settings: settings, index: index) }
        if starFillLevel == 0 { return createStarLayer(false, settings: settings, index: index) }
        return createPartialStar(starFillLevel, settings: settings, index: index)
    }

    fileprivate class func createPartialStar(_ starFillLevel: Double, settings: CosmosSettings, index: Int) -> CALayer {
        let filledStar = createStarLayer(true, settings: settings, index: index)
        let emptyStar = createStarLayer(false, settings: settings, index: index)
        
        let parentLayer = CALayer()
        parentLayer.contentsScale = UIScreen.main.scale
        parentLayer.bounds = CGRect(origin: CGPoint(), size: filledStar.bounds.size)
        parentLayer.anchorPoint = CGPoint()
        parentLayer.addSublayer(emptyStar)
        parentLayer.addSublayer(filledStar)
        
        filledStar.bounds.size.width *= CGFloat(starFillLevel)
        return parentLayer
    }
    
    fileprivate class func positionStarLayers(_ layers: [CALayer], starMargin: Double) {
        var positionX:CGFloat = 0
        for layer in layers {
            layer.position.x = positionX
            positionX += layer.bounds.width + CGFloat(starMargin)
        }
    }
    
    fileprivate class func createStarLayer(_ isFilled: Bool, settings: CosmosSettings, index: Int) -> CALayer {
        var colorFilled = settings.colorFilled
        
        if (settings.userRatingMode) {
            if index >= settings.previousRating { colorFilled = Constants.kBlueShade }
            else { colorFilled =  Constants.kRedShade }
        }

        let fillColor = isFilled ? colorFilled : settings.colorEmpty
        let strokeColor = isFilled ? colorFilled : settings.borderColorEmpty
        
        return StarLayer.create(settings.starPoints,
            size: settings.starSize,
            lineWidth: settings.borderWidthEmpty,
            fillColor: fillColor,
            strokeColor: strokeColor)
    }
}
