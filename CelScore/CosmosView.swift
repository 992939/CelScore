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
    fileprivate var previousRatingForDidTouchCallback: Double = -123.192
    fileprivate var widthOfStars: CGFloat {
        if let sublayers = self.layer.sublayers , settings.totalStars <= sublayers.count {
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
    
    fileprivate func improvePerformance() {
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.isOpaque = true
    }
    
    fileprivate func updateSize(_ layers: [CALayer]) {
        viewContentSize = calculateSizeToFitLayers(layers)
        invalidateIntrinsicContentSize()
    }
    
    fileprivate func calculateSizeToFitLayers(_ layers: [CALayer]) -> CGSize {
        var size = CGSize()
        for layer in layers {
            if layer.frame.maxX > size.width { size.width = layer.frame.maxX }
            if layer.frame.maxY > size.height { size.height = layer.frame.maxY }
        }
        return size
    }
    
    //MARK: Touch recognition
    func onDidTouch(_ locationX: CGFloat, starsWidth: CGFloat) {
        let calculatedTouchRating = CosmosTouch.touchRating(locationX, starsWidth: starsWidth, settings: settings)
        if settings.updateOnTouch { rating = calculatedTouchRating }
        if calculatedTouchRating == previousRatingForDidTouchCallback { return }
        didTouchCosmos?(calculatedTouchRating)
        previousRatingForDidTouchCallback = calculatedTouchRating
    }
    
    override var intrinsicContentSize : CGSize { return viewContentSize }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: self).x
            self.onDidTouch(location, starsWidth: widthOfStars)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: self).x
            self.onDidTouch(location, starsWidth: widthOfStars)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        didFinishTouchingCosmos?(rating)
    }
}
