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
    var settings = CosmosSettings() { didSet { update() } }
    var viewContentSize = CGSize()
    var didTouchCosmos: ((Double)->())?
    var didFinishTouchingCosmos: ((Double)->())?
    private var previousRatingForDidTouchCallback: Double = -123.192
    private var widthOfStars: CGFloat {
        if let sublayers = self.layer.sublayers where settings.totalStars <= sublayers.count {
            let starLayers = Array(sublayers[0..<settings.totalStars])
            return calculateSizeToFitLayers(starLayers).width
        }
        return 0
    }
    
    //MARK: Initializers
    required init?(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    convenience init() { self.init(frame: CGRect()) }
    override init(frame: CGRect) {
        super.init(frame: frame)
        update()
        improvePerformance()
    }
    
    //MARK: Methods
    func update() {
        let layers = CosmosLayers.createStarLayers(rating, settings: settings)
        self.layer.sublayers = layers
        updateSize(layers)
    }
    
    private func improvePerformance() {
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.opaque = true
    }
    
    private func updateSize(layers: [CALayer]) {
        viewContentSize = calculateSizeToFitLayers(layers)
        invalidateIntrinsicContentSize()
    }
    
    private func calculateSizeToFitLayers(layers: [CALayer]) -> CGSize {
        var size = CGSize()
        for layer in layers {
            if layer.frame.maxX > size.width { size.width = layer.frame.maxX }
            if layer.frame.maxY > size.height { size.height = layer.frame.maxY }
        }
        return size
    }
    
    //MARK: Touch recognition
    func onDidTouch(locationX: CGFloat, starsWidth: CGFloat) {
        let calculatedTouchRating = CosmosTouch.touchRating(locationX, starsWidth: starsWidth, settings: settings)
        if settings.updateOnTouch { rating = calculatedTouchRating }
        if calculatedTouchRating == previousRatingForDidTouchCallback { return }
        didTouchCosmos?(calculatedTouchRating)
        previousRatingForDidTouchCallback = calculatedTouchRating
    }
    
    override func intrinsicContentSize() -> CGSize { return viewContentSize }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if let touch = touches.first {
            let location = touch.locationInView(self).x
            self.onDidTouch(location, starsWidth: widthOfStars)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        if let touch = touches.first {
            let location = touch.locationInView(self).x
            self.onDidTouch(location, starsWidth: widthOfStars)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        didFinishTouchingCosmos?(rating)
    }
}
