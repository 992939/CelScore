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
        let logoImageView: ImageCardView = ImageCardView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 80))
        logoImageView.contentsGravity = .ResizeAspect
        logoImageView.divider = false
        logoImageView.depth = .Depth2
        let logoLabel = UILabel()
        //logoImageView.image = UIImage(named: "flask_logo")
        //logoLabel.text = "*Vote Responsibly."
        //logoLabel.font = UIFont(name: logoLabel.font.fontName, size: 10)
        //logoImageView.detailLabel = logoLabel
        //logoImageView.detailLabelInset = UIEdgeInsets(top: 10, left: 30, bottom: Constants.kPadding, right: 30)
        logoImageView.backgroundColor = Constants.kDarkShade
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoImageView })

        //Progress Bars
        let publicOpinionBarNode = self.setupProgressBarNode("Your #PublicOpinion Completion", maxWidth: maxWidth, yPosition: logoImageView.bottom + Constants.kPadding)
        let consensusBarNode  = self.setupProgressBarNode("Your Positive Votes Ratio", maxWidth: maxWidth, yPosition: publicOpinionBarNode.view.bottom + Constants.kPadding)
        let factsBarNode = self.setupProgressBarNode("The Overall Social Consensus", maxWidth: maxWidth, yPosition: consensusBarNode.view.bottom + Constants.kPadding)
        
        //Picker
        let pickerView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kPadding, y: factsBarNode.view.bottom + Constants.kPadding, width: maxWidth, height: Constants.kPickerViewHeight))
        pickerView.divider = false
        pickerView.depth = .Depth1
        let pickerLabel = UILabel()
        pickerLabel.text = "Main Topic Of Interest"
        pickerLabel.textColor = MaterialColor.white
        pickerLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        pickerView.titleLabel = pickerLabel
        pickerView.titleLabelInset = UIEdgeInsets(top: 0, left: 0, bottom: Constants.kPickerViewHeight - 30, right: 0)
        let picker = UIPickerView(frame: CGRect(x: Constants.kPadding, y: Constants.kPickerY, width: maxWidth - 20, height: 100))
        pickerView.addSubview(picker)
        pickerView.backgroundColor = Constants.kMainShade
        let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        
        //PublicService
        let publicServiceView: MaterialView = MaterialView(frame: CGRect(x: Constants.kPadding, y: pickerView.bottom + Constants.kPadding, width: maxWidth, height: 30))
        publicServiceView.depth = .Depth1
        let publicServiceLabel = UILabel()
        publicServiceLabel.text = "Public Service Mode"
        publicServiceLabel.textColor = MaterialColor.white
        publicServiceLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        publicServiceLabel.frame = CGRect(x: Constants.kPadding, y: 0, width: 120, height: 30)
        let publicServiceBox = BEMCheckBox(frame: CGRect(x: maxWidth - 30, y: Constants.kPadding, width: 15, height: 15))
        publicServiceBox.onAnimationType = .Bounce
        publicServiceBox.offAnimationType = .Bounce
        publicServiceBox.onCheckColor = MaterialColor.white
        publicServiceBox.onFillColor = Constants.kBrightShade
        publicServiceBox.onTintColor = Constants.kBrightShade
        publicServiceView.addSubview(publicServiceLabel)
        publicServiceView.addSubview(publicServiceBox)
        publicServiceView.backgroundColor = Constants.kMainShade
        let publicServiceNode = ASDisplayNode(viewBlock: { () -> UIView in return publicServiceView })
        
        //Fortune Cookies
        let notificationView: MaterialView = MaterialView(frame: CGRect(x: Constants.kPadding, y: publicServiceView.bottom + Constants.kPadding, width: maxWidth, height: 30))
        notificationView.depth = .Depth1
        let notificationLabel = UILabel()
        notificationLabel.text = "Bad Fortune Cookies"
        notificationLabel.textColor = MaterialColor.white
        notificationLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        notificationLabel.frame = CGRect(x: Constants.kPadding, y: 0, width: 120, height: 30)
        let notificationBox = BEMCheckBox(frame: CGRect(x: maxWidth - 30, y: Constants.kPadding, width: 15, height: 15))
        notificationBox.onAnimationType = .Bounce
        notificationBox.offAnimationType = .Bounce
        notificationBox.onCheckColor = MaterialColor.white
        notificationBox.onFillColor = Constants.kBrightShade
        notificationBox.onTintColor = Constants.kBrightShade
        notificationView.addSubview(notificationLabel)
        notificationView.addSubview(notificationBox)
        notificationView.backgroundColor = Constants.kMainShade
        let notificationNode = ASDisplayNode(viewBlock: { () -> UIView in return notificationView })
        
        //LogStatus
        let loginView: MaterialView = MaterialView(frame: CGRect(x: Constants.kPadding, y: notificationView.bottom + Constants.kPadding, width: maxWidth, height: 60))
        loginView.depth = .Depth1
        let loginLabel = UILabel()
        loginLabel.textColor = MaterialColor.white
        loginLabel.text = "Logged In As"
        loginLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        loginLabel.frame = CGRect(x: Constants.kPadding, y: 0, width: 90, height: 30)
        let userLabel = UILabel()
        userLabel.text = "@GreyEcologist" //TODO
        userLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        let userLabelWidth = maxWidth - (loginLabel.width + Constants.kPadding)
        userLabel.frame = CGRect(x: loginLabel.width, y: 0, width: userLabelWidth, height: 30)
        userLabel.textAlignment = .Right
        userLabel.textColor = MaterialColor.white
        let logoutButton = FlatButton(frame: CGRect(x: 65, y: 30, width: 100, height: 30))
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.titleLabel!.font = RobotoFont.mediumWithSize(12)
        loginView.addSubview(loginLabel)
        loginView.addSubview(userLabel)
        loginView.addSubview(logoutButton)
        loginView.backgroundColor = Constants.kMainShade
        let loginNode = ASDisplayNode(viewBlock: { () -> UIView in return loginView })
        
        //Copyright
        let copyrightTextNode = ASTextNode()
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .Center
        let attr = [NSFontAttributeName : UIFont.systemFontOfSize(8.0), NSForegroundColorAttributeName : Constants.kBrightShade, NSParagraphStyleAttributeName: paraStyle]
        copyrightTextNode.attributedString = NSMutableAttributedString(string: "CelScore 1.0.0 Copyrights. Grey Ecology, 2016.", attributes: attr)
        copyrightTextNode.frame = CGRect(x: Constants.kPadding, y: self.view.bottom - 2 * Constants.kPadding, width: maxWidth, height: 20)
        copyrightTextNode.alignSelf = .Center
        
        picker.dataSource = self
        picker.delegate = self
        
        self.node.addSubnode(logoNode)
        self.node.addSubnode(publicOpinionBarNode)
        self.node.addSubnode(consensusBarNode)
        self.node.addSubnode(factsBarNode)
        self.node.addSubnode(pickerNode)
        self.node.addSubnode(publicServiceNode)
        self.node.addSubnode(notificationNode)
        self.node.addSubnode(loginNode)
        self.node.addSubnode(copyrightTextNode)
        
        //SettingsViewModel().getUserRatingsPercentageSignal().start()
        //SettingsViewModel().calculateSocialConsensusSignal().start()
        SettingsViewModel().getSettingSignal(settingType: .DefaultListId).start()
        
        self.view.backgroundColor = Constants.kDarkShade
        self.sideNavigationViewController!.backdropColor = Constants.kDarkShade
        self.sideNavigationViewController!.depth = .Depth1
    }
    
    func setupProgressBarNode(title: String, maxWidth: CGFloat, yPosition: CGFloat) -> ASDisplayNode {
        let factsView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 60))
        factsView.divider = false
        factsView.depth = .Depth1
        let factsLabel = UILabel()
        factsLabel.text = title
        factsLabel.textColor = MaterialColor.white
        factsLabel.font = UIFont(name: factsLabel.font.fontName, size: 12)
        factsView.titleLabel = factsLabel
        factsView.titleLabelInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        let factsBar = YLProgressBar(frame: CGRect(x: Constants.kPadding, y: 35, width: maxWidth - 20, height: 15))
        factsBar.progressTintColor = Constants.kWineShade
        factsBar.type = .Flat
        factsBar.indicatorTextDisplayMode = .Progress
        factsView.addSubview(factsBar)
        factsView.backgroundColor = Constants.kMainShade
        let factsNode = ASDisplayNode(viewBlock: { () -> UIView in return factsView })
        return factsNode
    }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return ListInfo.getCount() }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: ListInfo(rawValue: row)!.name(), attributes: [NSForegroundColorAttributeName : MaterialColor.white])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //self.settingsVM.updateSettingOnLocalStoreSignal(value: row, settingType: .DefaultListId).start()
    }
}