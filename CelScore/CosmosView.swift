//
//  CosmosView.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/9/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit


public class CosmosView: UIView {
    
    //MARK: Properties
    public var rating: Double = CosmosDefaultSettings.rating { didSet { if oldValue != rating { update() } } }
    public var text: String? { didSet { if oldValue != text { update() } } }
    public var settings = CosmosSettings() { didSet { update() } }
    public var viewContentSize = CGSize()
    
    //MARK: Initializers
    convenience public init() { self.init(frame: CGRect()) }
    required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); improvePerformance() }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        update()
        self.frame.size = intrinsicContentSize()
        
        improvePerformance()
    }
    
    //MARK: Methods
    public override func awakeFromNib() { super.awakeFromNib(); update() }
    
    private func improvePerformance() {
        /// Cache the view into a bitmap instead of redrawing the stars each time
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        opaque = true
    }

    public func update() {
        var layers = CosmosLayers.createStarLayers(rating, settings: settings)
        layer.sublayers = layers
        if let text = text {
            let textLayer = createTextLayer(text, layers: layers)
            layers.append(textLayer)
        }
        
        updateSize(layers)
    }
    
    private func createTextLayer(text: String, layers: [CALayer]) -> CALayer {
        let textLayer = CosmosLayerHelper.createTextLayer(text,
            font: settings.textFont, color: settings.textColor)
        
        let starsSize = CosmosSize.calculateSizeToFitLayers(layers)
        
        CosmosText.position(textLayer, starsSize: starsSize, textMargin: settings.textMargin)
        
        layer.addSublayer(textLayer)
        
        return textLayer
    }
    
    private func updateSize(layers: [CALayer]) {
        viewContentSize = CosmosSize.calculateSizeToFitLayers(layers)
        invalidateIntrinsicContentSize()
    }
    
    /// Returns the content size to fit all the star and text layers.
    override public func intrinsicContentSize() -> CGSize { return viewContentSize }
    
    //MARK: Touch recognition
    
    /// Closure will be called when user touches the cosmos view. The touch rating argument is passed to the closure.
    public var didTouchCosmos: ((Double)->())?
    
    /// Closure will be called when the user lifts finger from the cosmos view. The touch rating argument is passed to the closure.
    public var didFinishTouchingCosmos: ((Double)->())?
    
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if let touch = touches.first {
            let location = touch.locationInView(self).x
            onDidTouch(location, starsWidth: widthOfStars)
        }
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        if let touch = touches.first {
            let location = touch.locationInView(self).x
            onDidTouch(location, starsWidth: widthOfStars)
        }
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        didFinishTouchingCosmos?(rating)
    }
    
    func onDidTouch(locationX: CGFloat, starsWidth: CGFloat) {
        let calculatedTouchRating = CosmosTouch.touchRating(locationX, starsWidth: starsWidth,
            settings: settings)
        
        if settings.updateOnTouch {
            rating = calculatedTouchRating
        }
        
        if calculatedTouchRating == previousRatingForDidTouchCallback {
            // Do not call didTouchCosmos if rating has not changed
            return
        }
        
        didTouchCosmos?(calculatedTouchRating)
        previousRatingForDidTouchCallback = calculatedTouchRating
    }
    
    private var previousRatingForDidTouchCallback: Double = -123.192
    
    
    /// Width of the stars (excluding the text). Used for calculating touch location.
    var widthOfStars: CGFloat {
        if let sublayers = self.layer.sublayers where settings.totalStars <= sublayers.count {
            let starLayers = Array(sublayers[0..<settings.totalStars])
            return CosmosSize.calculateSizeToFitLayers(starLayers).width
        }
        
        return 0
    }
    
    /// Increase the hitsize of the view if it's less than 44px for easier touching.
    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let oprimizedBounds = CosmosTouchTarget.optimize(bounds)
        return oprimizedBounds.contains(point)
    }
}


//MARK: CosmosSize
final class CosmosSize {
    class func calculateSizeToFitLayers(layers: [CALayer]) -> CGSize {
        var size = CGSize()
        for layer in layers {
            if layer.frame.maxX > size.width { size.width = layer.frame.maxX }
            if layer.frame.maxY > size.height { size.height = layer.frame.maxY }
        }
        return size
    }
}

//MARK: CosmosText
final class CosmosText {
    class func position(layer: CALayer, starsSize: CGSize, textMargin: Double) {
        layer.position.x = starsSize.width + CGFloat(textMargin)
        let yOffset = (starsSize.height - layer.bounds.height) / 2
        layer.position.y = yOffset
    }
}

