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


final class CelebrityTableViewCell: ASCellNode, MaterialSwitchDelegate {
    
    //MARK: Properties
    private let nameNode: ASTextNode
    private let ratingsNode: ASDisplayNode
    private let switchNode: ASDisplayNode
    private let backgroundNode: ASDisplayNode
    internal let profilePicNode: ASNetworkImageNode
    internal let celebST: CelebrityStruct
    
    //MARK: Initializer
    init(celebrityStruct: CelebrityStruct) {
        self.celebST = celebrityStruct
        
        self.nameNode = ASTextNode()
        let attr = [NSFontAttributeName: UIFont.systemFontOfSize(20.0), NSForegroundColorAttributeName : MaterialColor.white]
        self.nameNode.attributedString = NSMutableAttributedString(string: "\(celebST.nickname)", attributes: attr)
        self.nameNode.maximumNumberOfLines = 1
        self.nameNode.truncationMode = .ByTruncatingTail
    
        self.profilePicNode = ASNetworkImageNode(webImage: ())
        self.profilePicNode.URL = NSURL(string: self.celebST.imageURL)
        self.profilePicNode.contentMode = .ScaleAspectFill
        self.profilePicNode.preferredFrameSize = CGSize(width: 70, height: 70)
        
        let cosmosView = CosmosView()
        cosmosView.settings.starSize = Constants.kStarSize
        cosmosView.settings.starMargin = Constants.kStarMargin
        cosmosView.settings.updateOnTouch = false
        self.ratingsNode = ASDisplayNode(viewBlock: { () -> UIView in return cosmosView })
        self.ratingsNode.preferredFrameSize = CGSize(width: 10, height: 20)
        RatingsViewModel().getCelScoreSignal(ratingsId: self.celebST.id).startWithNext { score in cosmosView.rating = score }
        RatingsViewModel().hasUserRatingsSignal(ratingsId: self.celebST.id).startWithNext { hasRatings in
            cosmosView.settings.colorFilled = hasRatings ? Constants.kStarRatingShade : MaterialColor.white
            cosmosView.settings.borderColorEmpty = hasRatings ? Constants.kStarRatingShade : MaterialColor.white
        }
        
        let followSwitch = MaterialSwitch(size: .Small, state: self.celebST.isFollowed == true ? .On : .Off)
        followSwitch.center = CGPoint(x: Constants.kScreenWidth - 50, y: 45)
        followSwitch.buttonOnColor = Constants.kWineShade
    
        followSwitch.trackOnColor = followSwitch.trackOffColor
        self.switchNode = ASDisplayNode(viewBlock: { () -> UIView in return followSwitch })
        self.switchNode.preferredFrameSize = CGSize(width: 20, height: 20)
        
        let cardView: MaterialPulseView = MaterialPulseView()
        cardView.borderWidth = 2.0
        cardView.borderColor = Constants.kDarkShade
        self.backgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return cardView })
        self.backgroundNode.backgroundColor = Constants.kMainShade
        
        super.init()
        self.selectionStyle = .None
        followSwitch.delegate = self
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.profilePicNode)
        self.addSubnode(self.nameNode)
        self.addSubnode(self.ratingsNode)
        self.addSubnode(self.switchNode)
    }
    
    //MARK: Methods
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.profilePicNode.flexBasis = ASRelativeDimension(type: .Points, value: 70)
        self.nameNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.40)
        self.ratingsNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.15)
        self.switchNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.10)
        
        let horizontalStack = ASStackLayoutSpec(
            direction: .Horizontal,
            spacing: Constants.kPadding,
            justifyContent: .Start,
            alignItems: .Center,
            children: [self.profilePicNode, self.nameNode, self.ratingsNode])
        horizontalStack.flexBasis = ASRelativeDimension(type: .Percent, value: 0.95)
        
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsetsMake(Constants.kPadding, Constants.kPadding, Constants.kPadding, Constants.kPadding),
            child: horizontalStack),
            background: self.backgroundNode)
    }
    
    func getId() -> String { return celebST.id }
    
    //MARK: MaterialSwitchDelegate
    func materialSwitchStateChanged(control: MaterialSwitch) {
        if control.switchState == .Off { CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: false)
            .observeOn(UIScheduler())
            .start()
        } else {
            CelebrityViewModel().countFollowedCelebritiesSignal()
                .observeOn(UIScheduler())
                .startWithNext { count in
                    if count == 0 { SettingsViewModel().getSettingSignal(settingType: .FirstFollow).startWithNext({ first in
                        CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: true).start()
                        let firstTime = first as! Bool
                        if firstTime {
                            TAOverlay.showOverlayWithLabel(OverlayInfo.FirstFollow.message(),
                                image: OverlayInfo.FirstFollow.logo(),
                                options: OverlayInfo.getOptions())}})
                            TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstFollow).start() })
                    }
                    else if count > 9 {
                        TAOverlay.showOverlayWithLabel(OverlayInfo.MaxFollow.message(),
                            image: OverlayInfo.MaxFollow.logo(),
                            options: OverlayInfo.getOptions())
                        TAOverlay.setCompletionBlock({ _ in control.setOn(false, animated: true) })
                    } else { CelebrityViewModel().followCebritySignal(id: self.celebST.id, isFollowing: true).start() }
            }
        }
    }
}
