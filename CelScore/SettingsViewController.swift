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
    let kMaxWidth = Constants.kMenuWidth - 2 * Constants.kCellPadding
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.settingsVM = SettingsViewModel()
        
        //MARK: Logo
        let logoImageView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: 35, width: kMaxWidth, height: 160))
        logoImageView.image = UIImage(named: "flask_logo")
        logoImageView.depth = .Depth1
        let logoLabel = UILabel()
        logoLabel.text = "*Vote Responsibly."
        logoImageView.detailLabel = logoLabel
        logoImageView.backgroundColor = MaterialColor.white
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoImageView })
        
        //MARK: PublicOpinion
        let publicOpinionView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: logoImageView.bottom, width: kMaxWidth, height: 60))
        publicOpinionView.depth = .Depth1
        let opinionLabel = UILabel()
        opinionLabel.text = "#PublicOpinion Completion:"
        publicOpinionView.titleLabel = opinionLabel
        publicOpinionView.backgroundColor = MaterialColor.white
        
        let publicOpinionBar = YLProgressBar(frame: CGRect(x: 2 * Constants.kCellPadding, y: logoImageView.bottom + Constants.kCellPadding, width: kMaxWidth - 20, height: 15))
        publicOpinionBar.progressTintColor = MaterialColor.green.darken4
        publicOpinionBar.type = .Flat
        publicOpinionBar.indicatorTextDisplayMode = .Progress
        publicOpinionView.addSubview(publicOpinionBar)
        
        let publicOpinionNode = ASDisplayNode(viewBlock: { () -> UIView in return publicOpinionView })
        
        //MARK: Consensus
        let consensusView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: publicOpinionView.bottom, width: kMaxWidth, height: 60))
        consensusView.depth = .Depth1
        let consensusLabel = UILabel()
        consensusLabel.text = "Overall Social Consensus:"
        consensusView.titleLabel = consensusLabel
        consensusView.backgroundColor = MaterialColor.white
        
        let consensusBar = YLProgressBar(frame: CGRect(x: 2 * Constants.kCellPadding, y: publicOpinionView.bottom + Constants.kCellPadding, width: kMaxWidth - 20, height: 15))
        consensusBar.progressTintColor = MaterialColor.green.darken4
        consensusBar.type = .Flat
        consensusBar.indicatorTextDisplayMode = .Progress
        consensusView.addSubview(consensusBar)
        
        let consensusNode = ASDisplayNode(viewBlock: { () -> UIView in return consensusView })
        
        //MARK: Random Facts
        let factsView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: consensusView.bottom, width: kMaxWidth, height: 60))
        factsView.depth = .Depth1
        let factsLabel = UILabel()
        factsLabel.text = "#CitizensThatDontWatchTelevision:"
        factsView.titleLabel = factsLabel
        factsView.backgroundColor = MaterialColor.white
        
        let factsBar = YLProgressBar(frame: CGRect(x: 2 * Constants.kCellPadding, y: consensusView.bottom + Constants.kCellPadding, width: kMaxWidth - 20, height: 15))
        factsBar.progressTintColor = MaterialColor.green.darken4
        factsBar.type = .Flat
        factsBar.indicatorTextDisplayMode = .Progress
        factsView.addSubview(factsBar)
        
        let factsNode = ASDisplayNode(viewBlock: { () -> UIView in return factsView })
        
        //MARK: Picker
        let pickerView: MaterialView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: factsView.bottom, width: kMaxWidth, height: 160))
        pickerView.depth = .Depth1
        let pickerLabel = UILabel()
        pickerLabel.text = "Main Topic Of Interest:"
        pickerView.addSubview(pickerLabel)
        pickerView.backgroundColor = MaterialColor.white
        let picker = UIPickerView(frame: CGRect(x: 2 * Constants.kCellPadding, y: factsView.bottom  + Constants.kCellPadding, width: kMaxWidth - 20, height: 100))
        pickerView.addSubview(picker)
        
        let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        
        //MARK: PublicService
        let publicServiceView: ImageCardView = ImageCardView(frame: CGRect(x: Constants.kCellPadding, y: pickerView.bottom, width: kMaxWidth, height: 60))
        publicServiceView.depth = .Depth1
        let publicServiceLabel = UILabel()
        publicServiceLabel.text = "Public Service Mode:"
        publicServiceView.titleLabel = publicServiceLabel
        publicServiceView.backgroundColor = MaterialColor.white
        
        let publicServiceSwitch = JTMaterialSwitch(size: JTMaterialSwitchSizeSmall, state: JTMaterialSwitchStateOff)
        publicServiceSwitch.thumbOnTintColor = MaterialColor.purple.lighten2
        publicServiceSwitch.trackOnTintColor = MaterialColor.purple.lighten4
        publicServiceSwitch.rippleFillColor = MaterialColor.purple.lighten1
        publicServiceSwitch.center = CGPoint(x: 205, y: pickerView.bottom + Constants.kCellPadding)
        publicServiceView.addSubview(publicServiceSwitch)
        
        let publicServiceNode = ASDisplayNode(viewBlock: { () -> UIView in return publicServiceView })
        
        //MARK: LogStatus
        let loginView: MaterialView = MaterialView(frame: CGRect(x: Constants.kCellPadding, y: publicServiceView.bottom, width: kMaxWidth, height: 80))
        loginView.depth = .Depth1
        let loginLabel = UILabel()
        loginLabel.text = "Logged In As: "
        let userLabel = UILabel()
        userLabel.text = "@GreyEcologist"
        userLabel.textColor = MaterialColor.green.darken2
        loginView.addSubview(loginLabel)
        loginView.addSubview(userLabel)
        loginView.backgroundColor = MaterialColor.white
        
        let logoutButton = FlatButton(frame: CGRect(x: 70, y: publicServiceView.bottom + 45, width: 120, height: 30))
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.titleLabel!.font = RobotoFont.mediumWithSize(12)
        loginView.addSubview(logoutButton)
        
        let loginNode = ASDisplayNode(viewBlock: { () -> UIView in return loginView })
        
        //MARK: Copyright
        let copyrightTextNode = ASTextNode()
        let attr = [NSFontAttributeName : UIFont.systemFontOfSize(9.0), NSForegroundColorAttributeName : MaterialColor.grey.darken3]
        copyrightTextNode.attributedString = NSMutableAttributedString(
            string: "CelScore 1.0.0 Copyrights. Grey Ecology, 2016.", attributes: attr)
        copyrightTextNode.frame = CGRect(x: 2 * Constants.kCellPadding, y: loginView.bottom + Constants.kCellPadding, width: kMaxWidth - 20, height: 20)
        
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