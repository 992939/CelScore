//
//  SettingsViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/1/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import YLProgressBar
import Material
import BEMCheckBox
import AIRTimer
import PMAlertController
import ReactiveCocoa


final class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, BEMCheckBoxDelegate, Labelable {
    
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
        super.init(nibName: nil, bundle: nil)
    }
    
    //MARK: Method
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maxWidth: CGFloat = self.view.width - 2 * Constants.kPadding
        
        //Logo
        let logoView: MaterialView = setupMaterialView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 87 - 2 * UIDevice.getOffset()))
        logoView.depth = .None
        let diameter = 60 - 2 * UIDevice.getOffset()
        let logoCircle: MaterialButton = MaterialButton(frame: CGRect(x: (Constants.kSettingsViewWidth - diameter)/2 , y: 15 - UIDevice.getOffset()/2, width: diameter, height: diameter))
        logoCircle.setImage(R.image.court_white()!, forState: .Normal)
        logoCircle.setImage(R.image.court_white()!, forState: .Highlighted)
        logoCircle.shape = .Circle
        logoCircle.depth = .Depth2
        logoCircle.backgroundColor = Constants.kDarkGreenShade
        logoCircle.addTarget(self, action: #selector(SettingsViewController.refreshAction), forControlEvents: .TouchUpInside)
        
        let labelWidth: CGFloat = (self.view.width - logoCircle.width)/2
        let courtLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 28 - 1.1 * UIDevice.getOffset(), width: labelWidth, height: 40))
        courtLabel.textAlignment = .Center
        let houseLabel: UILabel = UILabel(frame: CGRect(x: Constants.kSettingsViewWidth - labelWidth, y: 28 - 1.1 * UIDevice.getOffset(), width: labelWidth, height: 40))
        houseLabel.textAlignment = .Center
        let font: UIFont = UIFont(name: "Cochin-Bold", size: 25.0) ?? UIFont.systemFontOfSize(23.0)
        let attributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : MaterialColor.white]
        courtLabel.attributedText = NSAttributedString(string: "COURT", attributes: attributes)
        courtLabel.backgroundColor = Constants.kMainShade
        houseLabel.attributedText = NSAttributedString(string: "HOUSE", attributes: attributes)
        houseLabel.backgroundColor = Constants.kMainShade
        logoView.addSubview(courtLabel)
        logoView.addSubview(houseLabel)
        logoView.addSubview(logoCircle)
        logoView.backgroundColor = Constants.kMainShade
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoView })
        self.view.addSubnode(logoNode)

        //Progress Bars
        let progressNodeHeight: CGFloat = 60.0
        
        SettingsViewModel().calculateSocialConsensusSignal().startWithNext({ value in
            let consensusBarNode = self.setupProgressBarNode(title: "Universal Consensus %", maxWidth: maxWidth, yPosition: (logoView.bottom + Constants.kPadding), value: value, bar: self.fact1Bar)
            self.view.addSubnode(consensusBarNode) })
        
        SettingsViewModel().calculateUserRatingsPercentageSignal()
            .on(next: { value in
                let publicOpinionBarNode = self.setupProgressBarNode(title: "Your Public Opinion %", maxWidth: maxWidth, yPosition: logoView.bottom + Constants.kPadding + progressNodeHeight, value: value, bar: self.fact2Bar)
                self.view.addSubnode(publicOpinionBarNode) })
            .filter({ (value: CGFloat) -> Bool in return value == 100.0 })
            .promoteErrors(NSError)
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return SettingsViewModel().getSettingSignal(settingType: .FirstCompleted) }
            .on(next: { first in let firstTime = first as! Bool
                if firstTime {
                    TAOverlay.showOverlayWithLabel(OverlayInfo.FirstCompleted.message(),
                        image: OverlayInfo.FirstCompleted.logo(),
                        options: OverlayInfo.getOptions())
                    TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstCompleted).start() })
                }
            })
            .start()
        
        SettingsViewModel().calculatePositiveVoteSignal().startWithNext({ value in
            let positiveBarNode = self.setupProgressBarNode(title: "Your Positive Votes %", maxWidth: maxWidth, yPosition: (logoView.bottom + Constants.kPadding + 2 * progressNodeHeight), value: value, bar: self.fact3Bar)
            self.view.addSubnode(positiveBarNode)
        })
        
        //PickerView
        let pickerView: MaterialView = self.setupMaterialView(frame: CGRect(x: Constants.kPadding, y: (logoView.bottom + Constants.kPadding + 3 * progressNodeHeight), width: maxWidth, height: Constants.kPickerViewHeight))
        let pickerLabel: UILabel = self.setupLabel(title: "Your Realm Of Interest", frame: CGRect(x: Constants.kPadding, y: 0, width: 180, height: 25))
        self.picker.frame = CGRect(x: Constants.kPadding, y: Constants.kPickerY, width: maxWidth - 2 * Constants.kPadding, height: 100)
        self.picker.dataSource = self
        self.picker.delegate = self
        pickerView.addSubview(pickerLabel)
        pickerView.addSubview(self.picker)
        let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        self.view.addSubnode(pickerNode)
        
        //Check Boxes
        let publicNodeHeight = logoView.bottom + Constants.kPickerViewHeight + 2 * Constants.kPadding + 3 * progressNodeHeight
        
        SettingsViewModel().getSettingSignal(settingType: .PublicService)
            .startWithNext({ status in
                let publicServiceNode = self.setupCheckBoxNode(title: "Public Service", tag: 0, maxWidth: maxWidth, yPosition: publicNodeHeight, status: (status as! Bool))
                self.view.addSubnode(publicServiceNode)
            })
        
        SettingsViewModel().getSettingSignal(settingType: .ConsensusBuilding)
            .startWithNext({ status in
                let notificationNode = self.setupCheckBoxNode(title: "Building Consensus", tag: 1, maxWidth: maxWidth, yPosition: publicNodeHeight + 50, status: (status as! Bool))
                self.view.addSubnode(notificationNode)
            })
        
        //Logout
        let logoutView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 90 + Constants.kPadding, width: maxWidth, height: 40))
        let logoutButton = FlatButton(frame: CGRect(x: 2*Constants.kPadding, y: Constants.kPadding/2, width: maxWidth - 4 * Constants.kPadding, height: 30))
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.addTarget(self, action: #selector(SettingsViewController.logout), forControlEvents: .TouchUpInside)
        logoutButton.setTitleColor(Constants.kWineShade, forState: .Normal)
        logoutButton.titleLabel?.textAlignment = .Center
        logoutButton.pulseColor = Constants.kWineShade
        logoutView.addSubview(logoutButton)
        logoutButton.titleLabel!.font = UIFont(name: logoutButton.titleLabel!.font.fontName, size: 16)
        let logoutNode = ASDisplayNode(viewBlock: { () -> UIView in return logoutView })
        self.view.addSubnode(logoutNode)
        
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
        let alertVC = PMAlertController(title: "Warning", description: "Your votes and settings might get lost. Are you sure you want to continue?", image: R.image.spaceship_green_big()!, style: .Alert)
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .Cancel, action: nil))
        alertVC.addAction(PMAlertAction(title: "Log Out", style: .Default, action: { () in
            UserViewModel().logoutSignal().startWithNext({ _ in
                MaterialAnimation.delay(1.0) { TAOverlay.showOverlayWithLabel(OverlayInfo.LogoutUser.message(), image: OverlayInfo.LogoutUser.logo(), options: OverlayInfo.getOptions()) }
                TAOverlay.setCompletionBlock({ _ in self.sideNavigationController!.closeLeftView() })
                })
        }))
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func refreshAction(button: MaterialButton) {
        button.enabled = false
        self.fact1Bar.setProgress(0, animated: true)
        self.fact2Bar.setProgress(0, animated: true)
        self.fact3Bar.setProgress(0, animated: true)
        AIRTimer.after(2.0){ _ in
            SettingsViewModel().calculateSocialConsensusSignal().startWithNext({ value in self.fact1Bar.setProgress(value, animated: true) })
            SettingsViewModel().calculateUserRatingsPercentageSignal().startWithNext({ value in self.fact2Bar.setProgress(value, animated: true) })
            SettingsViewModel().calculatePositiveVoteSignal().startWithNext({ value in self.fact3Bar.setProgress(value, animated: true) })
            button.enabled = true
        }
    }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return ListInfo.getCount() }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: ListInfo(rawValue: row)!.name(), attributes: [NSForegroundColorAttributeName : MaterialColor.white, NSBackgroundColorAttributeName : Constants.kMainShade])
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
                        TAOverlay.showOverlayWithLabel(OverlayInfo.FirstConsensus.message(), image:  OverlayInfo.FirstConsensus.logo(), options: OverlayInfo.getOptions())
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
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 40))
        let publicServiceLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: 180, height: 40))
        let box = BEMCheckBox(frame: CGRect(x: maxWidth - 40, y: 5, width: 30, height: 30))
        box.delegate = self
        box.tag = tag
        box.onAnimationType = .Bounce
        box.offAnimationType = .Bounce
        box.onCheckColor = MaterialColor.white
        box.onFillColor = Constants.kDarkGreenShade
        box.onTintColor = Constants.kDarkGreenShade
        box.tintColor = Constants.kDarkGreenShade
        box.backgroundColor = Constants.kMainShade
        box.setOn(status, animated: true)
        materialView.addSubview(publicServiceLabel)
        materialView.addSubview(box)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
    
    func setupProgressBarNode(title title: String, maxWidth: CGFloat, yPosition: CGFloat, value: CGFloat, bar: YLProgressBar) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 50))
        let factsLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: 180, height: 25))
        bar.frame = CGRect(x: Constants.kPadding, y: factsLabel.bottom, width: maxWidth - 2 * Constants.kPadding, height: 15)
        bar.progressTintColors = [Constants.kWineShade, Constants.kDarkGreenShade]
        bar.setProgress(value, animated: true)
        bar.type = .Flat
        bar.backgroundColor = Constants.kMainShade
        bar.indicatorTextDisplayMode = .Progress
        materialView.addSubview(factsLabel)
        materialView.addSubview(bar)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
}