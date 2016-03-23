//
//  CosmosView.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/9/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit


final class CosmosView: UIView {
    
    //MARK: Properties
    var rating: Double = CosmosDefaultSettings.rating { didSet { if oldValue != rating { update() } } }
    var text: String? { didSet { if oldValue != text { update() } } }
    var settings = CosmosSettings() { didSet { update() } }
    var viewContentSize = CGSize()
    
    var didTouchCosmos: ((Double)->())?
    var didFinishTouchingCosmos: ((Double)->())?
    
    var widthOfStars: CGFloat {
        if let sublayers = self.layer.sublayers where settings.totalStars <= sublayers.count {
            let starLayers = Array(sublayers[0..<settings.totalStars])
            return CosmosSize.calculateSizeToFitLayers(starLayers).width
        }
        return 0
    }
    
    private var previousRatingForDidTouchCallback: Double = -123.192
    
    //MARK: Initializers
    convenience init() { self.init(frame: CGRect()) }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); improvePerformance() }
    override init(frame: CGRect) {
        super.init(frame: frame)
        update()
        self.frame.size = intrinsicContentSize()
        improvePerformance()
    }
    
    //MARK: Methods
    func update() {
        let layers = CosmosLayers.createStarLayers(rating, settings: settings)
        layer.sublayers = layers
        updateSize(layers)
    }
    
    private func improvePerformance() {
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        opaque = true
    }
    
    private func updateSize(layers: [CALayer]) {
        viewContentSize = CosmosSize.calculateSizeToFitLayers(layers)
        invalidateIntrinsicContentSize()
    }
    
    //MARK: Touch recognition
    func onDidTouch(locationX: CGFloat, starsWidth: CGFloat) {
        let calculatedTouchRating = CosmosTouch.touchRating(locationX, starsWidth: starsWidth, settings: settings)
        
        if settings.updateOnTouch { rating = calculatedTouchRating }
        
        if calculatedTouchRating == previousRatingForDidTouchCallback { return }
        
        didTouchCosmos?(calculatedTouchRating)
        previousRatingForDidTouchCallback = calculatedTouchRating
    }
    
    override func awakeFromNib() { super.awakeFromNib(); update() }
    override func intrinsicContentSize() -> CGSize { return viewContentSize }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if let touch = touches.first {
            let location = touch.locationInView(self).x
            onDidTouch(location, starsWidth: widthOfStars)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        if let touch = touches.first {
            let location = touch.locationInView(self).x
            onDidTouch(location, starsWidth: widthOfStars)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        didFinishTouchingCosmos?(rating)
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
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


