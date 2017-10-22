//
//  celebrityTableNodeCell.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 5/23/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import Material
import BEMCheckBox
import ReactiveCocoa
import ReactiveSwift
import Result
import NotificationCenter


final class celebrityTableNodeCell: ASCellNode, BEMCheckBoxDelegate {
    
    //MARK: Properties
    fileprivate let ratingsNode: ASDisplayNode
    fileprivate let switchNode: ASDisplayNode
    fileprivate let backgroundNode: ASDisplayNode
    internal let nameNode: ASTextNode
    internal let trendNode: ASImageNode
    internal let averageNode: ASImageNode
    internal let newsNode: ASImageNode
    internal let rankNode: ASImageNode
    internal let graphNode: ASImageNode
    internal let rankTextNode: ASTextNode
    internal let pastNode: ASImageNode
    internal let pastTextNode: ASTextNode
    internal let consensusNode: ASImageNode
    internal let wreathNode: ASImageNode
    internal let wreathTextNode: ASTextNode
    internal let faceNode: ASImageNode
    internal let profilePicNode: ASNetworkImageNode
    internal let id: String
    
    //MARK: Initializer
    init(celebrity: CelebrityModel) {
        self.id = celebrity.id
        self.nameNode = ASTextNode()
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.pointSizeScaleFactors = [0.95, 0.9]
        self.nameNode.truncationMode = .byTruncatingTail
        self.nameNode.isLayerBacked = true
    
        self.profilePicNode = ASNetworkImageNode()
        //self.profilePicNode.url = URL(string: self.celebST.imageURL)
        self.profilePicNode.defaultImage = R.image.jamie_blue()!
        //self.profilePicNode.defaultImage = R.image.uncle_sam()!
        self.profilePicNode.contentMode = .scaleAspectFill
        self.profilePicNode.style.preferredSize = CGSize(width: UIDevice.getRowHeight(), height: UIDevice.getRowHeight())
        
        let cosmosView: CosmosView = CosmosView()
        cosmosView.settings.starSize = UIDevice.getStarsSize()
        cosmosView.settings.starMargin = 1
        cosmosView.settings.borderColorEmpty = Constants.kStarGreyShade
        cosmosView.settings.updateOnTouch = false
        self.ratingsNode = ASDisplayNode(viewBlock: { () -> UIView in return cosmosView })
        self.ratingsNode.style.preferredSize = CGSize(width: 10, height: 20)
        self.ratingsNode.backgroundColor = UIColor.clear
        
        let box: BEMCheckBox = BEMCheckBox(frame: CGRect(x: 80, y: 30, width: UIDevice.getPastSize() - 5, height: UIDevice.getPastSize() - 5))
        box.onAnimationType = .bounce
        box.offAnimationType = .bounce
        box.onCheckColor = Color.white
        box.onFillColor = Constants.kRedShade
        box.onTintColor = Constants.kRedShade
        box.tintColor = Constants.kRedShade
        box.lineWidth = 2.5
        box.setOn(celebrity.isFollowed, animated: true)
        self.switchNode = ASDisplayNode(viewBlock: { () -> UIView in return box })
        self.switchNode.style.preferredSize = box.frame.size
        
        self.wreathNode = ASImageNode()
        self.wreathNode.style.preferredSize = CGSize(width: UIDevice.getPastSize() + 4, height: UIDevice.getPastSize() + 4)
        self.wreathNode.image = R.image.blue_wreath()!
        self.wreathNode.isLayerBacked = true
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let rankFont = R.font.droidSerifBold(size: UIDevice.getFontSize())!
        
        let attr = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: UIDevice.getFontSize() + 1),
                    NSForegroundColorAttributeName : Color.black]
        
        let attr2 = [NSFontAttributeName: rankFont,
                     NSForegroundColorAttributeName : Constants.kBlueShade,
                     NSParagraphStyleAttributeName: style]
        
        let attr3 = [NSFontAttributeName: rankFont,
                     NSForegroundColorAttributeName : Constants.kRedShade,
                     NSParagraphStyleAttributeName: style]
    
        self.rankTextNode = ASTextNode()
        self.rankTextNode.attributedText = NSAttributedString(string: "\(self.celebST.index)", attributes: attr2)
        self.rankTextNode.style.preferredSize = CGSize(width: UIDevice.getRankingSize(), height: UIDevice.getRankingSize())
        self.rankTextNode.isLayerBacked = true
        
        self.wreathTextNode = ASTextNode()
        self.wreathTextNode.style.preferredSize = self.wreathNode.style.preferredSize
        self.wreathTextNode.isLayerBacked = true
        
        self.pastTextNode = ASTextNode()
        self.pastTextNode.attributedText = NSAttributedString(string: "\(self.celebST.y_index)", attributes: attr3)
        self.pastTextNode.style.preferredSize = CGSize(width: UIDevice.getRankingSize(), height: UIDevice.getRankingSize())
        self.pastTextNode.isLayerBacked = true
        
        self.rankNode = ASImageNode()
        self.rankNode.style.preferredSize = CGSize(width: UIDevice.getPastSize(), height: UIDevice.getPastSize())
        self.rankNode.image = R.image.thin_circle()!
        self.wreathTextNode.isLayerBacked = true
        
        self.pastNode = ASImageNode()
        self.pastNode.style.preferredSize = CGSize(width: UIDevice.getPastSize(), height: UIDevice.getPastSize())
        self.pastNode.image = R.image.thin_red()!
        self.pastNode.isLayerBacked = true
        
        self.trendNode = ASImageNode()
        self.trendNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle(), height: UIDevice.getMiniCircle())
        self.trendNode.isLayerBacked = true
        
        self.newsNode = ASImageNode()
        self.newsNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle(), height: UIDevice.getMiniCircle())
        self.newsNode.image = self.celebST.isTrending ? R.image.bell_red()! : R.image.bell_blue()!
        self.newsNode.isLayerBacked = true
        
        self.consensusNode = ASImageNode()
        self.consensusNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle(), height: UIDevice.getMiniCircle())
        self.consensusNode.isLayerBacked = true
        
        self.faceNode = ASImageNode()
        self.faceNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle(), height: UIDevice.getMiniCircle())
        self.faceNode.isLayerBacked = true
        
        self.averageNode = ASImageNode()
        self.averageNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle(), height: UIDevice.getMiniCircle())
        self.averageNode.isLayerBacked = true
        
        self.graphNode = ASImageNode()
        self.graphNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle() * 2.4, height: UIDevice.getMiniCircle() * 2.4)
        self.graphNode.image = BarTrend(rawValue: celebrity.trend)?.icon()
        self.graphNode.isLayerBacked = true
        
        let cardView: PulseView = PulseView()
        cardView.borderWidth = 2.0
        cardView.borderColor = Constants.kBlueShade
        self.backgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return cardView })
        self.backgroundNode.layer.cornerRadius = Constants.kCornerRadius
        self.backgroundNode.backgroundColor = Constants.kGreyBackground
        
        super.init()
        self.selectionStyle = .none
        box.delegate = self
        
        self.wreathTextNode.attributedText = NSAttributedString(string: "\(String(describing: self.celebST.getDaysOnThrone()))", attributes: attr2)
        self.nameNode.attributedText = NSMutableAttributedString(string: "\(self.celebST.getCelebName())", attributes: attr)
        
        RatingsViewModel().getCelScoreSignal(ratingsId: celebrity.id)
            .on(value: { score in
                cosmosView.rating = score/20
                self.trendNode.image = score >= celebrity.prevScore ? R.image.arrow_up()! : R.image.arrow_down()!
                self.consensusNode.image = score >= Constants.kRoyalty ? R.image.mini_crown_blue()! : R.image.mini_crown_red()!
                if celebrity.y_index == 1 && celebrity.index != 1  { self.consensusNode.image = R.image.mini_death()! }
                else if celebrity.index == 1 { self.consensusNode.image = celebrity.sex ? R.image.king_mini()! : R.image.queen_mini()! }
            })
            .flatMap(.latest) { (_) -> SignalProducer<Int, NoError> in
                return CelebrityViewModel().countCelebritiesSignal() }
            .on(value: { count in
                self.averageNode.image = celebrity.index < (count/2) ? R.image.half_circle_blue()! : R.image.half_circle_red()! })
            .flatMap(.latest) { (_) -> SignalProducer<RatingsModel, RatingsError> in
                return RatingsViewModel().getRatingsSignal(ratingsId: celebrity.id, ratingType: .userRatings) }
            .on(failed: { _ in
                self.faceNode.image = R.image.mini_empty()!
                cosmosView.settings.colorFilled = Constants.kStarGreyShade })
            .on(value: { ratings in
                cosmosView.settings.colorFilled = Constants.kStarGoldShade
                switch ratings.getCelScore() {
                case 90..<101: self.faceNode.image = R.image.mini_happy()!
                case 75..<90: self.faceNode.image = R.image.mini_smile()!
                case 60..<75: self.faceNode.image = R.image.mini_nosmile()!
                case 40..<60: self.faceNode.image = R.image.mini_sadFace()!
                case 20..<40: self.faceNode.image = R.image.mini_angry()!
                default: self.faceNode.image = R.image.mini_empty()!
                } })
            .start()
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.rankNode)
        self.addSubnode(self.rankTextNode)
        self.addSubnode(self.profilePicNode)
        self.addSubnode(self.nameNode)
        self.addSubnode(self.pastNode)
        self.addSubnode(self.pastTextNode)
        self.addSubnode(self.ratingsNode)
        self.addSubnode(self.switchNode)
        self.addSubnode(self.trendNode)
        self.addSubnode(self.averageNode)
        self.addSubnode(self.wreathNode)
        self.addSubnode(self.graphNode)
        self.addSubnode(self.wreathTextNode)
        self.addSubnode(self.newsNode)
        self.addSubnode(self.consensusNode)
        self.addSubnode(self.faceNode)
    }
    
    //MARK: Methods
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.profilePicNode.style.flexBasis = ASDimensionMake(.points, UIDevice.getRowHeight())
        
        let minisStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: UIDevice.getBubbleSpace(),
            justifyContent: .start,
            alignItems: .start,
            children: [self.averageNode, self.consensusNode, self.trendNode, self.newsNode, self.faceNode])
        
        let middleStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: Constants.kIsOriginalIphone ? 3 : 7,
            justifyContent: .start,
            alignItems: .start,
            children: [self.ratingsNode, minisStack])
        middleStack.style.flexBasis = ASDimensionMake(.fraction, UIDevice.getVerticalStackPercent())
        
        let graphStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: Constants.kIsOriginalIphone ? 10 : 15,
            justifyContent: .start,
            alignItems: .end,
            children: [middleStack, self.graphNode])
        
        let verticalStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: UIDevice.getPastSpacing(),
            justifyContent: .start,
            alignItems: .start,
            children: [self.nameNode, graphStack])
            verticalStack.style.flexBasis = ASDimensionMake(.fraction, UIDevice.getVerticalStackPercent())
        
        let rankStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: UIDevice.getPastSpacing(),
            justifyContent: .start,
            alignItems: .start,
            children: [ASLayoutSpec(), self.rankTextNode])
        
        let pastStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: UIDevice.getPastSpacing(),
            justifyContent: .start,
            alignItems: .start,
            children: [ASLayoutSpec(), self.pastTextNode])
        
        let rankOverlayStack = ASOverlayLayoutSpec(child: self.rankNode, overlay: rankStack)
        let pastOverlayStack = ASOverlayLayoutSpec(child: self.pastNode, overlay: pastStack)
        
        let rankTextStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .center,
            children: [rankOverlayStack, pastOverlayStack])
        rankTextStack.style.flexBasis = ASDimensionMake(.fraction, 0.1)
        
        let wreathStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: Constants.kIsOriginalIphone ? 5 : 5.5,
            justifyContent: .start,
            alignItems: .start,
            children: [ASLayoutSpec(), self.wreathTextNode])
        
        let wreathOverlayStack = ASOverlayLayoutSpec(child: self.wreathNode, overlay: wreathStack)
        
        let rightStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .center,
            children: [wreathOverlayStack, self.switchNode])
        
        let horizontalStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: Constants.kIsOriginalIphone ? Constants.kPadding/2 : Constants.kPadding,
            justifyContent: .start,
            alignItems: .center,
            children: [rankTextStack, self.profilePicNode, verticalStack, rightStack])

        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: Constants.kPadding, left: Constants.kPadding, bottom: Constants.kPadding, right: Constants.kPadding),
            child: horizontalStack),
            background: self.backgroundNode)
    }
    
    //MARK: BEMCheckBoxDelegate
    func didTap(_ checkBox: BEMCheckBox) {
        self.updateCheckBox(checkBox)
        SettingsViewModel().updateTodayWidgetSignal().start()
    }
    
    func updateCheckBox(_ checkBox: BEMCheckBox) {
        if checkBox.on == false {
            CelebrityViewModel().followCebritySignal(id: self.id, isFollowing: false).start()
        } else {
            CelebrityViewModel().countFollowedCelebritiesSignal()
                .on(value: { count in
                    if count > 9 {
                        let message = "Today View: maximum reached!"
                        NotificationCenter.default.post(name: .onSelectedBox, object: checkBox, userInfo: ["message": message])
                        Motion.delay(0.5){ checkBox.setOn(false, animated: true) }
                    } else {
                        let message = "Today View: \(self.celebST.getCelebName()) added!"
                        NotificationCenter.default.post(name: .onSelectedBox, object: checkBox, userInfo: ["message": message])
                        CelebrityViewModel().followCebritySignal(id: self.id, isFollowing: true).start()
                    }
                }).start()
        }
    }
}
