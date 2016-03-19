//
//  SettingsViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/1/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import YLProgressBar
import Material
import BEMCheckBox


final class SettingsViewController: ASViewController, UIPickerViewDelegate, UIPickerViewDataSource, BEMCheckBoxDelegate {
    
    //MARK: Property
    private let picker: UIPickerView
    private let refreshButton: MaterialButton

    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.picker = UIPickerView()
        self.refreshButton = MaterialButton()
        super.init(node: ASDisplayNode())
    }
    
    //MARK: Method
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maxWidth = self.view.width - 2 * Constants.kPadding
        
        //Logo
        let logoView = setupMaterialView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 87))
        logoView.depth = .None
        let logoCircle: MaterialView = MaterialView(frame: CGRect(x: (Constants.kSettingsViewWidth - 70)/2 , y: 10, width: 70, height: 70))
        
        let courtLabel = UILabel(frame: CGRect(x: Constants.kPadding + 5, y: 25, width: 110, height: 40))
        let houseLabel = UILabel(frame: CGRect(x: Constants.kSettingsViewWidth - 110, y: 25, width: 110, height: 40))
        let font = UIFont(name: "Cochin", size: 25.0) ?? UIFont.systemFontOfSize(25.0)
        let attributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : MaterialColor.white]
        courtLabel.attributedText = NSAttributedString(string: "COURT", attributes: attributes)
        houseLabel.attributedText = NSAttributedString(string: "HOUSE", attributes: attributes)

        logoCircle.image = UIImage(named: "court_small_white")
        logoCircle.contentsGravity = "center"
        logoCircle.shape = .Circle
        logoCircle.depth = .Depth2
        logoCircle.backgroundColor = Constants.kDarkGreenShade
        logoView.addSubview(courtLabel)
        logoView.addSubview(houseLabel)
        logoView.addSubview(logoCircle)
        logoView.backgroundColor = Constants.kMainShade
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoView })
        self.node.addSubnode(logoNode)

        //Progress Bars
        let progressNodeHeight: CGFloat = 60.0
        
        SettingsViewModel().calculateSocialConsensusSignal().startWithNext({ value in
            let consensusBarNode = self.setupProgressBarNode("Global Consensus", maxWidth: maxWidth, yPosition: (logoView.bottom + Constants.kPadding), value: value)
            self.node.addSubnode(consensusBarNode)
        })
        
        SettingsViewModel().calculateUserRatingsPercentageSignal().startWithNext({ value in
            let publicOpinionBarNode = self.setupProgressBarNode("Your Public Opinion Ratio", maxWidth: maxWidth, yPosition: logoView.bottom + Constants.kPadding + progressNodeHeight, value: value)
            self.node.addSubnode(publicOpinionBarNode)
        })
        
        SettingsViewModel().calculatePositiveVoteSignal().startWithNext({ value in
            let positiveBarNode = self.setupProgressBarNode("Your Positive Vote Ratio", maxWidth: maxWidth, yPosition: (logoView.bottom + Constants.kPadding + 2 * progressNodeHeight), value: value)
            self.node.addSubnode(positiveBarNode)
        })
        
        //PickerView
        let pickerView = self.setupMaterialView(frame: CGRect(x: Constants.kPadding, y: (logoView.bottom + Constants.kPadding + 3 * progressNodeHeight), width: maxWidth, height: Constants.kPickerViewHeight))
        let pickerLabel = Constants.setupLabel(title: "Your Topic Of Interest", frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 2 * Constants.kPadding, height: 25))
        self.picker.frame = CGRect(x: Constants.kPadding, y: Constants.kPickerY, width: maxWidth - 2 * Constants.kPadding, height: 100)
        self.picker.dataSource = self
        self.picker.delegate = self
        pickerView.addSubview(pickerLabel)
        pickerView.addSubview(self.picker)
        let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        self.node.addSubnode(pickerNode)
        
        //Check Boxes
        let publicNodeHeight = logoView.bottom + Constants.kPickerViewHeight + 2 * Constants.kPadding + 3 * progressNodeHeight
        
        SettingsViewModel().getSettingSignal(settingType: .PublicService)
            .startWithNext({ status in
                let publicServiceNode = self.setupCheckBoxNode("Public Service", tag:0, maxWidth: maxWidth, yPosition: publicNodeHeight, status: (status as! Bool))
                self.node.addSubnode(publicServiceNode)
            })
        
        SettingsViewModel().getSettingSignal(settingType: .ConsensusBuilding)
            .startWithNext({ status in
                let notificationNode = self.setupCheckBoxNode("Consensus Building", tag:1, maxWidth: maxWidth, yPosition: publicNodeHeight + 40, status: (status as! Bool))
                self.node.addSubnode(notificationNode)
            })
        
        //Login Status
        let loginView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 75 + Constants.kPadding, width: maxWidth, height: 60))
        let loginLabel = Constants.setupLabel(title: "Logged As:", frame: CGRect(x: Constants.kPadding, y: 0, width: 110, height: 30))
        let userLabelWidth = maxWidth - (loginLabel.width + Constants.kPadding)
        SettingsViewModel().loggedInAsSignal().startWithNext { username in
            let userLabel = Constants.setupLabel(title: username, frame: CGRect(x: loginLabel.width, y: 0, width: userLabelWidth, height: 30))
            userLabel.textAlignment = .Right
            let logoutButton = FlatButton(frame: CGRect(x: Constants.kScreenWidth/2 - 100, y: 30, width: 100, height: 30))
            logoutButton.setTitle("Logout", forState: .Normal)
            logoutButton.addTarget(self, action: "logout", forControlEvents: .TouchUpInside)
            logoutButton.setTitleColor(Constants.kWineShade, forState: .Normal)
            logoutButton.titleLabel!.font = UIFont(name: logoutButton.titleLabel!.font.fontName, size: 16)
            loginView.addSubview(loginLabel)
            loginView.addSubview(userLabel)
            loginView.addSubview(logoutButton)
            let loginNode = ASDisplayNode(viewBlock: { () -> UIView in return loginView })
            self.node.addSubnode(loginNode)
        }
        
        //Copyright
        let copyrightTextNode = ASTextNode()
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .Center
        let attr = [NSFontAttributeName : UIFont.systemFontOfSize(12.0), NSForegroundColorAttributeName : Constants.kWineShade, NSParagraphStyleAttributeName: paraStyle]
        copyrightTextNode.attributedString = NSMutableAttributedString(string: "CelScore \(NSBundle.mainBundle().releaseVersionNumber!) by Grey Ecology, LLC.", attributes: attr)
        copyrightTextNode.frame = CGRect(x: Constants.kPadding, y: self.view.bottom - 2 * Constants.kPadding, width: maxWidth, height: 20)
        copyrightTextNode.alignSelf = .Center
        
        self.node.addSubnode(copyrightTextNode)
        self.view.backgroundColor = Constants.kDarkShade
        self.sideNavigationController!.depth = .Depth1
    }
    
    //MARK: Methods
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SettingsViewModel().getSettingSignal(settingType: .DefaultListIndex)
            .startWithNext({ index in self.picker.selectRow(index as! Int, inComponent: 0, animated: true) })
    }
    
    func logout() { UserViewModel().logoutSignal(.Facebook).start() }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return ListInfo.getCount() }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: ListInfo(rawValue: row)!.name(), attributes: [NSForegroundColorAttributeName : MaterialColor.white])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SettingsViewModel().updateSettingSignal(value: row, settingType: .DefaultListIndex).start()
    }
    
    //MARK: BEMCheckBoxDelegate 
    func didTapCheckBox(checkBox: BEMCheckBox) {
        SettingsViewModel().updateSettingSignal(value: checkBox.on, settingType: (checkBox.tag == 0 ? .PublicService : .ConsensusBuilding)).start()
        if checkBox.on {
            SettingsViewModel().getSettingSignal(settingType: checkBox.tag == 0 ? .FirstPublic : .FirstRoad).startWithNext({ first in
                let firstTime = first as! Bool
                if firstTime {
                    if checkBox.tag == 0 {
                        TAOverlay.showOverlayWithLabel(OverlayInfo.FirstPublic.message(),
                            image: UIImage(named: OverlayInfo.FirstPublic.logo()),
                            options: OverlayInfo.getOptions())
                    } else {
                        TAOverlay.showOverlayWithLabel(OverlayInfo.FirstConsensus.message(),
                            image: UIImage(named: OverlayInfo.FirstConsensus.logo()),
                            options: OverlayInfo.getOptions())
                    }
                    TAOverlay.setCompletionBlock({ _ in
                        SettingsViewModel().updateSettingSignal(value: false, settingType: checkBox.tag == 0 ? .FirstPublic : .FirstRoad)
                    })
                }
            })
        }
    }
    
    //MARK: DidLayoutSubviews Helpers
    func setupMaterialView(frame frame: CGRect) -> MaterialView {
        let materialView = MaterialView(frame: frame)
        materialView.depth = .Depth1
        materialView.backgroundColor = Constants.kMainShade
        return materialView
    }
    
    func setupCheckBoxNode(title: String, tag: Int, maxWidth: CGFloat, yPosition: CGFloat, status: Bool) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 30))
        let publicServiceLabel = Constants.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 30, height: 30))
        let box = BEMCheckBox(frame: CGRect(x: maxWidth - 30, y: 5, width: 20, height: 20))
        box.delegate = self
        box.tag = tag
        box.onAnimationType = .Bounce
        box.offAnimationType = .Bounce
        box.onCheckColor = MaterialColor.white
        box.onFillColor = Constants.kDarkGreenShade
        box.onTintColor = Constants.kDarkGreenShade
        box.setOn(status, animated: true)
        materialView.addSubview(publicServiceLabel)
        materialView.addSubview(box)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
    
    func setupProgressBarNode(title: String, maxWidth: CGFloat, yPosition: CGFloat, value: CGFloat) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 50))
        let factsLabel = Constants.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 2 * Constants.kPadding, height: 25))
        let factsBar = YLProgressBar(frame: CGRect(x: Constants.kPadding, y: factsLabel.bottom, width: maxWidth - 2 * Constants.kPadding, height: 15))
        factsBar.progressTintColors = [Constants.kWineShade, Constants.kDarkGreenShade]
        factsBar.setProgress(value, animated: true)
        factsBar.type = .Flat
        factsBar.indicatorTextDisplayMode = .Progress
        materialView.addSubview(factsLabel)
        materialView.addSubview(factsBar)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
}