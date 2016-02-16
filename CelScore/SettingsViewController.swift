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
import BEMCheckBox


final class SettingsViewController: ASViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() { super.init(node: ASDisplayNode()) }
    
    //MARK: Method
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let maxWidth = self.view.width - 2 * Constants.kPadding
        
        //Logo TODO: logoImageView + "Vote Responsibly."
        let logoImageView = setupMaterialView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 80))
        logoImageView.depth = .Depth2
        logoImageView.backgroundColor = Constants.kDarkShade
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoImageView })

        //Progress Bars
        let publicOpinionBarNode = self.setupProgressBarNode("Your #PublicOpinion Completion", maxWidth: maxWidth, yPosition: logoImageView.bottom + Constants.kPadding)
        let consensusBarNode  = self.setupProgressBarNode("Your Positive Votes Ratio", maxWidth: maxWidth, yPosition: publicOpinionBarNode.view.bottom + Constants.kPadding)
        let factsBarNode = self.setupProgressBarNode("The Overall Social Consensus", maxWidth: maxWidth, yPosition: consensusBarNode.view.bottom + Constants.kPadding)
        
        //PickerView
        let pickerView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: factsBarNode.view.bottom + Constants.kPadding, width: maxWidth, height: Constants.kPickerViewHeight))
        let pickerLabel = setupLabel(title: "Main Topic Of Interest", frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 2 * Constants.kPadding, height: 25))
        let picker = UIPickerView(frame: CGRect(x: Constants.kPadding, y: Constants.kPickerY, width: maxWidth - 2 * Constants.kPadding, height: 100))
        pickerView.addSubview(pickerLabel)
        pickerView.addSubview(picker)
        let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        picker.dataSource = self
        picker.delegate = self
        
        //Check Boxes
        let publicServiceNode = setupCheckBoxNode("Public Service Mode", maxWidth: maxWidth, yPosition: pickerView.bottom + Constants.kPadding)
        let fortuneCookieNode = setupCheckBoxNode("Bad Fortune Cookies", maxWidth: maxWidth, yPosition: publicServiceNode.view.bottom + Constants.kPadding)
        
        //Login Status
        let loginView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: fortuneCookieNode.view.bottom + Constants.kPadding, width: maxWidth, height: 60))
        let loginLabel = setupLabel(title: "Logged In As", frame: CGRect(x: Constants.kPadding, y: 0, width: 90, height: 30))
        let userLabelWidth = maxWidth - (loginLabel.width + Constants.kPadding)
        let userLabel = setupLabel(title: "@GreyEcologist", frame: CGRect(x: loginLabel.width, y: 0, width: userLabelWidth, height: 30)) //TODO
        userLabel.textAlignment = .Right
        let logoutButton = FlatButton(frame: CGRect(x: 65, y: 30, width: 100, height: 30))
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.titleLabel!.font = UIFont(name: logoutButton.titleLabel!.font.fontName, size: 12)
        loginView.addSubview(loginLabel)
        loginView.addSubview(userLabel)
        loginView.addSubview(logoutButton)
        let loginNode = ASDisplayNode(viewBlock: { () -> UIView in return loginView })
        
        //Copyright
        let copyrightTextNode = ASTextNode()
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .Center
        let attr = [NSFontAttributeName : UIFont.systemFontOfSize(8.0), NSForegroundColorAttributeName : Constants.kBrightShade, NSParagraphStyleAttributeName: paraStyle]
        copyrightTextNode.attributedString = NSMutableAttributedString(string: "CelScore 1.0.0 Copyrights. Grey Ecology, 2016.", attributes: attr)
        copyrightTextNode.frame = CGRect(x: Constants.kPadding, y: self.view.bottom - 2 * Constants.kPadding, width: maxWidth, height: 20)
        copyrightTextNode.alignSelf = .Center
        
        self.node.addSubnode(logoNode)
        self.node.addSubnode(publicOpinionBarNode)
        self.node.addSubnode(consensusBarNode)
        self.node.addSubnode(factsBarNode)
        self.node.addSubnode(pickerNode)
        self.node.addSubnode(publicServiceNode)
        self.node.addSubnode(fortuneCookieNode)
        self.node.addSubnode(loginNode)
        self.node.addSubnode(copyrightTextNode)
        
        //TODO: SettingsViewModel().getUserRatingsPercentageSignal().start()
        //TODO: SettingsViewModel().calculateSocialConsensusSignal().start()
        SettingsViewModel().getSettingSignal(settingType: .DefaultListId).start()
        
        self.view.backgroundColor = Constants.kDarkShade
        self.sideNavigationViewController!.backdropColor = Constants.kDarkShade
        self.sideNavigationViewController!.depth = .Depth1
    }
    
    //MARK: DidLayoutSubviews Helpers
    func setupMaterialView(frame frame: CGRect) -> MaterialView {
        let materialView = MaterialView(frame: frame)
        materialView.depth = .Depth1
        materialView.backgroundColor = Constants.kMainShade
        return materialView
    }
    
    func setupLabel(title title: String, frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = title
        label.textColor = MaterialColor.white
        label.font = UIFont(name: label.font.fontName, size: 12)
        return label
    }
    
    func setupCheckBoxNode(title: String, maxWidth: CGFloat, yPosition: CGFloat) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 30))
        let publicServiceLabel = setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: 120, height: 30))
        let publicServiceBox = BEMCheckBox(frame: CGRect(x: maxWidth - 30, y: 5, width: 20, height: 20))
        publicServiceBox.onAnimationType = .Bounce
        publicServiceBox.offAnimationType = .Bounce
        publicServiceBox.onCheckColor = MaterialColor.white
        publicServiceBox.onFillColor = Constants.kBrightShade
        publicServiceBox.onTintColor = Constants.kBrightShade
        materialView.addSubview(publicServiceLabel)
        materialView.addSubview(publicServiceBox)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
    
    func setupProgressBarNode(title: String, maxWidth: CGFloat, yPosition: CGFloat) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 50))
        let factsLabel = setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 2 * Constants.kPadding, height: 25))
        let factsBar = YLProgressBar(frame: CGRect(x: Constants.kPadding, y: factsLabel.bottom, width: maxWidth - 2 * Constants.kPadding, height: 15))
        factsBar.progressTintColor = Constants.kWineShade
        factsBar.type = .Flat
        factsBar.indicatorTextDisplayMode = .Progress
        materialView.addSubview(factsLabel)
        materialView.addSubview(factsBar)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return ListInfo.getCount() }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: ListInfo(rawValue: row)!.name(), attributes: [NSForegroundColorAttributeName : MaterialColor.white])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //TODO: self.settingsVM.updateSettingOnLocalStoreSignal(value: row, settingType: .DefaultListId).start()
    }
}