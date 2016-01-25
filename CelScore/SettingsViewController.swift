//
//  SettingsViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/6/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit


final class SettingsViewController: ASViewController {
    
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
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.settingsVM = SettingsViewModel()
        self.logoPicNode = ASImageNode()
        self.publicOpionBarNode = ASDisplayNode()
        self.consensusBarNode = ASDisplayNode()
        self.pickerViewNode = ASDisplayNode()
        self.switchNode = ASDisplayNode()
        self.logButtonNode = ASDisplayNode()
        self.logoTextNode = ASTextNode()
        self.publicOpionTextNode = ASTextNode()
        self.consensusTextNode = ASTextNode()
        self.pickerTextNode = ASTextNode()
        self.publicServiceTextNode = ASTextNode()
        self.logStatusTextNode = ASTextNode()
        self.copyrightTextNode = ASTextNode()
        
        super.init(node: ASDisplayNode())
    }
    
    //MARK: Methods
    override func viewWillLayoutSubviews() {}
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.settingsVM.getUserRatingsPercentageSignal().start()
        //self.settingsVM.calculateSocialConsensusSignal().start()
        //self.settingsVM.updateSettingOnLocalStoreSignal(value: 1, settingType: .DefaultListId).start()
        self.settingsVM.getSettingSignal(settingType: .DefaultListId).start()
    }
    
//    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        self.profilePicNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.12)
//        self.nameNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.48)
//        self.ratingsNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.2)
//        self.switchNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.2)
//        
//        let horizontalStack = ASStackLayoutSpec(
//            direction: .Horizontal,
//            spacing: Constants.cellPadding,
//            justifyContent: .Start,
//            alignItems: .Center,
//            children: [self.profilePicNode, self.nameNode, self.ratingsNode])
//        horizontalStack.flexBasis = ASRelativeDimension(type: .Percent, value: 1.0)
//        
//        return ASBackgroundLayoutSpec(child: ASInsetLayoutSpec(
//            insets: UIEdgeInsetsMake(Constants.cellPadding, Constants.cellPadding, Constants.cellPadding, Constants.cellPadding),
//            child: horizontalStack),
//            background: nil)
//    }
}