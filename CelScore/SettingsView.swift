//
//  SettingsView.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 1/25/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import YLProgressBar

final class SettingsView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        let kMaxWidth = Constants.kMenuWidth - 2 * Constants.kCellPadding
        let kSpacing: CGFloat = 50.0
        
        self.settingsVM = SettingsViewModel()
        
        self.logoPicNode = ASImageNode()
        self.logoPicNode.image = UIImage(named: "flask_logo")
        self.logoPicNode.frame = CGRectMake(80, Constants.kNavigationPadding, 80, 120)
        self.logoTextNode = ASTextNode()
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(6.0)]
        self.logoTextNode.attributedString = NSMutableAttributedString(string:"*Vote Responsibly.", attributes:attrs)
        var y = self.logoPicNode.frame.height + self.logoPicNode.frame.origin.y
        self.logoTextNode.frame = CGRectMake(83, y, kMaxWidth, 20)
        
        y += kSpacing
        self.publicOpinionTextNode = ASTextNode()
        self.publicOpinionTextNode.attributedString = NSMutableAttributedString(string:"#PublicOpinion Completion:")
        self.publicOpinionTextNode.frame = CGRectMake(Constants.kCellPadding, y, kMaxWidth, 20)
        y = self.publicOpinionTextNode.frame.height + self.publicOpinionTextNode.frame.origin.y
        let publicOpinionBar = YLProgressBar(frame: CGRectMake(Constants.kCellPadding, y, kMaxWidth, 15))
        publicOpinionBar.progressTintColor = UIColor.redColor()
        publicOpinionBar.type = YLProgressBarType.Flat
        self.publicOpinionBarNode = ASDisplayNode.init(viewBlock: { () -> UIView in return publicOpinionBar })
        
        y += kSpacing
        self.consensusTextNode = ASTextNode()
        self.consensusTextNode.attributedString = NSMutableAttributedString(string:"Overall Social Consensus:")
        self.consensusTextNode.frame = CGRectMake(Constants.kCellPadding, y, kMaxWidth, 20)
        y = self.consensusTextNode.frame.height + self.consensusTextNode.frame.origin.y
        let consensusBar = YLProgressBar(frame: CGRectMake(Constants.kCellPadding, y, kMaxWidth, 15))
        consensusBar.progressTintColor = UIColor.redColor()
        consensusBar.type = YLProgressBarType.Flat
        self.consensusBarNode = ASDisplayNode.init(viewBlock: { () -> UIView in return consensusBar })
        
        y += kSpacing
        self.pickerTextNode = ASTextNode()
        self.pickerTextNode.attributedString = NSMutableAttributedString(string:"Topic Of Interest:")
        self.pickerTextNode.frame = CGRectMake(Constants.kCellPadding, y, kMaxWidth, 20)
        y = self.pickerTextNode.frame.height + self.pickerTextNode.frame.origin.y
        let pickerView = UIPickerView(frame: CGRectMake(Constants.kCellPadding, y, kMaxWidth, 100))
        self.pickerViewNode = ASDisplayNode.init(viewBlock: { () -> UIView in return pickerView })
        
        y += kSpacing
        self.publicServiceTextNode = ASTextNode()
        self.publicServiceTextNode.attributedString = NSMutableAttributedString(string:"Public Service Mode:")
        self.publicServiceTextNode.frame = CGRectMake(Constants.kCellPadding, y, kMaxWidth, 20)
        y = self.publicServiceTextNode.frame.height + self.publicServiceTextNode.frame.origin.y
        self.publicServiceSwitchNode = ASDisplayNode()
        
        
        self.logStatusNode = ASDisplayNode()
        self.logStatusTextNode = ASTextNode()
        
        self.copyrightTextNode = ASTextNode()
        
        super.init(frame: frame)
        pickerView.dataSource = self
        pickerView.delegate = self
        
        self.addSubnode(self.logoPicNode)
        self.addSubnode(self.logoTextNode)
        self.addSubnode(self.publicOpinionTextNode)
        self.addSubnode(self.publicOpinionBarNode)
        self.addSubnode(self.consensusTextNode)
        self.addSubnode(self.consensusBarNode)
        self.addSubnode(self.pickerTextNode)
        self.addSubnode(self.pickerViewNode)
        
        //self.settingsVM.getUserRatingsPercentageSignal().start()
        //self.settingsVM.calculateSocialConsensusSignal().start()
        //self.settingsVM.updateSettingOnLocalStoreSignal(value: 1, settingType: .DefaultListId).start()
        self.settingsVM.getSettingSignal(settingType: .DefaultListId).start()
    }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return CelebList.getCount() }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CelebList(rawValue: row)?.name()
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("GENERATION")
        if(row == 0) { print("YO") }
    }
}


