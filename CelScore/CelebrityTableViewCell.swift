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
import PMAlertController


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
    internal let rankTextNode: ASTextNode
    internal let pastNode: ASImageNode
    internal let pastTextNode: ASTextNode
    internal let consensusNode: ASImageNode
    internal let wreathNode: ASImageNode
    internal let wreathTextNode: ASTextNode
    internal let faceNode: ASImageNode
    internal let profilePicNode: ASNetworkImageNode
    internal let celebST: CelebrityStruct
    
    //MARK: Initializer
    init(celebrityStruct: CelebrityStruct) {
        self.celebST = celebrityStruct
        
        self.nameNode = ASTextNode()
        let attr = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: UIDevice.getFontSize() + 2), NSForegroundColorAttributeName : Color.black]
        let celebName = self.celebST.index == 1 ? celebST.kingName : celebST.nickName
        self.nameNode.attributedText = NSMutableAttributedString(string: "\(celebName)", attributes: attr)
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.truncationMode = .byTruncatingTail
    
        self.profilePicNode = ASNetworkImageNode()
        //self.profilePicNode.url = URL(string: self.celebST.imageURL)
        //self.profilePicNode.defaultImage = R.image.anonymous()
        self.profilePicNode.defaultImage = R.image.jamie_blue()!
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
        box.setOn(self.celebST.isFollowed, animated: true)
        self.switchNode = ASDisplayNode(viewBlock: { () -> UIView in return box })
        self.switchNode.style.preferredSize = box.frame.size
        
        self.wreathNode = ASImageNode()
        self.wreathNode.style.preferredSize = CGSize(width: UIDevice.getPastSize() + 4, height: UIDevice.getPastSize() + 4)
        self.wreathNode.image = R.image.blue_wreath()!
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let rankFont = R.font.droidSerifBold(size: UIDevice.getFontSize())!
        
        let attr2 = [NSFontAttributeName: rankFont,
                     NSForegroundColorAttributeName : Constants.kBlueShade,
                     NSParagraphStyleAttributeName: style]
        
        self.rankTextNode = ASTextNode()
        self.rankTextNode.attributedText = NSAttributedString(string: "\(self.celebST.index)", attributes: attr2)
        self.rankTextNode.style.preferredSize = CGSize(width: UIDevice.getRankingSize(), height: UIDevice.getRankingSize())
        
        self.wreathTextNode = ASTextNode()
        let days = self.celebST.daysOnThrone > 1 ? String(self.celebST.daysOnThrone) : "∅"
        self.wreathTextNode.attributedText = NSAttributedString(string: "\(days)", attributes: attr2)
        self.wreathTextNode.style.preferredSize = self.wreathNode.style.preferredSize
        
        let attr3 = [NSFontAttributeName: rankFont,
                     NSForegroundColorAttributeName : Constants.kRedShade,
                     NSParagraphStyleAttributeName: style]
        
        self.pastTextNode = ASTextNode()
        self.pastTextNode.attributedText = NSAttributedString(string: "\(self.celebST.y_index)", attributes: attr3)
        self.pastTextNode.style.preferredSize = CGSize(width: UIDevice.getRankingSize(), height: UIDevice.getRankingSize())
        
        self.rankNode = ASImageNode()
        self.rankNode.style.preferredSize = CGSize(width: UIDevice.getPastSize(), height: UIDevice.getPastSize())
        self.rankNode.image = R.image.thin_circle()!
        
        self.pastNode = ASImageNode()
        self.pastNode.style.preferredSize = CGSize(width: UIDevice.getPastSize(), height: UIDevice.getPastSize())
        self.pastNode.image = R.image.past_circle()!
        
        self.trendNode = ASImageNode()
        self.trendNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle(), height: UIDevice.getMiniCircle())
        
        self.newsNode = ASImageNode()
        self.newsNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle(), height: UIDevice.getMiniCircle())
        self.newsNode.image = self.celebST.isTrending ? R.image.bell_red()! : R.image.bell_blue()!
        
        self.consensusNode = ASImageNode()
        self.consensusNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle(), height: UIDevice.getMiniCircle())
        
        self.faceNode = ASImageNode()
        self.faceNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle(), height: UIDevice.getMiniCircle())
        
        self.averageNode = ASImageNode()
        self.averageNode.style.preferredSize = CGSize(width: UIDevice.getMiniCircle(), height: UIDevice.getMiniCircle())
        
        let cardView: PulseView = PulseView()
        cardView.borderWidth = 2.0
        cardView.borderColor = Constants.kBlueShade
        self.backgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return cardView })
        self.backgroundNode.layer.cornerRadius = Constants.kCornerRadius
        self.backgroundNode.backgroundColor = Constants.kGreyBackground
        
        super.init()
        self.selectionStyle = .none
        box.delegate = self
        
        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id)
            .on(value: { score in
                cosmosView.rating = score/20
                self.trendNode.image = score >= self.celebST.prevScore ? R.image.arrow_up()! : R.image.arrow_down()!
                self.consensusNode.image = score >= Constants.kRoyalty ? R.image.mini_crown_blue()! : R.image.mini_crown_red()!
                if self.celebST.y_index == 1 && self.celebST.index != 1  { self.consensusNode.image = R.image.mini_death()! }
                else if self.celebST.index == 1 { self.consensusNode.image = R.image.mini_crown_yellow()! }
            })
            .flatMap(.latest) { (_) -> SignalProducer<Int, NoError> in
                return CelebrityViewModel().countCelebritiesSignal() }
            .on(value: { count in
                self.averageNode.image = self.celebST.index < (count/2) ? R.image.half_circle_blue()! : R.image.half_circle_red()! })
            .flatMap(.latest) { (_) -> SignalProducer<RatingsModel, RatingsError> in
                return RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: .userRatings) }
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
            children: [self.consensusNode, self.trendNode, self.averageNode, self.newsNode, self.faceNode])
        
        let middleStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: Constants.kIsOriginalIphone ? 3 : 7,
            justifyContent: .start,
            alignItems: .start,
            children: [self.ratingsNode, minisStack])
        middleStack.style.flexBasis = ASDimensionMake(.fraction, UIDevice.getVerticalStackPercent())

        
        let verticalStack = ASStackLayoutSpec(
        direction: .vertical,
        spacing: UIDevice.getPastSpacing(),
        justifyContent: .start,
        alignItems: .start,
        children: [self.nameNode, middleStack])
        verticalStack.style.flexBasis = ASDimensionMake(.fraction, UIDevice.getVerticalStackPercent())
        
        let rankStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: UIDevice.getPastSpacing(),
            justifyContent: .start,
            alignItems: .start,
            children: [ASLayoutSpec(), self.rankTextNode])
        
        let pastStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: Constants.kIsOriginalIphone ? 6 : 8.5,
            justifyContent: .start,
            alignItems: .start,
            children: [ASLayoutSpec(), self.pastTextNode])
        
        let rankOverlayStack = ASOverlayLayoutSpec(child: self.rankNode, overlay: rankStack)
        let pastOverlayStack = ASOverlayLayoutSpec(child: self.pastNode, overlay: pastStack)
        
        let wreathStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: Constants.kIsOriginalIphone ? 5 : 5.5,
            justifyContent: .start,
            alignItems: .start,
            children: [ASLayoutSpec(), self.wreathTextNode])
        
        let rankTextStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 4,
            justifyContent: .start,
            alignItems: .center,
            children: [rankOverlayStack, pastOverlayStack])
        rankTextStack.style.flexBasis = ASDimensionMake(.fraction, 0.1)
        
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
        horizontalStack.style.flexBasis = ASDimensionMake(.fraction, 1)

        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: Constants.kPadding, left: Constants.kPadding, bottom: Constants.kPadding, right: Constants.kPadding),
            child: horizontalStack),
            background: self.backgroundNode)
    }
    
    func getId() -> String { return celebST.id }
    
    //MARK: BEMCheckBoxDelegate
    func didTap(_ checkBox: BEMCheckBox) {
        self.updateCheckBox(checkBox)
        SettingsViewModel().updateTodayWidgetSignal().start()
    }
    
    func updateCheckBox(_ checkBox: BEMCheckBox) {
        if checkBox.on == false {
            CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: false).start()
        } else {
            CelebrityViewModel().countFollowedCelebritiesSignal()
                .on(value: { count in
                    if count > 9 {
                        TAOverlay.show(withLabel: OverlayInfo.maxFollow.message(),
                                       image: OverlayInfo.maxFollow.logo(),
                                       options: OverlayInfo.getOptions())
                        TAOverlay.setCompletionBlock({ _ in checkBox.setOn(false, animated: true) })
                    } else {
                        CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: true).start()
                    }
                }).start()
        }
    }
}
