//
//  SettingsNode.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/25/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit


final class SettingsNode: ASDisplayNode {
    
    //MARK: Property
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
    
    override init() {
        self.settingsVM = SettingsViewModel()
        self.logoPicNode = ASImageNode()
        self.publicOpionBarNode = ASDisplayNode()
        self.consensusBarNode = ASDisplayNode()
        self.pickerViewNode = ASDisplayNode()
        self.switchNode = ASDisplayNode()
        self.logButtonNode = ASDisplayNode()
        
        self.logoTextNode = ASTextNode()
        self.logoTextNode.attributedString = NSMutableAttributedString(string:"The one and only!")
        self.logoTextNode.maximumNumberOfLines = 1
        self.logoTextNode.truncationMode = .ByTruncatingTail
        
        self.publicOpionTextNode = ASTextNode()
        self.consensusTextNode = ASTextNode()
        self.pickerTextNode = ASTextNode()
        self.publicServiceTextNode = ASTextNode()
        self.logStatusTextNode = ASTextNode()
        self.copyrightTextNode = ASTextNode()
        
        super.init()
        self.layerBacked = false
        //self.addSubnode(self.logoPicNode)
        self.addSubnode(self.logoTextNode)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.logoTextNode.flexBasis = ASRelativeDimension(type: .Percent, value: 1.0)
        self.logoTextNode.backgroundColor = UIColor.redColor()
        print("layoutSpecThatFits!!!")
        
        let verticalStack = ASStackLayoutSpec(
            direction: .Vertical,
            spacing: Constants.cellPadding,
            justifyContent: .Start,
            alignItems: .Center,
            children: [self.logoTextNode])
        verticalStack.flexBasis = ASRelativeDimension(type: .Percent, value: 1.0)
        
        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
            insets: UIEdgeInsetsMake(Constants.cellPadding, Constants.cellPadding, Constants.cellPadding, Constants.cellPadding),
            child: verticalStack),
            background: nil)
    }
}