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
import AIRTimer
import OpinionzAlertView


final class SettingsViewController: ASViewController, UIPickerViewDelegate, UIPickerViewDataSource, BEMCheckBoxDelegate, Labelable {
    
    //MARK: Property
    private let picker: UIPickerView
    private let fact1Bar: YLProgressBar
    private let fact2Bar: YLProgressBar
    private let fact3Bar: YLProgressBar

    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.picker = UIPickerView()
        self.fact1Bar = YLProgressBar()
        self.fact2Bar = YLProgressBar()
        self.fact3Bar = YLProgressBar()
        super.init(node: ASDisplayNode())
    }
    
    //MARK: Method
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maxWidth = self.view.width - 2 * Constants.kPadding
        
        //Logo
        let logoView = setupMaterialView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 87))
        logoView.depth = .None
        let logoCircle: MaterialButton = MaterialButton(frame: CGRect(x: (Constants.kSettingsViewWidth - 60)/2 , y: 14, width: 60, height: 60))
        logoCircle.setImage(R.image.court_white()!, forState: .Normal)
        logoCircle.setImage(R.image.court_white()!, forState: .Highlighted)
        logoCircle.shape = .Circle
        logoCircle.depth = .Depth2
        logoCircle.backgroundColor = Constants.kDarkGreenShade
        logoCircle.addTarget(self, action: #selector(SettingsViewController.refreshAction), forControlEvents: .TouchUpInside)
        
        let courtLabel = UILabel(frame: CGRect(x: 2 * Constants.kPadding, y: 25, width: 110, height: 40))
        let houseLabel = UILabel(frame: CGRect(x: Constants.kSettingsViewWidth - 115, y: 25, width: 110, height: 40))
        let font = UIFont(name: "Cochin", size: 25.0) ?? UIFont.systemFontOfSize(25.0)
        let attributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : MaterialColor.white]
        courtLabel.attributedText = NSAttributedString(string: "COURT", attributes: attributes)
        houseLabel.attributedText = NSAttributedString(string: "HOUSE", attributes: attributes)
        logoView.addSubview(courtLabel)
        logoView.addSubview(houseLabel)
        logoView.addSubview(logoCircle)
        logoView.backgroundColor = Constants.kMainShade
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoView })
        self.node.addSubnode(logoNode)

        //Progress Bars
        let progressNodeHeight: CGFloat = 60.0
        
        SettingsViewModel().calculateSocialConsensusSignal().startWithNext({ value in
            let consensusBarNode = self.setupProgressBarNode(title: "Global Consensus", maxWidth: maxWidth, yPosition: (logoView.bottom + Constants.kPadding), value: value, bar: self.fact1Bar)
            self.node.addSubnode(consensusBarNode)
        })
        
        SettingsViewModel().calculateUserRatingsPercentageSignal().startWithNext({ value in
            let publicOpinionBarNode = self.setupProgressBarNode(title: "Your Public Opinion Ratio", maxWidth: maxWidth, yPosition: logoView.bottom + Constants.kPadding + progressNodeHeight, value: value, bar: self.fact2Bar)
            self.node.addSubnode(publicOpinionBarNode)
        })
        
        SettingsViewModel().calculatePositiveVoteSignal().startWithNext({ value in
            let positiveBarNode = self.setupProgressBarNode(title: "Your Positive Vote Ratio", maxWidth: maxWidth, yPosition: (logoView.bottom + Constants.kPadding + 2 * progressNodeHeight), value: value, bar: self.fact3Bar)
            self.node.addSubnode(positiveBarNode)
        })
        
        //PickerView
        let pickerView = self.setupMaterialView(frame: CGRect(x: Constants.kPadding, y: (logoView.bottom + Constants.kPadding + 3 * progressNodeHeight), width: maxWidth, height: Constants.kPickerViewHeight))
        let pickerLabel = self.setupLabel(title: "Your Topic Of Interest", frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 2 * Constants.kPadding, height: 25))
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
                let publicServiceNode = self.setupCheckBoxNode(title: "Public Service", tag:0, maxWidth: maxWidth, yPosition: publicNodeHeight, status: (status as! Bool))
                self.node.addSubnode(publicServiceNode)
            })
        
        SettingsViewModel().getSettingSignal(settingType: .ConsensusBuilding)
            .startWithNext({ status in
                let notificationNode = self.setupCheckBoxNode(title: "Consensus Building", tag:1, maxWidth: maxWidth, yPosition: publicNodeHeight + 40, status: (status as! Bool))
                self.node.addSubnode(notificationNode)
            })
        
        //Logout
        let logoutView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 75 + Constants.kPadding, width: maxWidth, height: 40))
        let logoutButton = FlatButton(frame: CGRect(x: Constants.kScreenWidth/2 - 100, y: Constants.kPadding/2, width: 100, height: 30))
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.addTarget(self, action: #selector(SettingsViewController.logout), forControlEvents: .TouchUpInside)
        logoutButton.setTitleColor(Constants.kWineShade, forState: .Normal)
        logoutButton.pulseColor = Constants.kWineShade
        logoutView.addSubview(logoutButton)
        logoutButton.titleLabel!.font = UIFont(name: logoutButton.titleLabel!.font.fontName, size: 16)
        let logoutNode = ASDisplayNode(viewBlock: { () -> UIView in return logoutView })
        self.node.addSubnode(logoutNode)
        
        self.view.backgroundColor = Constants.kDarkShade
        self.sideNavigationController!.depth = .Depth1
    }
    
    //MARK: Methods
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SettingsViewModel().getSettingSignal(settingType: .DefaultListIndex)
            .startWithNext({ index in self.picker.selectRow(index as! Int, inComponent: 0, animated: true) })
    }
    
    func logout() {
        let logoutAlert = OpinionzAlertView(title: nil, message: "Some of your votes might get lost, are you sure you want to continue?", cancelButtonTitle: "Log Out", otherButtonTitles: ["Cancel"])
            { (_, index: Int) -> Void in if index == 0 {
                UserViewModel().logoutSignal().startWithNext({ _ in
                    TAOverlay.showOverlayWithLabel(OverlayInfo.LogoutUser.message(), image: OverlayInfo.LogoutUser.logo(), options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in self.sideNavigationController!.closeLeftView() })
                    })
                }}
        logoutAlert.iconType = OpinionzAlertIconWarning
        logoutAlert.show()
    }
    
    func refreshAction() {
        self.fact1Bar.setProgress(0, animated: true)
        self.fact2Bar.setProgress(0, animated: true)
        self.fact3Bar.setProgress(0, animated: true)
        AIRTimer.after(2.0){ _ in
            SettingsViewModel().calculateSocialConsensusSignal().startWithNext({ value in self.fact1Bar.setProgress(value, animated: true) })
            SettingsViewModel().calculateUserRatingsPercentageSignal().startWithNext({ value in self.fact2Bar.setProgress(value, animated: true) })
            SettingsViewModel().calculatePositiveVoteSignal().startWithNext({ value in self.fact3Bar.setProgress(value, animated: true) })
        }
    }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return ListInfo.getCount() }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: ListInfo(rawValue: row)!.name(), attributes: [NSForegroundColorAttributeName : MaterialColor.white])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SettingsViewModel().updateSettingSignal(value: row, settingType: .DefaultListIndex).start()
        SettingsViewModel().getSettingSignal(settingType: .FirstInterest).startWithNext({ first in let firstTime = first as! Bool
            if firstTime {
                TAOverlay.showOverlayWithLabel(OverlayInfo.FirstInterest.message(),
                    image: OverlayInfo.FirstInterest.logo(),
                    options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstInterest).start() })
            }
        })
    }
    
    //MARK: BEMCheckBoxDelegate
    func didTapCheckBox(checkBox: BEMCheckBox) {
        SettingsViewModel().updateSettingSignal(value: checkBox.on, settingType: (checkBox.tag == 0 ? .PublicService : .ConsensusBuilding)).start()
        if checkBox.on {
            SettingsViewModel().getSettingSignal(settingType: checkBox.tag == 0 ? .FirstPublic : .FirstConsensus).startWithNext({ first in
                let firstTime = first as! Bool
                if firstTime {
                    if checkBox.tag == 0 {
                        TAOverlay.showOverlayWithLabel(OverlayInfo.FirstPublic.message(), image: OverlayInfo.FirstPublic.logo(), options: OverlayInfo.getOptions())
                        TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstPublic).start() })
                    } else {
                        TAOverlay.showOverlayWithLabel(OverlayInfo.FirstConsensus.message(), image: OverlayInfo.FirstConsensus.logo(), options: OverlayInfo.getOptions())
                        TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstConsensus).start() })
                    }
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
    
    func setupCheckBoxNode(title title: String, tag: Int, maxWidth: CGFloat, yPosition: CGFloat, status: Bool) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 30))
        let publicServiceLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 30, height: 30))
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
    
    func setupProgressBarNode(title title: String, maxWidth: CGFloat, yPosition: CGFloat, value: CGFloat, bar: YLProgressBar) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 50))
        let factsLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 2 * Constants.kPadding, height: 25))
        bar.frame = CGRect(x: Constants.kPadding, y: factsLabel.bottom, width: maxWidth - 2 * Constants.kPadding, height: 15)
        bar.progressTintColors = [Constants.kWineShade, Constants.kDarkGreenShade]
        bar.setProgress(value, animated: true)
        bar.type = .Flat
        bar.indicatorTextDisplayMode = .Progress
        materialView.addSubview(factsLabel)
        materialView.addSubview(bar)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
}