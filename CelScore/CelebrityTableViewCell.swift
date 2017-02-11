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


final class celebrityTableNodeCell: ASCellNode, BEMCheckBoxDelegate {
    
    //MARK: Properties
    fileprivate let ratingsNode: ASDisplayNode
    fileprivate let switchNode: ASDisplayNode
    fileprivate let backgroundNode: ASDisplayNode
    internal let nameNode: ASTextNode
    internal let trendNode: ASImageNode
    internal let consensusNode: ASImageNode
    internal let faceNode: ASImageNode
    internal let profilePicNode: ASNetworkImageNode
    internal let celebST: CelebrityStruct
    
    //MARK: Initializer
    init(celebrityStruct: CelebrityStruct) {
        self.celebST = celebrityStruct
        
        self.nameNode = ASTextNode()
        let attr = [NSFontAttributeName: UIFont.systemFont(ofSize: UIDevice.getFontSize() + 2), NSForegroundColorAttributeName : Color.black]
        self.nameNode.attributedText = NSMutableAttributedString(string: "\(celebST.nickname)", attributes: attr)
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.truncationMode = .byTruncatingTail
    
        self.profilePicNode = ASNetworkImageNode()
        self.profilePicNode.url = URL(string: self.celebST.imageURL)
        self.profilePicNode.defaultImage = R.image.anonymous()
        self.profilePicNode.contentMode = .scaleAspectFill
        self.profilePicNode.style.preferredSize = CGSize(width: UIDevice.getRowHeight(), height: UIDevice.getRowHeight())
        
        let cosmosView: CosmosView = CosmosView()
        cosmosView.settings.starSize = 15
        cosmosView.settings.starMargin = 1.0
        cosmosView.settings.updateOnTouch = false
        self.ratingsNode = ASDisplayNode(viewBlock: { () -> UIView in return cosmosView })
        self.ratingsNode.style.preferredSize = CGSize(width: 10, height: 20)
        self.ratingsNode.backgroundColor = UIColor.clear
        
        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id)
            .on(value: { score in cosmosView.rating = score/20 })
            .start()
        
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id)
            .on(value: { hasRatings in
                cosmosView.settings.colorFilled = hasRatings ? Constants.kStarGoldShade : Constants.kStarGreyShade
                cosmosView.settings.borderColorEmpty = Constants.kStarGreyShade })
            .start()
        
        let box: BEMCheckBox = BEMCheckBox(frame: CGRect(x: floor(UIDevice.getFollowCheckBoxPosition()), y: 30, width: 30, height: 30))
        box.onAnimationType = .bounce
        box.offAnimationType = .bounce
        box.onCheckColor = Color.white
        box.onFillColor = Constants.kRedShade
        box.onTintColor = Constants.kRedShade
        box.tintColor = Constants.kRedShade
        box.setOn(self.celebST.isFollowed, animated: true)
        self.switchNode = ASDisplayNode(viewBlock: { () -> UIView in return box })
        self.switchNode.style.preferredSize = box.frame.size
        
        let cardView: PulseView = PulseView()
        cardView.borderWidth = 2.0
        cardView.borderColor = Constants.kBlueShade
        self.backgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return cardView })
        self.backgroundNode.backgroundColor = Constants.kGreyBackground
        
        self.trendNode = ASImageNode()
        self.trendNode.style.preferredSize = CGSize(width: Constants.kMiniCircleDiameter, height: Constants.kMiniCircleDiameter)
        
        self.consensusNode = ASImageNode()
        self.consensusNode.style.preferredSize = CGSize(width: Constants.kMiniCircleDiameter + 0.5, height: Constants.kMiniCircleDiameter + 0.5)
        
        self.faceNode = ASImageNode()
        self.faceNode.style.preferredSize = CGSize(width: Constants.kMiniCircleDiameter, height: Constants.kMiniCircleDiameter)
        
        super.init()
        self.selectionStyle = .none
        box.delegate = self
        
        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id)
            .on(value: { score in
                self.trendNode.image = score >= self.celebST.prevScore ? R.image.arrow_up()! : R.image.arrow_down()! })
            .start()
        
        RatingsViewModel().getConsensusSignal(ratingsId: self.celebST.id)
            .on(value: { consensus in
                self.consensusNode.image = consensus >= Constants.kPositiveConsensus ? R.image.crown_filling_blue()! : R.image.crown_filling_red()!
                if self.celebST.isKing { self.consensusNode.image = R.image.crown_filling_yellow()! }
                if self.celebST.id == "0014" { print("king :\(self.celebST.isKing)") }
            })
            .start()
        
        RatingsViewModel().getRatingsSignal(ratingsId: self.celebST.id, ratingType: RatingsType.userRatings)
            .on(failed: { _ in self.faceNode.image = R.image.emptyCircle()! })
            .on(value: { ratings in
                switch ratings.getCelScore() {
                case 90..<101: self.faceNode.image = R.image.happyFace()!
                case 75..<90: self.faceNode.image = R.image.smileFace()!
                case 60..<75: self.faceNode.image = R.image.nosmileFace()!
                case 40..<60: self.faceNode.image = R.image.sadFace()!
                case 20..<40: self.faceNode.image = R.image.angryFace()!
                default: self.faceNode.image = R.image.emptyCircle()!
                } })
            .start()
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.profilePicNode)
        self.addSubnode(self.nameNode)
        self.addSubnode(self.ratingsNode)
        self.addSubnode(self.switchNode)
        self.addSubnode(self.trendNode)
        self.addSubnode(self.consensusNode)
        self.addSubnode(self.faceNode)
    }
    
    //MARK: Methods
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.profilePicNode.style.flexBasis = ASDimensionMake(.points, UIDevice.getRowHeight())
        
        let minisStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: Constants.kPadding/2,
            justifyContent: .start,
            alignItems: .start,
            children: [self.trendNode, self.consensusNode, self.faceNode])
        minisStack.style.flexGrow = 1
        
        let verticalStack = ASStackLayoutSpec(
        direction: .vertical,
        spacing: Constants.kPadding/4,
        justifyContent: .start,
        alignItems: .start,
        children: [self.nameNode, self.ratingsNode, minisStack])
        verticalStack.style.flexBasis = ASDimensionMake(.fraction, Constants.kVerticalStackPercent)
        verticalStack.style.flexGrow = 1
        
        let horizontalStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: Constants.kPadding,
            justifyContent: .start,
            alignItems: .center,
            children: [self.profilePicNode, verticalStack, self.switchNode])
        horizontalStack.style.flexBasis = ASDimensionMake(.fraction, 1)
        
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: Constants.kPadding, left: Constants.kPadding, bottom: Constants.kPadding, right: 2*Constants.kPadding),
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
        if checkBox.on == false { CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: false)
            .observe(on: UIScheduler())
            .start()
        } else {
            CelebrityViewModel().countFollowedCelebritiesSignal()
                .on(value: { count in
                    if count == 0 {
                        SettingsViewModel().getSettingSignal(settingType: .firstFollow).startWithValues({ first in
                            CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: true).start()
                            let firstTime = first as! Bool
                            guard firstTime else { return }
                            TAOverlay.show(withLabel: OverlayInfo.firstFollow.message(), image: OverlayInfo.firstFollow.logo(), options: OverlayInfo.getOptions()) })
                        TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false as AnyObject, settingType: .firstFollow).start() })
                    }
                    else if count > 9 {
                        TAOverlay.show(withLabel: OverlayInfo.maxFollow.message(),
                                       image: OverlayInfo.maxFollow.logo(),
                                       options: OverlayInfo.getOptions())
                        TAOverlay.setCompletionBlock({ _ in checkBox.setOn(false, animated: true) })
                    } else { CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: true).start() }
                }).start()
        }
    }
}
