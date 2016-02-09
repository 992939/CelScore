//
//  CosmosLayers.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/9/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit


final class CosmosLayers {

    //MARK: Methods
    class func createStarLayers(rating: Double, settings: CosmosSettings) -> [CALayer] {
        var ratingRemander = CosmosRating.numberOfFilledStars(rating, totalNumberOfStars: settings.totalStars)
        
        var starLayers = [CALayer]()
        
        for _ in (0..<settings.totalStars) {
            let fillLevel = CosmosRating.starFillLevel(ratingRemainder: ratingRemander, fillMode: settings.fillMode)
            let starLayer = createCompositeStarLayer(fillLevel, settings: settings)
            starLayers.append(starLayer)
            ratingRemander--
        }
        positionStarLayers(starLayers, starMargin: settings.starMargin)
        return starLayers
    }
    
    class func createCompositeStarLayer(starFillLevel: Double, settings: CosmosSettings) -> CALayer {
        if starFillLevel >= 1 { return createStarLayer(true, settings: settings) }
        if starFillLevel == 0 { return createStarLayer(false, settings: settings) }
        return createPartialStar(starFillLevel, settings: settings)
    }

    class func createPartialStar(starFillLevel: Double, settings: CosmosSettings) -> CALayer {
        let filledStar = createStarLayer(true, settings: settings)
        let emptyStar = createStarLayer(false, settings: settings)
        
        let parentLayer = CALayer()
        parentLayer.contentsScale = UIScreen.mainScreen().scale
        parentLayer.bounds = CGRect(origin: CGPoint(), size: filledStar.bounds.size)
        parentLayer.anchorPoint = CGPoint()
        parentLayer.addSublayer(emptyStar)
        parentLayer.addSublayer(filledStar)
        
        // make filled layer width smaller according to the fill level.
        filledStar.bounds.size.width *= CGFloat(starFillLevel)
        
        return parentLayer
    }
    
    class func positionStarLayers(layers: [CALayer], starMargin: Double) {
        var positionX:CGFloat = 0
        for layer in layers {
            layer.position.x = positionX
            positionX += layer.bounds.width + CGFloat(starMargin)
        }
    }
    
    //MARK: Private Method
    private class func createStarLayer(isFilled: Bool, settings: CosmosSettings) -> CALayer {
        let fillColor = isFilled ? settings.colorFilled : settings.colorEmpty
        let strokeColor = isFilled ? settings.colorFilled : settings.borderColorEmpty
        
        return StarLayer.create(settings.starPoints,
            size: settings.starSize,
            lineWidth: settings.borderWidthEmpty,
            fillColor: fillColor,
            strokeColor: strokeColor)
    }
}


//MARK: CosmosLayerHelper
final class CosmosLayerHelper {
    class func createTextLayer(text: String, font: UIFont, color: UIColor) -> CATextLayer {
        let size = NSString(string: text).sizeWithAttributes([NSFontAttributeName: font])
        let layer = CATextLayer()
        layer.bounds = CGRect(origin: CGPoint(), size: size)
        layer.anchorPoint = CGPoint()
        layer.string = text
        layer.font = CGFontCreateWithFontName(font.fontName)
        layer.fontSize = font.pointSize
        layer.foregroundColor = color.CGColor
        layer.contentsScale = UIScreen.mainScreen().scale
        return layer
    }
}