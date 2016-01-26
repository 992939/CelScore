//
//  SettingsView.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/25/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import YLProgressBar

final class SettingsView: UIView {
    
    //MARK: Properties
    let settingsVM: SettingsViewModel
    let logoPicNode: ASImageNode
    let publicOpinionBarNode: ASDisplayNode
    let consensusBarNode: ASDisplayNode
    let pickerViewNode: ASDisplayNode
    let publicServiceSwitchNode: ASDisplayNode
    let logStatusNode: ASDisplayNode
    let logoTextNode: ASTextNode
    let publicOpinionTextNode: ASTextNode
    let consensusTextNode: ASTextNode
    let pickerTextNode: ASTextNode
    let publicServiceTextNode: ASTextNode
    let logStatusTextNode: ASTextNode
    let copyrightTextNode: ASTextNode
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }

    override init(frame: CGRect) {
        self.settingsVM = SettingsViewModel()
        
        self.logoPicNode = ASImageNode()
        self.logoPicNode.image = UIImage(named: "flask_logo")
        self.logoPicNode.frame = CGRectMake(80, Constants.kNavigationPadding, 60, 100)
        self.logoTextNode = ASTextNode()
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(6.0)]
        self.logoTextNode.attributedString = NSMutableAttributedString(string:"*Vote Responsibly.", attributes:attrs)
        var y = self.logoPicNode.frame.height + self.logoPicNode.frame.origin.y
        self.logoTextNode.frame = CGRectMake(83, y, Constants.kMenuWidth, 20)
        
        y += 50
        self.publicOpinionTextNode = ASTextNode()
        self.publicOpinionTextNode.attributedString = NSMutableAttributedString(string:"#PublicOpinion Completion:")
        self.publicOpinionTextNode.frame = CGRectMake(Constants.kCellPadding, y, Constants.kMenuWidth, 20)
        y = self.publicOpinionTextNode.frame.height + self.publicOpinionTextNode.frame.origin.y
        let publicOpinionBar = YLProgressBar(frame: CGRectMake(Constants.kCellPadding, y, Constants.kMenuWidth - 2*Constants.kCellPadding, 15))
        publicOpinionBar.progressTintColor = UIColor.redColor()
        publicOpinionBar.type = YLProgressBarType.Flat
        self.publicOpinionBarNode = ASDisplayNode.init(viewBlock: { () -> UIView in return publicOpinionBar })
        
        y += 50
        self.consensusTextNode = ASTextNode()
        self.consensusTextNode.attributedString = NSMutableAttributedString(string:"Overall Social Consensus:")
        self.consensusTextNode.frame = CGRectMake(Constants.kCellPadding, y, Constants.kMenuWidth, 20)
        y = self.consensusTextNode.frame.height + self.consensusTextNode.frame.origin.y
        let consensusBar = YLProgressBar(frame: CGRectMake(Constants.kCellPadding, y, Constants.kMenuWidth - 2*Constants.kCellPadding, 15))
        consensusBar.progressTintColor = UIColor.redColor()
        consensusBar.type = YLProgressBarType.Flat
        self.consensusBarNode = ASDisplayNode.init(viewBlock: { () -> UIView in return consensusBar })
        
        self.pickerViewNode = ASDisplayNode()
        self.pickerTextNode = ASTextNode()
        
        self.publicServiceSwitchNode = ASDisplayNode()
        self.publicServiceTextNode = ASTextNode()
        
        self.logStatusNode = ASDisplayNode()
        self.logStatusTextNode = ASTextNode()
        
        self.copyrightTextNode = ASTextNode()
        
        super.init(frame: frame)
        self.addSubnode(self.logoPicNode)
        self.addSubnode(self.logoTextNode)
        self.addSubnode(self.publicOpinionTextNode)
        self.addSubnode(self.publicOpinionBarNode)
        self.addSubnode(self.consensusTextNode)
        self.addSubnode(self.consensusBarNode)
        
        //self.settingsVM.getUserRatingsPercentageSignal().start()
        //self.settingsVM.calculateSocialConsensusSignal().start()
        //self.settingsVM.updateSettingOnLocalStoreSignal(value: 1, settingType: .DefaultListId).start()
        self.settingsVM.getSettingSignal(settingType: .DefaultListId).start()
    }
}


