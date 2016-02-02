//
//  SettingsViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/1/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import YLProgressBar
import JTMaterialSwitch
import Material


final class SettingsViewController: ASViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: Properties
    let settingsVM: SettingsViewModel
    let logoPicNode: ASImageNode
    let publicOpinionBarNode: ASDisplayNode
    let consensusBarNode: ASDisplayNode
    let factsBarNode: ASDisplayNode
    let pickerViewNode: ASDisplayNode
    let publicServiceSwitchNode: ASDisplayNode
    let logStatusNode: ASDisplayNode
    let logoTextNode: ASTextNode
    let logNameTextNode: ASTextNode
    let publicOpinionTextNode: ASTextNode
    let consensusTextNode: ASTextNode
    let factsTextNode: ASTextNode
    let pickerTextNode: ASTextNode
    let publicServiceTextNode: ASTextNode
    let logStatusTextNode: ASTextNode
    let copyrightTextNode: ASTextNode
    let kMaxWidth = Constants.kMenuWidth - 2 * Constants.kCellPadding
    let kSpacing: CGFloat = 40.0
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.settingsVM = SettingsViewModel()
        
        //MARK: Logo
        self.logoPicNode = ASImageNode()
        self.logoPicNode.image = UIImage(named: "flask_logo")
        self.logoPicNode.frame = CGRect(x: 85, y: 50, width: 70, height: 120)
        self.logoTextNode = ASTextNode()
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(8.0), NSForegroundColorAttributeName : MaterialColor.black]
        self.logoTextNode.attributedString = NSMutableAttributedString(string:"*Vote Responsibly.", attributes:attrs)
        var y = self.logoPicNode.frame.height + self.logoPicNode.frame.origin.y
        self.logoTextNode.frame = CGRect(x: 86, y: y, width: kMaxWidth, height: 20)
        
        let logoBackgroundView: MaterialView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: 35, width: kMaxWidth, height: 160))
        logoBackgroundView.depth = .Depth1
        logoBackgroundView.backgroundColor = MaterialColor.white
        let logoBackgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return logoBackgroundView })
        
        //MARK: PublicOpinion
        y += kSpacing
        self.publicOpinionTextNode = ASTextNode()
        self.publicOpinionTextNode.attributedString = NSMutableAttributedString(string:"#PublicOpinion Completion:")
        self.publicOpinionTextNode.frame = CGRect(x: 2 * Constants.kCellPadding, y: y + Constants.kCellPadding, width: kMaxWidth - 20, height: 20)
        
        let publicBackgroundView: MaterialView = MaterialView(frame: CGRectMake(Constants.kCellPadding, y, kMaxWidth, 60))
        publicBackgroundView.depth = .Depth1
        publicBackgroundView.backgroundColor = MaterialColor.white
        let publicBackgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return publicBackgroundView })
        
        y = self.publicOpinionTextNode.frame.height + self.publicOpinionTextNode.frame.origin.y
        let publicOpinionBar = YLProgressBar(frame: CGRect(x: 2 * Constants.kCellPadding, y: y, width: kMaxWidth - 20, height: 15))
        publicOpinionBar.progressTintColor = MaterialColor.green.darken4
        publicOpinionBar.type = .Flat
        publicOpinionBar.indicatorTextDisplayMode = .Progress
        self.publicOpinionBarNode = ASDisplayNode(viewBlock: { () -> UIView in return publicOpinionBar })
        
        //MARK: Consensus
        y += kSpacing
        self.consensusTextNode = ASTextNode()
        self.consensusTextNode.attributedString = NSMutableAttributedString(string:"Overall Social Consensus:")
        self.consensusTextNode.frame = CGRect(x: 2 * Constants.kCellPadding, y: y + Constants.kCellPadding, width: kMaxWidth - 20, height: 20)
        
        let consensusBackgroundView: MaterialView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: y, width: kMaxWidth, height: 60))
        consensusBackgroundView.depth = .Depth1
        consensusBackgroundView.backgroundColor = MaterialColor.white
        let consensusBackgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return consensusBackgroundView })
        
        y = self.consensusTextNode.frame.height + self.consensusTextNode.frame.origin.y
        let consensusBar = YLProgressBar(frame: CGRect(x: 2 * Constants.kCellPadding, y: y, width: kMaxWidth - 20, height: 15))
        consensusBar.progressTintColor = MaterialColor.green.darken4
        consensusBar.type = .Flat
        consensusBar.indicatorTextDisplayMode = .Progress
        self.consensusBarNode = ASDisplayNode(viewBlock: { () -> UIView in return consensusBar })
        
        //MARK: Random Facts
        y += kSpacing
        self.factsTextNode = ASTextNode()
        self.factsTextNode.attributedString = NSMutableAttributedString(string:"#CitizensThatDontWatchTelevision:")
        self.factsTextNode.frame = CGRect(x: 2 * Constants.kCellPadding, y: y + Constants.kCellPadding, width: kMaxWidth - 20, height: 20)
        
        let factsBackgroundView: MaterialView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: y, width: kMaxWidth, height: 60))
        factsBackgroundView.depth = .Depth1
        factsBackgroundView.backgroundColor = MaterialColor.white
        let factsBackgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return factsBackgroundView })
        
        y = self.factsTextNode.frame.height + self.factsTextNode.frame.origin.y
        let factsBar = YLProgressBar(frame: CGRect(x: 2 * Constants.kCellPadding, y: y, width: kMaxWidth - 20, height: 15))
        factsBar.progressTintColor = MaterialColor.green.darken4
        factsBar.type = .Flat
        factsBar.indicatorTextDisplayMode = .Progress
        self.factsBarNode = ASDisplayNode(viewBlock: { () -> UIView in return factsBar })
        
        //MARK: Picker
        y += kSpacing
        self.pickerTextNode = ASTextNode()
        self.pickerTextNode.attributedString = NSMutableAttributedString(string:"Main Topic Of Interest:")
        self.pickerTextNode.frame = CGRect(x: 2 * Constants.kCellPadding, y: y + Constants.kCellPadding, width: kMaxWidth - 20, height: 20)
        
        let pickerBackgroundView: MaterialView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: y , width: kMaxWidth, height: 160))
        pickerBackgroundView.depth = .Depth1
        pickerBackgroundView.backgroundColor = MaterialColor.white
        let pickerBackgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerBackgroundView })
        
        y = self.pickerTextNode.frame.height + self.pickerTextNode.frame.origin.y
        let pickerView = UIPickerView(frame: CGRect(x: 2 * Constants.kCellPadding, y: y + Constants.kCellPadding, width: kMaxWidth - 20, height: 100))
        self.pickerViewNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        
        //MARK: PublicService
        y += 3 * kSpacing
        self.publicServiceTextNode = ASTextNode()
        self.publicServiceTextNode.attributedString = NSMutableAttributedString(string:"Public Service Mode:")
        self.publicServiceTextNode.frame = CGRect(x: 2 * Constants.kCellPadding, y: y + 2.5 * Constants.kCellPadding, width: kMaxWidth - 20, height: 20)
        
        let serviceBackgroundView: MaterialView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: y , width: kMaxWidth, height: 60))
        serviceBackgroundView.depth = .Depth1
        serviceBackgroundView.backgroundColor = MaterialColor.white
        let serviceBackgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return serviceBackgroundView })
        
        let publicServiceSwitch = JTMaterialSwitch(size: JTMaterialSwitchSizeSmall, state: JTMaterialSwitchStateOff)
        publicServiceSwitch.thumbOnTintColor = MaterialColor.purple.lighten2
        publicServiceSwitch.trackOnTintColor = MaterialColor.purple.lighten4
        publicServiceSwitch.rippleFillColor = MaterialColor.purple.lighten1
        publicServiceSwitch.center = CGPoint(x: 205, y: y + 3.5 * Constants.kCellPadding)
        self.publicServiceSwitchNode = ASDisplayNode(viewBlock: { () -> UIView in return publicServiceSwitch })
        
        //MARK: LogStatus
        y += 1.6 * kSpacing
        self.logStatusTextNode = ASTextNode()
        self.logStatusTextNode.attributedString = NSMutableAttributedString(string:"Logged In As: ")
        self.logStatusTextNode.frame = CGRect(x: 2 * Constants.kCellPadding, y: y + Constants.kCellPadding, width: 75, height: 20)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Right
        let attributes = [NSForegroundColorAttributeName : MaterialColor.green.darken2, NSParagraphStyleAttributeName : paragraphStyle]
        self.logNameTextNode = ASTextNode()
        self.logNameTextNode.attributedString = NSMutableAttributedString(string:"@GreyEcologist", attributes: attributes)
        self.logNameTextNode.frame = CGRect(x: 85, y: y + Constants.kCellPadding, width: 145, height: 20)
        
        let logBackgroundView: MaterialView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: y , width: kMaxWidth, height: 80))
        logBackgroundView.depth = .Depth1
        logBackgroundView.backgroundColor = MaterialColor.white
        let logBackgroundNode = ASDisplayNode(viewBlock: { () -> UIView in return logBackgroundView })
        
        let logoutButton = FlatButton(frame: CGRect(x: 70, y: y + 45, width: 120, height: 30))
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.titleLabel!.font = RobotoFont.mediumWithSize(12)
        self.logStatusNode = ASDisplayNode(viewBlock: { () -> UIView in return logoutButton })
        
        //MARK: Copyright
        y += 1.8 * kSpacing
        self.copyrightTextNode = ASTextNode()
        let attr = [NSFontAttributeName : UIFont.systemFontOfSize(9.0), NSForegroundColorAttributeName : MaterialColor.grey.darken3]
        self.copyrightTextNode.attributedString = NSMutableAttributedString(
            string:"CelScore 1.0.0 Copyrights. Grey Ecology, 2016.", attributes: attr)
        self.copyrightTextNode.frame = CGRect(x: 2 * Constants.kCellPadding, y: y + Constants.kCellPadding, width: kMaxWidth - 20, height: 20)
        
        super.init(node: ASDisplayNode())
        pickerView.dataSource = self
        pickerView.delegate = self
        
        self.node.addSubnode(logoBackgroundNode)
        self.node.addSubnode(self.logoPicNode)
        self.node.addSubnode(self.logoTextNode)
        self.node.addSubnode(publicBackgroundNode)
        self.node.addSubnode(self.publicOpinionTextNode)
        self.node.addSubnode(self.publicOpinionBarNode)
        self.node.addSubnode(consensusBackgroundNode)
        self.node.addSubnode(self.consensusTextNode)
        self.node.addSubnode(self.consensusBarNode)
        self.node.addSubnode(factsBackgroundNode)
        self.node.addSubnode(self.factsTextNode)
        self.node.addSubnode(self.factsBarNode)
        self.node.addSubnode(pickerBackgroundNode)
        self.node.addSubnode(self.pickerTextNode)
        self.node.addSubnode(self.pickerViewNode)
        self.node.addSubnode(serviceBackgroundNode)
        self.node.addSubnode(self.publicServiceTextNode)
        self.node.addSubnode(self.publicServiceSwitchNode)
        self.node.addSubnode(logBackgroundNode)
        self.node.addSubnode(self.logStatusTextNode)
        self.node.addSubnode(self.logNameTextNode)
        self.node.addSubnode(self.logStatusNode)
        self.node.addSubnode(self.copyrightTextNode)
        
        //self.settingsVM.getUserRatingsPercentageSignal().start()
        //self.settingsVM.calculateSocialConsensusSignal().start()
        self.settingsVM.getSettingSignal(settingType: .DefaultListId).start()
    }
    
    //MARK: Method
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = Constants.kBackgroundColor
        self.sideNavigationViewController!.backdropColor = MaterialColor.grey.darken3
        self.sideNavigationViewController!.depth = .Depth1
    }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return CelebList.getCount() }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CelebList(rawValue: row)?.name()
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //self.settingsVM.updateSettingOnLocalStoreSignal(value: row, settingType: .DefaultListId).start()
    }

}