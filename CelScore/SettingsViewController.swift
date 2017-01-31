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
import SwiftyTimer
import PMAlertController
import ReactiveCocoa
import MessageUI
import SafariServices


final class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, BEMCheckBoxDelegate, Labelable, Supportable, MFMailComposeViewControllerDelegate, SFSafariViewControllerDelegate {
    
    //MARK: Property
    fileprivate let picker: UIPickerView
    fileprivate let fact1Bar: YLProgressBar
    fileprivate let fact2Bar: YLProgressBar
    fileprivate let fact3Bar: YLProgressBar

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
        let logoView: View = setupMaterialView(frame: CGRect(x: 0, y: 0, width: Constants.kSettingsViewWidth, height: 80 - 2 * UIDevice.getOffset()))
        logoView.depthPreset = .none
        let diameter = 60 - 2 * UIDevice.getOffset()
        let logoCircle: Button = Button(frame: CGRect(x: (Constants.kSettingsViewWidth - diameter)/2 , y: 10 - UIDevice.getOffset()/2, width: diameter, height: diameter))
        logoCircle.setImage(R.image.court_white()!, for: .normal)
        logoCircle.setImage(R.image.court_white()!, for: .highlighted)
        logoCircle.shapePreset = .circle
        logoCircle.depthPreset = .depth2
        logoCircle.backgroundColor = Constants.kRedShade
        logoCircle.addTarget(self, action: #selector(SettingsViewController.refreshAction), for: .touchUpInside)
        
        let labelWidth: CGFloat = (Constants.kSettingsViewWidth - logoCircle.width)/2
        let courtLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 20 - UIDevice.getOffset(), width: labelWidth, height: 40))
        courtLabel.textAlignment = .center
        let houseLabel: UILabel = UILabel(frame: CGRect(x: Constants.kSettingsViewWidth - labelWidth, y: 20 - UIDevice.getOffset(), width: labelWidth, height: 40))
        houseLabel.textAlignment = .center
        let font: UIFont = UIFont(name: "Cochin-Bold", size: 25.0) ?? UIFont.systemFont(ofSize: 23.0)
        let attributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : Color.white]
        courtLabel.attributedText = NSAttributedString(string: "COURT", attributes: attributes)
        courtLabel.backgroundColor = Constants.kBlueShade
        houseLabel.attributedText = NSAttributedString(string: "HOUSE", attributes: attributes)
        houseLabel.backgroundColor = Constants.kBlueShade
        logoView.addSubview(courtLabel)
        logoView.addSubview(houseLabel)
        logoView.addSubview(logoCircle)
        logoView.layer.shadowColor = Color.black.cgColor
        logoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoView.layer.shadowOpacity = 0.1
        logoView.backgroundColor = Constants.kBlueShade
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoView })
        self.view.addSubnode(logoNode)

        //Progress Bars
        let progressNodeHeight: CGFloat = 60.0
        
        SettingsViewModel().calculateSocialConsensusSignal().startWithValues({ value in
            let consensusBarNode = self.setupProgressBarNode(title: "General Consensus %", maxWidth: maxWidth, yPosition: logoView.bottom + Constants.kPadding, value: value, bar: self.fact1Bar)
            self.view.addSubnode(consensusBarNode) })
        
        SettingsViewModel().calculateUserRatingsPercentageSignal().startWithValues({ value in
            let publicOpinionBarNode = self.setupProgressBarNode(title: "Your Public Opinion %", maxWidth: maxWidth, yPosition: logoView.bottom + progressNodeHeight + Constants.kPadding/2, value: value, bar: self.fact2Bar)
            self.view.addSubnode(publicOpinionBarNode) })
        
        SettingsViewModel().calculatePositiveVoteSignal().startWithValues({ value in
            let positiveBarNode = self.setupProgressBarNode(title: "Your Positive Votes %", maxWidth: maxWidth, yPosition: logoView.bottom + 2 * progressNodeHeight, value: value, bar: self.fact3Bar)
            self.view.addSubnode(positiveBarNode)
        })
        
        //PickerView
        let pickerView: View = self.setupMaterialView(frame: CGRect(x: Constants.kPadding, y: (logoView.bottom + 3 * progressNodeHeight - Constants.kPadding/2), width: maxWidth, height: UIDevice.getPickerHeight()))
        let pickerLabel: UILabel = self.setupLabel(title: "Main Interest", frame: CGRect(x: Constants.kPadding, y: 0, width: 180, height: 25))
        self.picker.frame = CGRect(x: Constants.kPadding, y: Constants.kPickerY, width: maxWidth - 2 * Constants.kPadding, height: 100)
        self.picker.dataSource = self
        self.picker.delegate = self
        pickerView.addSubview(pickerLabel)
        pickerView.addSubview(self.picker)
        let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        self.view.addSubnode(pickerNode)
        
        //Check Boxes
        let publicNodeHeight = logoView.bottom + UIDevice.getPickerHeight() + 3 * progressNodeHeight
        
        SettingsViewModel().getSettingSignal(settingType: .publicService)
            .startWithValues({ status in
                let publicServiceNode = self.setupCheckBoxNode(title: "Social Sharing", tag: 0, maxWidth: maxWidth, yPosition: publicNodeHeight, status: (status as! Bool))
                self.view.addSubnode(publicServiceNode)
            })
        
        SettingsViewModel().getSettingSignal(settingType: .onCountdown)
            .startWithValues({ status in
                let notificationNode = self.setupCheckBoxNode(title: "Coronation Countdown", tag: 1, maxWidth: maxWidth, yPosition: publicNodeHeight + 45, status: (status as! Bool))
                self.view.addSubnode(notificationNode)
            })
        
        //Issue
        let issueView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 90, width: maxWidth, height: 40))
        let issueButton = FlatButton(frame: CGRect(x: 2*Constants.kPadding, y: Constants.kPadding/2, width: maxWidth - 4 * Constants.kPadding, height: 30))
        issueButton.setTitle("Report An Issue", for: .normal)
        issueButton.addTarget(self, action:#selector(self.support), for: .touchUpInside)
        issueButton.setTitleColor(Color.black, for: .normal)
        issueButton.titleLabel!.textAlignment = .center
        issueButton.pulseColor = Constants.kBlueShade
        issueView.addSubview(issueButton)
        issueButton.titleLabel!.font = UIFont(name: issueButton.titleLabel!.font.fontName, size: Constants.kFontSize)
        let issueNode = ASDisplayNode(viewBlock: { () -> UIView in return issueView })
        self.view.addSubnode(issueNode)
        
        //Privacy
        let privacyView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 135, width: maxWidth, height: 40))
        let privacyButton = FlatButton(frame: CGRect(x: 2*Constants.kPadding, y: Constants.kPadding/2, width: maxWidth - 4 * Constants.kPadding, height: 30))
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.addTarget(self, action:#selector(self.showPolicy), for: .touchUpInside)
        privacyButton.setTitleColor(Color.black, for: .normal)
        privacyButton.titleLabel!.textAlignment = .center
        privacyButton.pulseColor = Constants.kBlueShade
        privacyView.addSubview(privacyButton)
        privacyButton.titleLabel!.font = UIFont(name: privacyButton.titleLabel!.font.fontName, size: Constants.kFontSize)
        let privacyNode = ASDisplayNode(viewBlock: { () -> UIView in return privacyView })
        self.view.addSubnode(privacyNode)
        
        //Logout
        let logoutView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 180, width: maxWidth, height: 40))
        let logoutButton = FlatButton(frame: CGRect(x: 2*Constants.kPadding, y: Constants.kPadding/2, width: maxWidth - 4 * Constants.kPadding, height: 30))
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(SettingsViewController.logout), for: .touchUpInside)
        logoutButton.setTitleColor(Color.black, for: .normal)
        logoutButton.titleLabel!.textAlignment = .center
        logoutButton.pulseColor = Constants.kBlueShade
        logoutView.addSubview(logoutButton)
        logoutButton.titleLabel!.font = UIFont(name: logoutButton.titleLabel!.font.fontName, size: Constants.kFontSize)
        let logoutNode = ASDisplayNode(viewBlock: { () -> UIView in return logoutView })
        self.view.addSubnode(logoutNode)
        
        self.view.backgroundColor = Constants.kBlueShade
        self.navigationDrawerController!.depthPreset = .depth1
    }
    
    //MARK: Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SettingsViewModel().getSettingSignal(settingType: .defaultListIndex)
            .startWithValues({ index in self.picker.selectRow(index as! Int, inComponent: 0, animated: true) })
    }
    
    func logout() {
        let alertVC = PMAlertController(title: "Warning", description: "We strongly recommend against undoing your registration, your votes and settings may get removed.\n\nAre you sure you want to continue?", image: R.image.tomb_big_red()!, style: .alert)
        alertVC.alertTitle.textColor = Constants.kRedText
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { _ in self.dismiss(animated: true, completion: nil) } ))
        alertVC.addAction(PMAlertAction(title: "Continue", style: .default, action: { _ in
            self.dismiss(animated: true, completion: nil)
            UserViewModel().logoutSignal().startWithValues({ _ in
                Motion.delay(time: 1.0) { self.navigationDrawerController!.closeLeftView() }
            })
        }))
        alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
        alertVC.view.isOpaque = false
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func refreshAction(_ button: Button) {
        button.isEnabled = false
        self.fact1Bar.setProgress(0, animated: true)
        self.fact2Bar.setProgress(0, animated: true)
        self.fact3Bar.setProgress(0, animated: true)
        Timer.after(2.seconds){ _ in
            SettingsViewModel().calculateSocialConsensusSignal().startWithValues({ value in self.fact1Bar.setProgress(value, animated: true) })
            SettingsViewModel().calculateUserRatingsPercentageSignal().startWithValues({ value in self.fact2Bar.setProgress(value, animated: true) })
            SettingsViewModel().calculatePositiveVoteSignal().startWithValues({ value in self.fact3Bar.setProgress(value, animated: true) })
            button.isEnabled = true
        }
    }
    
    func support() { self.sendEmail() }
    
    func showPolicy() {
        let url = URL(string: Constants.kPolicyURL)
        let vc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        Motion.delay(time: 0.75) {
            self.navigationDrawerController!.isEnabled = true
            self.navigationDrawerController!.closeLeftView()
        }
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: { _ in
            self.navigationDrawerController!.isEnabled = true
        })
    }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return ListInfo.getCount() }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: ListInfo(rawValue: row)!.name(), attributes: [NSForegroundColorAttributeName : Color.black, NSBackgroundColorAttributeName : Constants.kGreyBackground])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SettingsViewModel().updateSettingSignal(value: row as AnyObject, settingType: .defaultListIndex).start()
        SettingsViewModel().getSettingSignal(settingType: .firstInterest).startWithValues({ first in let firstTime = first as! Bool
            guard firstTime else { return }
            TAOverlay.show(withLabel: OverlayInfo.firstInterest.message(), image: OverlayInfo.firstInterest.logo(), options: OverlayInfo.getOptions())
            TAOverlay.setCompletionBlock({ _ in SettingsViewModel().updateSettingSignal(value: false as AnyObject, settingType: .firstInterest).start() })
        })
    }
    
    //MARK: BEMCheckBoxDelegate
    func didTap(_ checkBox: BEMCheckBox) {
        SettingsViewModel().updateSettingSignal(value: checkBox.on as AnyObject, settingType: (checkBox.tag == 0 ? .publicService : .onCountdown)).start()
        if checkBox.on {
            if checkBox.tag == 0 {
                let alertVC = PMAlertController(title: "Social Sharing", description: OverlayInfo.firstPublic.message(), image: OverlayInfo.firstPublic.logo(), style: .alert)
                alertVC.alertTitle.textColor = Constants.kBlueText
                alertVC.addAction(PMAlertAction(title: "Long live the King!", style: .default, action: { _ in
                    self.dismiss(animated: true, completion: nil) }))
                alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
                alertVC.view.isOpaque = false
                self.present(alertVC, animated: true, completion: nil)
            } else {
                let alertVC = PMAlertController(title: "Coronation Countdown", description: OverlayInfo.countdown.message(), image: OverlayInfo.countdown.logo(), style: .alert)
                alertVC.alertTitle.textColor = Constants.kBlueText
                alertVC.addAction(PMAlertAction(title: "Long live the King!", style: .default, action: { _ in
                    self.dismiss(animated: true, completion: nil) }))
                alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
                alertVC.view.isOpaque = false
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: DidLayoutSubviews Helpers
    func setupMaterialView(frame: CGRect) -> View {
        let materialView = View(frame: frame)
        materialView.depthPreset = .depth1
        materialView.backgroundColor = Constants.kGreyBackground
        return materialView
    }
    
    func setupCheckBoxNode(title: String, tag: Int, maxWidth: CGFloat, yPosition: CGFloat, status: Bool) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 40))
        let publicServiceLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: 180, height: 40))
        let box = BEMCheckBox(frame: CGRect(x: maxWidth - 40, y: 5, width: 30, height: 30))
        box.delegate = self
        box.tag = tag
        box.onAnimationType = .bounce
        box.offAnimationType = .bounce
        box.onCheckColor = Color.white
        box.onFillColor = Constants.kRedShade
        box.onTintColor = Constants.kRedShade
        box.tintColor = Constants.kRedShade
        box.backgroundColor = Constants.kGreyBackground
        box.setOn(status, animated: true)
        materialView.addSubview(publicServiceLabel)
        materialView.addSubview(box)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
    
    func setupProgressBarNode(title: String, maxWidth: CGFloat, yPosition: CGFloat, value: CGFloat, bar: YLProgressBar) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 50))
        let factsLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: 180, height: 25))
        bar.frame = CGRect(x: Constants.kPadding, y: factsLabel.bottom, width: maxWidth - 2 * Constants.kPadding, height: 15)
        bar.progressTintColors = [Constants.kRedShade, Constants.kRedShade]
        bar.setProgress(value, animated: true)
        bar.type = .flat
        bar.backgroundColor = Constants.kRedShade
        bar.indicatorTextDisplayMode = .progress
        materialView.addSubview(factsLabel)
        materialView.addSubview(bar)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
}
