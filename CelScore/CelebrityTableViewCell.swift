//
//  CelebrityTableViewCell.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 5/23/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import WebASDKImageManager
import Material
import BEMCheckBox
import ReactiveCocoa


final class CelebrityTableViewCell: ASCellNode, BEMCheckBoxDelegate {
    
    //MARK: Properties
    private let ratingsNode: ASDisplayNode
    private let switchNode: ASDisplayNode
    private let backgroundNode: ASDisplayNode
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
        let attr = [NSFontAttributeName: UIFont.systemFontOfSize(UIDevice.getFontSize() + 2), NSForegroundColorAttributeName : MaterialColor.white]
        self.nameNode.attributedString = NSMutableAttributedString(string: "\(celebST.nickname)", attributes: attr)
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.truncationMode = .ByTruncatingTail
    
        self.profilePicNode = ASNetworkImageNode(webImage: ())
        self.profilePicNode.URL = NSURL(string: self.celebST.imageURL)
        self.profilePicNode.contentMode = .ScaleAspectFill
        self.profilePicNode.preferredFrameSize = CGSize(width: UIDevice.getRowHeight(), height: UIDevice.getRowHeight())
        
        self.trendNode = ASImageNode()
        self.trendNode.image = R.image.arrow_up()!
        self.trendNode.preferredFrameSize = CGSize(width: Constants.kMiniCircleDiameter, height: Constants.kMiniCircleDiameter)
        
        self.consensusNode = ASImageNode()
        self.consensusNode.image = R.image.sphere_green()!
        self.consensusNode.preferredFrameSize = CGSize(width: Constants.kMiniCircleDiameter, height: Constants.kMiniCircleDiameter)
        
        self.faceNode = ASImageNode()
        self.faceNode.image = R.image.sadFace()!
        self.faceNode.preferredFrameSize = CGSize(width: Constants.kMiniCircleDiameter, height: Constants.kMiniCircleDiameter)
        
        let cosmosView: CosmosView = CosmosView()
        cosmosView.settings.starSize = 15
        cosmosView.settings.starMargin = 1.0
        cosmosView.settings.updateOnTouch = false
        self.ratingsNode = ASDisplayNode(viewBlock: { () -> UIView in return cosmosView })
        self.ratingsNode.preferredFrameSize = CGSize(width: 10, height: 20)
        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithNext { score in
            cosmosView.rating = score
        }
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id).startWithNext { hasRatings in
            cosmosView.settings.colorFilled = hasRatings ? Constants.kStarRatingShade : MaterialColor.white
            cosmosView.settings.borderColorEmpty = hasRatings ? Constants.kStarRatingShade : MaterialColor.white
        }
        
        let box: BEMCheckBox = BEMCheckBox(frame: CGRect(x: floor(UIDevice.getFollowCheckBoxPosition()), y: 30, width: 30, height: 30))
        box.onAnimationType = .Bounce
        box.offAnimationType = .Bounce
        box.onCheckColor = MaterialColor.white
        box.onFillColor = Constants.kDarkGreenShade
        box.onTintColor = Constants.kDarkGreenShade
        box.tintColor = Constants.kDarkGreenShade
        box.setOn(self.celebST.isFollowed, animated: true)
        self.switchNode = ASDisplayNode(viewBlock: { () -> UIView in return box })
        self.switchNode.preferredFrameSize = box.frame.size
        
        let cardView: MaterialPulseView = MaterialPulseView()
        cardView.borderWidth = 2.0
        cardView.borderColor = Constants.kDarkShade
        self.backgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return cardView })
        self.backgroundNode.backgroundColor = Constants.kMainShade
        
        super.init()
        self.selectionStyle = .None
        box.delegate = self
        
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
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.profilePicNode.flexBasis = ASRelativeDimension(type: .Points, value: UIDevice.getRowHeight())
        
        let minisStack = ASStackLayoutSpec(
            direction: .Horizontal,
            spacing: Constants.kPadding/2,
            justifyContent: .Start,
            alignItems: .Start,
            children: [self.trendNode, self.consensusNode, self.faceNode])
        minisStack.flexGrow = true
        
        let verticalStack = ASStackLayoutSpec(
        direction: .Vertical,
        spacing: Constants.kPadding/4,
        justifyContent: .Start,
        alignItems: .Start,
        children: [self.nameNode, self.ratingsNode, minisStack])
        verticalStack.flexBasis = ASRelativeDimension(type: .Percent, value: Constants.kVerticalStackPercent)
        verticalStack.flexGrow = true
        
        let horizontalStack = ASStackLayoutSpec(
            direction: .Horizontal,
            spacing: Constants.kPadding,
            justifyContent: .Start,
            alignItems: .Center,
            children: [self.profilePicNode, verticalStack, self.switchNode])
        horizontalStack.flexBasis = ASRelativeDimension(type: .Percent, value: 1)
        
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: Constants.kPadding, left: Constants.kPadding, bottom: Constants.kPadding, right: 2*Constants.kPadding),
            child: horizontalStack),
            background: self.backgroundNode)
    }
    
    func getId() -> String { return celebST.id }
    
    //MARK: BEMCheckBoxDelegate
    func didTapCheckBox(checkBox: BEMCheckBox) {
        SettingsViewModel().loggedInAsSignal()
            .on(next: { _ in
                self.updateCheckBox(checkBox)
                SettingsViewModel().updateTodayWidgetSignal().start() })
            .on(failed: { _ in
                TAOverlay.showOverlayWithLabel(OverlayInfo.FirstNotFollow.message(), image: OverlayInfo.FirstNotFollow.logo(), options: OverlayInfo.getOptions())
               TAOverlay.setCompletionBlock({ _ in checkBox.setOn(false, animated: true) }) 
            })
            .start()
    }
    
    func updateCheckBox(checkBox: BEMCheckBox) {
        if checkBox.on == false { CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: false)
            .observeOn(UIScheduler())
            .start()
        } else {
            CelebrityViewModel().countFollowedCelebritiesSignal()
                .observeOn(UIScheduler())
                .startWithNext { count in
                    if count == 0 { SettingsViewModel().getSettingSignal(settingType: .FirstFollow).startWithNext({ first in
                        CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: true).start()
                        let firstTime = first as! Bool
                        guard firstTime else { return }
                        TAOverlay.showOverlayWithLabel(OverlayInfo.FirstFollow.message(), image: OverlayInfo.FirstFollow.logo(), options: OverlayInfo.getOptions()) })
                        TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstFollow).start() })
                    }
                    else if count > 9 {
                        TAOverlay.showOverlayWithLabel(OverlayInfo.MaxFollow.message(),
                            image: OverlayInfo.MaxFollow.logo(),
                            options: OverlayInfo.getOptions())
                        TAOverlay.setCompletionBlock({ _ in checkBox.setOn(false, animated: true) })
                    } else { CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: true).start() }
            }
        }
    }
}
