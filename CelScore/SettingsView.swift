//
//  SettingsView.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/25/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit

final class SettingsView: UIView {
    
    //MARK: Properties
    let settingsVM: SettingsViewModel
    let logoPicNode: ASImageNode
    let publicOpionBarNode: ASDisplayNode
    let consensusBarNode: ASDisplayNode
    let pickerViewNode: ASDisplayNode
    let switchNode: ASDisplayNode
    let logButtonNode: ASDisplayNode
    let logoTextNode: ASTextNode
    let publicOpionTextNode: ASTextNode
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
        self.publicOpionBarNode = ASDisplayNode()
        self.consensusBarNode = ASDisplayNode()
        self.pickerViewNode = ASDisplayNode()
        self.switchNode = ASDisplayNode()
        self.logButtonNode = ASDisplayNode()
        
        self.logoTextNode = ASTextNode()
        self.logoTextNode.attributedString = NSMutableAttributedString(string:"The one!")
        self.logoTextNode.maximumNumberOfLines = 1
        self.logoTextNode.frame = CGRectMake(Constants.cellPadding , 100, frame.width, 20)
        print("logo \(self.logoTextNode.description)")
        
        self.publicOpionTextNode = ASTextNode()
        self.consensusTextNode = ASTextNode()
        self.pickerTextNode = ASTextNode()
        self.publicServiceTextNode = ASTextNode()
        self.logStatusTextNode = ASTextNode()
        self.copyrightTextNode = ASTextNode()
        
        super.init(frame: frame)
        self.addSubnode(self.logoTextNode)
        
        //self.settingsVM.getUserRatingsPercentageSignal().start()
        //self.settingsVM.calculateSocialConsensusSignal().start()
        //self.settingsVM.updateSettingOnLocalStoreSignal(value: 1, settingType: .DefaultListId).start()
        self.settingsVM.getSettingSignal(settingType: .DefaultListId).start()
    }
}


