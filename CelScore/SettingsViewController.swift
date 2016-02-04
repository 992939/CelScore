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

    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        let maxWidth = Constants.kMenuWidth - 2 * Constants.kCellPadding
        
        //MARK: Logo
        let logoImageView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: 20, width: maxWidth, height: 160))
        logoImageView.contentsGravity = .ResizeAspect
        logoImageView.divider = false
        logoImageView.image = UIImage(named: "flask_logo")
        logoImageView.depth = .None
        let logoLabel = UILabel()
        logoLabel.text = "*Vote Responsibly."
        logoLabel.font = UIFont(name: logoLabel.font.fontName, size: 8)
        logoImageView.detailLabel = logoLabel
        logoImageView.detailLabelInset = UIEdgeInsets(top: 30, left: 70, bottom: Constants.kCellPadding, right: 40)
        logoImageView.backgroundColor = MaterialColor.white
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoImageView })
        
        //MARK: PublicOpinion
        let publicOpinionView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: logoImageView.bottom + Constants.kCellPadding, width: maxWidth, height: 60))
        publicOpinionView.divider = false
        publicOpinionView.depth = .None
        let opinionLabel = UILabel()
        opinionLabel.text = "#PublicOpinion Completion:"
        opinionLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        publicOpinionView.titleLabel = opinionLabel
        publicOpinionView.titleLabelInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        publicOpinionView.backgroundColor = MaterialColor.white
        let publicOpinionBar = YLProgressBar(frame: CGRect(x: Constants.kCellPadding, y: 35, width: maxWidth - 20, height: 15))
        publicOpinionBar.progressTintColor = MaterialColor.green.darken4
        publicOpinionBar.type = .Flat
        publicOpinionBar.indicatorTextDisplayMode = .Progress
        publicOpinionView.addSubview(publicOpinionBar)
        let publicOpinionNode = ASDisplayNode(viewBlock: { () -> UIView in return publicOpinionView })
        
        //MARK: Consensus
        let consensusView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: publicOpinionView.bottom + Constants.kCellPadding, width: maxWidth, height: 60))
        consensusView.divider = false
        consensusView.depth = .None
        let consensusLabel = UILabel()
        consensusLabel.text = "Overall Social Consensus:"
        consensusLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        consensusView.titleLabel = consensusLabel
        consensusView.titleLabelInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        consensusView.backgroundColor = MaterialColor.white
        let consensusBar = YLProgressBar(frame: CGRect(x: Constants.kCellPadding, y: 35, width: maxWidth - 20, height: 15))
        consensusBar.progressTintColor = MaterialColor.green.darken4
        consensusBar.type = .Flat
        consensusBar.indicatorTextDisplayMode = .Progress
        consensusView.addSubview(consensusBar)
        let consensusNode = ASDisplayNode(viewBlock: { () -> UIView in return consensusView })
        
        //MARK: Random Facts
        let factsView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: consensusView.bottom + Constants.kCellPadding, width: maxWidth, height: 60))
        factsView.divider = false
        factsView.depth = .None
        let factsLabel = UILabel()
        factsLabel.text = "#CitizensThatDontWatchTelevision:"
        factsLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        factsView.titleLabel = factsLabel
        factsView.titleLabelInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        factsView.backgroundColor = MaterialColor.white
        let factsBar = YLProgressBar(frame: CGRect(x: Constants.kCellPadding, y: 35, width: maxWidth - 20, height: 15))
        factsBar.progressTintColor = MaterialColor.green.darken4
        factsBar.type = .Flat
        factsBar.indicatorTextDisplayMode = .Progress
        factsView.addSubview(factsBar)
        let factsNode = ASDisplayNode(viewBlock: { () -> UIView in return factsView })
        
        //MARK: Picker
        let pickerView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: factsView.bottom + Constants.kCellPadding, width: maxWidth, height: 160))
        pickerView.divider = false
        pickerView.depth = .None
        let pickerLabel = UILabel()
        pickerLabel.text = "Main Topic Of Interest:"
        pickerLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        pickerView.titleLabel = pickerLabel
        pickerView.titleLabelInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        pickerView.backgroundColor = MaterialColor.white
        let picker = UIPickerView(frame: CGRect(x: Constants.kCellPadding, y: 35, width: maxWidth - 20, height: 100))
        pickerView.addSubview(picker)
        let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        
        //MARK: PublicService
        let publicServiceView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: pickerView.bottom + Constants.kCellPadding, width: maxWidth, height: 60))
        publicServiceView.divider = false
        publicServiceView.depth = .None
        let publicServiceLabel = UILabel()
        publicServiceLabel.text = "Public Service Mode:"
        publicServiceLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        publicServiceView.titleLabel = publicServiceLabel
        publicServiceView.titleLabelInset = UIEdgeInsets(top: 10, left: 0, bottom: 25, right: 0)
        publicServiceView.backgroundColor = MaterialColor.white
        let publicServiceSwitch = JTMaterialSwitch(size: JTMaterialSwitchSizeSmall, state: JTMaterialSwitchStateOff)
        publicServiceSwitch.thumbOnTintColor = MaterialColor.purple.lighten2
        publicServiceSwitch.trackOnTintColor = MaterialColor.purple.lighten4
        publicServiceSwitch.rippleFillColor = MaterialColor.purple.lighten1
        publicServiceSwitch.center = CGPoint(x: 200, y: 25)
        publicServiceView.addSubview(publicServiceSwitch)
        let publicServiceNode = ASDisplayNode(viewBlock: { () -> UIView in return publicServiceView })
        
        //MARK: LogStatus
        let loginView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: publicServiceView.bottom + Constants.kCellPadding, width: maxWidth, height: 80))
        loginView.divider = false
        loginView.depth = .None
        loginView.backgroundColor = MaterialColor.white
        let loginLabel = UILabel()
        loginLabel.text = "Logged In As: "
        loginLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        loginLabel.frame = CGRect(x: Constants.kCellPadding, y: 0, width: 100, height: 30)
        let userLabel = UILabel()
        userLabel.text = "@GreyEcologist"
        userLabel.font = UIFont(name: logoLabel.font.fontName, size: 12)
        userLabel.frame = CGRect(x: 100, y: 0, width: 120, height: 30)
        userLabel.textAlignment = .Right
        userLabel.textColor = MaterialColor.green.darken2
        let logoutButton = FlatButton(frame: CGRect(x: 65, y: 45, width: 100, height: 30))
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.titleLabel!.font = RobotoFont.mediumWithSize(12)
        loginView.addSubview(loginLabel)
        loginView.addSubview(userLabel)
        loginView.addSubview(logoutButton)
        let loginNode = ASDisplayNode(viewBlock: { () -> UIView in return loginView })
        
        //MARK: Copyright
        let copyrightTextNode = ASTextNode()
        let attr = [NSFontAttributeName : UIFont.systemFontOfSize(8.0), NSForegroundColorAttributeName : MaterialColor.grey.darken3]
        copyrightTextNode.attributedString = NSMutableAttributedString(string: "CelScore 1.0.0 Copyrights. Grey Ecology, 2016.", attributes: attr)
        copyrightTextNode.frame = CGRect(x: 2 * Constants.kCellPadding, y: loginView.bottom + Constants.kCellPadding, width: maxWidth - 20, height: 20)
        
        super.init(node: ASDisplayNode())
        picker.dataSource = self
        picker.delegate = self
        
        self.node.addSubnode(logoNode)
        self.node.addSubnode(publicOpinionNode)
        self.node.addSubnode(consensusNode)
        self.node.addSubnode(factsNode)
        self.node.addSubnode(pickerNode)
        self.node.addSubnode(publicServiceNode)
        self.node.addSubnode(loginNode)
        self.node.addSubnode(copyrightTextNode)
        
        //SettingsViewModel().getUserRatingsPercentageSignal().start()
        //SettingsViewModel().calculateSocialConsensusSignal().start()
        SettingsViewModel().getSettingSignal(settingType: .DefaultListId).start()
    }
    
    //MARK: Method
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.backgroundColor = MaterialColor.grey.lighten1
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