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
import MessageUI
import SafariServices


final class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, BEMCheckBoxDelegate, Labelable, Supportable, MFMailComposeViewControllerDelegate, SFSafariViewControllerDelegate {
    
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
        let maxWidth: CGFloat = Constants.kSettingsViewWidth - 2 * Constants.kPadding
        
        //Logo
        let logoView: MaterialView = setupMaterialView(frame: CGRect(x: 0, y: 0, width: Constants.kSettingsViewWidth, height: 70 - 2 * UIDevice.getOffset()))
        logoView.depth = .None
        let diameter = 60 - 2 * UIDevice.getOffset()
        let logoCircle: MaterialButton = MaterialButton(frame: CGRect(x: (Constants.kSettingsViewWidth - diameter)/2 , y: 5 - UIDevice.getOffset()/2, width: diameter, height: diameter))
        logoCircle.setImage(R.image.court_white()!, forState: .Normal)
        logoCircle.setImage(R.image.court_white()!, forState: .Highlighted)
        logoCircle.shape = .Circle
        logoCircle.depth = .Depth2
        logoCircle.backgroundColor = Constants.kRedShade
        logoCircle.addTarget(self, action: #selector(SettingsViewController.refreshAction), forControlEvents: .TouchUpInside)
        
        let labelWidth: CGFloat = (Constants.kSettingsViewWidth - logoCircle.width)/2
        let courtLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 17 - 1.1 * UIDevice.getOffset(), width: labelWidth, height: 40))
        courtLabel.textAlignment = .Center
        let houseLabel: UILabel = UILabel(frame: CGRect(x: Constants.kSettingsViewWidth - labelWidth, y: 17 - 1.1 * UIDevice.getOffset(), width: labelWidth, height: 40))
        houseLabel.textAlignment = .Center
        let font: UIFont = UIFont(name: "Cochin-Bold", size: 25.0) ?? UIFont.systemFontOfSize(23.0)
        let attributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : MaterialColor.white]
        courtLabel.attributedText = NSAttributedString(string: "COURT", attributes: attributes)
        courtLabel.backgroundColor = Constants.kBlueShade
        houseLabel.attributedText = NSAttributedString(string: "HOUSE", attributes: attributes)
        houseLabel.backgroundColor = Constants.kBlueShade
        logoView.addSubview(courtLabel)
        logoView.addSubview(houseLabel)
        logoView.addSubview(logoCircle)
        logoView.layer.shadowColor = MaterialColor.black.CGColor
        logoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoView.layer.shadowOpacity = 0.1
        logoView.backgroundColor = Constants.kBlueShade
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoView })
        self.view.addSubnode(logoNode)

        //Progress Bars
        let progressNodeHeight: CGFloat = 60.0
        
        SettingsViewModel().calculateSocialConsensusSignal().startWithNext({ value in
            let consensusBarNode = self.setupProgressBarNode(title: "General Consensus %", maxWidth: maxWidth, yPosition: (logoView.bottom + Constants.kPadding), value: value, bar: self.fact1Bar)
            self.view.addSubnode(consensusBarNode) })
        
        SettingsViewModel().calculateUserRatingsPercentageSignal().startWithNext({ value in
            let publicOpinionBarNode = self.setupProgressBarNode(title: "Your Public Opinion %", maxWidth: maxWidth, yPosition: logoView.bottom + Constants.kPadding + progressNodeHeight, value: value, bar: self.fact2Bar)
            self.view.addSubnode(publicOpinionBarNode) })
        
        SettingsViewModel().calculatePositiveVoteSignal().startWithNext({ value in
            let positiveBarNode = self.setupProgressBarNode(title: "Your Positive Votes %", maxWidth: maxWidth, yPosition: (logoView.bottom + Constants.kPadding + 2 * progressNodeHeight), value: value, bar: self.fact3Bar)
            self.view.addSubnode(positiveBarNode)
        })
        
        //PickerView
        let pickerView: MaterialView = self.setupMaterialView(frame: CGRect(x: Constants.kPadding, y: (logoView.bottom + Constants.kPadding + 3 * progressNodeHeight), width: maxWidth, height: UIDevice.getPickerHeight()))
        let pickerLabel: UILabel = self.setupLabel(title: "Main Interest", frame: CGRect(x: Constants.kPadding, y: 0, width: 180, height: 25))
        self.picker.frame = CGRect(x: Constants.kPadding, y: Constants.kPickerY, width: maxWidth - 2 * Constants.kPadding, height: 100)
        self.picker.dataSource = self
        self.picker.delegate = self
        pickerView.addSubview(pickerLabel)
        pickerView.addSubview(self.picker)
        let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        self.view.addSubnode(pickerNode)
        
        //Check Boxes
        let publicNodeHeight = logoView.bottom + UIDevice.getPickerHeight() + 2 * Constants.kPadding + 3 * progressNodeHeight
        
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
        
        //Issue
        let issueView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 90 + Constants.kPadding, width: maxWidth, height: 30))
        let issueButton = FlatButton(frame: CGRect(x: 2*Constants.kPadding, y: Constants.kPadding/4, width: maxWidth - 4 * Constants.kPadding, height: 25))
        issueButton.setTitle("Report An Issue", forState: .Normal)
        issueButton.addTarget(self, action:#selector(self.support), forControlEvents: .TouchUpInside)
        issueButton.setTitleColor(MaterialColor.black, forState: .Normal)
        issueButton.titleLabel!.textAlignment = .Center
        issueButton.pulseColor = Constants.kBlueShade
        issueView.addSubview(issueButton)
        issueButton.titleLabel!.font = UIFont(name: issueButton.titleLabel!.font.fontName, size: Constants.kFontSize)
        let issueNode = ASDisplayNode(viewBlock: { () -> UIView in return issueView })
        self.view.addSubnode(issueNode)
        
        //Privacy
        let privacyView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 130 + Constants.kPadding, width: maxWidth, height: 30))
        let privacyButton = FlatButton(frame: CGRect(x: 2*Constants.kPadding, y: Constants.kPadding/4, width: maxWidth - 4 * Constants.kPadding, height: 25))
        privacyButton.setTitle("Privacy Policy", forState: .Normal)
        privacyButton.addTarget(self, action:#selector(self.showPolicy), forControlEvents: .TouchUpInside)
        privacyButton.setTitleColor(MaterialColor.black, forState: .Normal)
        privacyButton.titleLabel!.textAlignment = .Center
        privacyButton.pulseColor = Constants.kBlueShade
        privacyView.addSubview(privacyButton)
        privacyButton.titleLabel!.font = UIFont(name: privacyButton.titleLabel!.font.fontName, size: Constants.kFontSize)
        let privacyNode = ASDisplayNode(viewBlock: { () -> UIView in return privacyView })
        self.view.addSubnode(privacyNode)
        
        //Logout
        let logoutView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 170 + Constants.kPadding, width: maxWidth, height: 30))
        let logoutButton = FlatButton(frame: CGRect(x: 2*Constants.kPadding, y: Constants.kPadding/4, width: maxWidth - 4 * Constants.kPadding, height: 25))
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.addTarget(self, action: #selector(SettingsViewController.logout), forControlEvents: .TouchUpInside)
        logoutButton.setTitleColor(MaterialColor.black, forState: .Normal)
        logoutButton.titleLabel!.textAlignment = .Center
        logoutButton.pulseColor = Constants.kBlueShade
        logoutView.addSubview(logoutButton)
        logoutButton.titleLabel!.font = UIFont(name: logoutButton.titleLabel!.font.fontName, size: Constants.kFontSize)
        let logoutNode = ASDisplayNode(viewBlock: { () -> UIView in return logoutView })
        self.view.addSubnode(logoutNode)
        
        self.view.backgroundColor = Constants.kBlueShade
        self.navigationDrawerController!.depth = .Depth1
    }
    
    //MARK: Methods
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SettingsViewModel().getSettingSignal(settingType: .DefaultListIndex)
            .startWithNext({ index in self.picker.selectRow(index as! Int, inComponent: 0, animated: true) })
    }
    
    func logout() {
        let alertVC = PMAlertController(title: "Warning", description: "We strongly recommend against switching accounts as your votes and settings might get lost. Are you sure you want to continue?", image: R.image.spaceship_red_big()!, style: .Alert)
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .Cancel, action: { _ in self.dismissViewControllerAnimated(true, completion: nil) } ))
        alertVC.addAction(PMAlertAction(title: "Log Out", style: .Default, action: { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
            UserViewModel().logoutSignal().startWithNext({ _ in
                MaterialAnimation.delay(1.0) { TAOverlay.showOverlayWithLabel(OverlayInfo.LogoutUser.message(), image: OverlayInfo.LogoutUser.logo(), options: OverlayInfo.getOptions()) }
                TAOverlay.setCompletionBlock({ _ in self.navigationDrawerController!.closeLeftView() })
            })
        }))
        alertVC.view.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.7)
        alertVC.view.opaque = false
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
    
    func support() { self.sendEmail() }
    
    func showPolicy() {
        let url = NSURL(string: Constants.kPolicyURL)
        let vc = SFSafariViewController(URL: url!, entersReaderIfAvailable: false)
        vc.delegate = self
        presentViewController(vc, animated: true, completion: nil)
    }
    
    //MARK: SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        MaterialAnimation.delay(0.75) {
            self.navigationDrawerController!.enabled = true
            self.navigationDrawerController!.closeLeftView()
        }
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: { _ in
            self.navigationDrawerController!.enabled = true
        })
    }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return ListInfo.getCount() }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: ListInfo(rawValue: row)!.name(), attributes: [NSForegroundColorAttributeName : MaterialColor.black, NSBackgroundColorAttributeName : Constants.kGreyBackground])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SettingsViewModel().updateSettingSignal(value: row, settingType: .DefaultListIndex).start()
        SettingsViewModel().getSettingSignal(settingType: .FirstInterest).startWithNext({ first in let firstTime = first as! Bool
            guard firstTime else { return }
            TAOverlay.showOverlayWithLabel(OverlayInfo.FirstInterest.message(), image: OverlayInfo.FirstInterest.logo(), options: OverlayInfo.getOptions())
            TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstInterest).start() })
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
                        let alertVC = PMAlertController(title: "The Public Sphere", description: OverlayInfo.FirstPublic.message(), image: OverlayInfo.FirstPublic.logo(), style: .Alert)
                        alertVC.addAction(PMAlertAction(title: "I'm ready to participate", style: .Cancel, action: { _ in
                            SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstPublic).start()
                            self.dismissViewControllerAnimated(true, completion: nil) }))
                        alertVC.view.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.7)
                        alertVC.view.opaque = false
                        self.presentViewController(alertVC, animated: true, completion: nil)
                    } else {
                        let alertVC = PMAlertController(title: "Work in Progress", description: OverlayInfo.FirstConsensus.message(), image: OverlayInfo.FirstConsensus.logo(), style: .Alert)
                        alertVC.addAction(PMAlertAction(title: "I'm ready to build", style: .Cancel, action: { _ in
                            SettingsViewModel().updateSettingSignal(value: false, settingType: .FirstConsensus).start()
                            self.dismissViewControllerAnimated(true, completion: nil) }))
                        alertVC.view.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.7)
                        alertVC.view.opaque = false
                        self.presentViewController(alertVC, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    //MARK: DidLayoutSubviews Helpers
    func setupMaterialView(frame frame: CGRect) -> MaterialView {
        let materialView = MaterialView(frame: frame)
        materialView.depth = .Depth1
        materialView.backgroundColor = Constants.kGreyBackground
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
        box.onFillColor = Constants.kRedShade
        box.onTintColor = Constants.kRedShade
        box.tintColor = Constants.kRedShade
        box.backgroundColor = Constants.kGreyBackground
        box.setOn(status, animated: true)
        materialView.addSubview(publicServiceLabel)
        materialView.addSubview(box)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
    
    func setupProgressBarNode(title title: String, maxWidth: CGFloat, yPosition: CGFloat, value: CGFloat, bar: YLProgressBar) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 50))
        let factsLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: 180, height: 25))
        bar.frame = CGRect(x: Constants.kPadding, y: factsLabel.bottom, width: maxWidth - 2 * Constants.kPadding, height: 15)
        bar.progressTintColors = [Constants.kRedShade, Constants.kRedShade]
        bar.setProgress(value, animated: true)
        bar.type = .Flat
        bar.backgroundColor = Constants.kRedShade
        bar.indicatorTextDisplayMode = .Progress
        materialView.addSubview(factsLabel)
        materialView.addSubview(bar)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
}