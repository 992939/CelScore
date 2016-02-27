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
        
        //Logo
        let logoImageView = setupMaterialView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 87))
        logoImageView.depth = .None
        //logoImageView.image = UIImage(named: "ballot")
        logoImageView.backgroundColor = Constants.kMainShade
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoImageView })
        self.node.addSubnode(logoNode)

        //Progress Bars
        let progressNodeHeight: CGFloat = 60.0
        
        SettingsViewModel().calculateUserRatingsPercentageSignal()
            .on(next: { value in
                let publicOpinionBarNode = self.setupProgressBarNode("Your Public Opinion Ratio", maxWidth: maxWidth, yPosition: logoImageView.bottom + Constants.kPadding, value: value)
                self.node.addSubnode(publicOpinionBarNode)
            })
            .start()
        SettingsViewModel().calculatePositiveVoteSignal()
            .on(next: { value in
                let positiveBarNode  = self.setupProgressBarNode("Your Positive Vote Ratio", maxWidth: maxWidth, yPosition: (logoImageView.bottom + Constants.kPadding + progressNodeHeight), value: value)
                self.node.addSubnode(positiveBarNode)
            })
            .start()
        SettingsViewModel().calculateSocialConsensusSignal()
            .on(next: { value in
                let consensusBarNode = self.setupProgressBarNode("General Social Consensus", maxWidth: maxWidth, yPosition: (logoImageView.bottom + Constants.kPadding + 2 * progressNodeHeight), value: value)
                self.node.addSubnode(consensusBarNode)
            })
            .start()
        
        //PickerView
        SettingsViewModel().getSettingSignal(settingType: .DefaultListIndex)
            .on(next: { index in
                let pickerView = self.setupMaterialView(frame: CGRect(x: Constants.kPadding, y: (logoImageView.bottom + Constants.kPadding + 3 * progressNodeHeight), width: maxWidth, height: Constants.kPickerViewHeight))
                let pickerLabel = self.setupLabel(title: "Default Topic Of Interest", frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 2 * Constants.kPadding, height: 25))
                let picker = UIPickerView(frame: CGRect(x: Constants.kPadding, y: Constants.kPickerY, width: maxWidth - 2 * Constants.kPadding, height: 100))
                picker.selectedRowInComponent(ListInfo(rawValue: (index as! Int))!.getIndex())
                picker.dataSource = self
                picker.delegate = self
                pickerView.addSubview(pickerLabel)
                pickerView.addSubview(picker)
                let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
                self.node.addSubnode(pickerNode)
            })
            .start()
        
        //TODO: save 1)picker choice, 2)public checkbox, 3)fortune checkbox
        
        //Check Boxes
        let publicNodeHeight = logoImageView.bottom + Constants.kPickerViewHeight + Constants.kPadding + 3 * progressNodeHeight
        
        SettingsViewModel().getSettingSignal(settingType: .DefaultListIndex)
            .on(next: { status in
                let publicServiceNode = self.setupCheckBoxNode("Public Service Mode", maxWidth: maxWidth, yPosition: publicNodeHeight, status: (status as! Bool))
                self.node.addSubnode(publicServiceNode)
            })
            .start()
        SettingsViewModel().getSettingSignal(settingType: .DefaultListIndex)
            .on(next: { status in
                let fortuneCookieNode = self.setupCheckBoxNode("Fortune Cookie Mode", maxWidth: maxWidth, yPosition: publicNodeHeight + 40, status: (status as! Bool))
                self.node.addSubnode(fortuneCookieNode)
            })
            .start()
        
        //Login Status
        let loginView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 80 + Constants.kPadding, width: maxWidth, height: 60))
        let loginLabel = setupLabel(title: "Logged As:", frame: CGRect(x: Constants.kPadding, y: 0, width: 100, height: 30))
        let userLabelWidth = maxWidth - (loginLabel.width + Constants.kPadding)
        let userLabel = setupLabel(title: "@GreyEcologist", frame: CGRect(x: loginLabel.width, y: 0, width: userLabelWidth, height: 30)) //TODO
        userLabel.textAlignment = .Right
        let logoutButton = FlatButton(frame: CGRect(x: 65, y: 30, width: 100, height: 30))
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.setTitleColor(Constants.kBrightShade, forState: .Normal)
        logoutButton.titleLabel!.font = UIFont(name: logoutButton.titleLabel!.font.fontName, size: 16)
        loginView.addSubview(loginLabel)
        loginView.addSubview(userLabel)
        loginView.addSubview(logoutButton)
        let loginNode = ASDisplayNode(viewBlock: { () -> UIView in return loginView })
        
        //Copyright
        let copyrightTextNode = ASTextNode()
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .Center
        let attr = [NSFontAttributeName : UIFont.systemFontOfSize(12.0), NSForegroundColorAttributeName : Constants.kBrightShade, NSParagraphStyleAttributeName: paraStyle]
        copyrightTextNode.attributedString = NSMutableAttributedString(string: "CelScore 1.0. Grey Ecology, 2016.", attributes: attr)
        copyrightTextNode.frame = CGRect(x: Constants.kPadding, y: self.view.bottom - 2 * Constants.kPadding, width: maxWidth, height: 20)
        copyrightTextNode.alignSelf = .Center
        
        self.node.addSubnode(loginNode)
        self.node.addSubnode(copyrightTextNode)
        
        //TODO: SettingsViewModel().getSettingSignal(settingType: .DefaultListId).start()
        
        self.view.backgroundColor = Constants.kDarkShade
        self.sideNavigationViewController!.backdropColor = Constants.kDarkShade
        self.sideNavigationViewController!.depth = .Depth1
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
        label.font = UIFont(name: label.font.fontName, size: 16)
        return label
    }
    
    func setupCheckBoxNode(title: String, maxWidth: CGFloat, yPosition: CGFloat, status: Bool) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 30))
        let publicServiceLabel = setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 30, height: 30))
        let publicServiceBox = BEMCheckBox(frame: CGRect(x: maxWidth - 30, y: 5, width: 20, height: 20))
        publicServiceBox.setOn(status, animated: true)
        publicServiceBox.onAnimationType = .Bounce
        publicServiceBox.offAnimationType = .Bounce
        publicServiceBox.onCheckColor = MaterialColor.white
        publicServiceBox.onFillColor = Constants.kBrightShade
        publicServiceBox.onTintColor = Constants.kBrightShade
        materialView.addSubview(publicServiceLabel)
        materialView.addSubview(publicServiceBox)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
    
    func setupProgressBarNode(title: String, maxWidth: CGFloat, yPosition: CGFloat, value: CGFloat) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 50))
        let factsLabel = setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 2 * Constants.kPadding, height: 25))
        let factsBar = YLProgressBar(frame: CGRect(x: Constants.kPadding, y: factsLabel.bottom, width: maxWidth - 2 * Constants.kPadding, height: 15))
        factsBar.progressTintColor = Constants.kBrightShade
        factsBar.setProgress(value, animated: true)
        factsBar.type = .Flat
        factsBar.indicatorTextDisplayMode = .Progress
        materialView.addSubview(factsLabel)
        materialView.addSubview(factsBar)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
}