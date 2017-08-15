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
        let logoView: View = setupMaterialView(frame: CGRect(x: 0, y: 0, width: Constants.kSettingsViewWidth, height: Constants.kLogoHeight))
        logoView.depthPreset = .none
        let diameter = Constants.kIsOriginalIphone ? 60 : 80
        let logoCircle_x = (Int(Constants.kSettingsViewWidth) - diameter)/2
        let logoCircle_y = Constants.kIsOriginalIphone ? 15 : 18
        let logoCircle: Button = Button(frame: CGRect(x: logoCircle_x, y: logoCircle_y, width: diameter, height: diameter))
        logoCircle.setImage(R.image.geometry_white()!, for: .normal)
        logoCircle.setImage(R.image.geometry_white()!, for: .highlighted)
        logoCircle.shapePreset = .circle
        logoCircle.depthPreset = .depth2
        logoCircle.backgroundColor = Constants.kBlueShade
        logoCircle.addTarget(self, action: #selector(SettingsViewController.refreshAction), for: .touchUpInside)
        logoView.addSubview(logoCircle)
        logoView.layer.shadowColor = Color.black.cgColor
        logoView.layer.cornerRadius = 0
        logoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoView.layer.shadowOpacity = 0.1
        logoView.backgroundColor = Constants.kRedShade
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoView })
        self.view.addSubnode(logoNode)

        //Progress Bars
        let progressNodeHeight: CGFloat = 60.0
        
        SettingsViewModel().calculateAverageRoyaltySignal()
            .on(value: { value in
                let consensusBarNode = self.setupProgressBarNode(title: "Hollywood Royalty (avg.)", maxWidth: maxWidth, yPosition: logoView.bottom + Constants.kPadding, value: value, bar: self.fact1Bar)
                self.view.addSubnode(consensusBarNode) })
            .start()
        
        SettingsViewModel().calculatePrevAverageRoyaltySignal(day: .LastWeek)
            .on(value: { value in
                let publicOpinionBarNode = self.setupProgressBarNode(title: "Last Week Royalty (avg.)", maxWidth: maxWidth, yPosition: logoView.bottom + progressNodeHeight + Constants.kPadding/2, value: value, bar: self.fact2Bar)
                self.view.addSubnode(publicOpinionBarNode) })
            .start()
        
        SettingsViewModel().calculatePrevAverageRoyaltySignal(day: .LastMonth)
            .on(value: { value in
                let positiveBarNode = self.setupProgressBarNode(title: "Last Month Royalty (avg.)", maxWidth: maxWidth, yPosition: logoView.bottom + 2 * progressNodeHeight, value: value, bar: self.fact3Bar)
                self.view.addSubnode(positiveBarNode) })
            .start()
        
        //PickerView
        let pickerView: View = self.setupMaterialView(frame: CGRect(x: Constants.kPadding, y: (logoView.bottom + 3 * progressNodeHeight - Constants.kPadding/2), width: maxWidth, height: UIDevice.getPickerHeight()))
        self.picker.frame = CGRect(x: Constants.kPadding, y: Constants.kPickerY, width: maxWidth - 2 * Constants.kPadding, height: 100)
        self.picker.dataSource = self
        self.picker.delegate = self
        pickerView.addSubview(self.picker)
        let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        self.view.addSubnode(pickerNode)
        
        //Check Boxes
        let publicNodeHeight = logoView.bottom + UIDevice.getPickerHeight() + 3 * progressNodeHeight
        SettingsViewModel().getSettingSignal(settingType: .onCountdown)
            .on(value: { status in
                let notificationNode = self.setupCheckBoxNode(title: "Coronation Notification", maxWidth: maxWidth, yPosition: publicNodeHeight, status: (status as! Bool))
                self.view.addSubnode(notificationNode) })
            .start()
        
        //Issue
        let issueView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 45, width: maxWidth, height: 40))
        let issueButton = FlatButton(frame: CGRect(x: 2 * Constants.kPadding, y: Constants.kPadding/2, width: maxWidth - 4 * Constants.kPadding, height: 30))
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
        let privacyView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 90, width: maxWidth, height: 40))
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
        let logoutView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight + 135, width: maxWidth, height: 40))
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
            .on(value: { index in self.picker.selectRow(index as! Int, inComponent: 0, animated: true) })
            .start()
    }
    
    func logout() {
        let alertVC = PMAlertController(title: Constants.kAlertName, description: "Your votes will be discarded.\n\nAre you sure you want to leave?", image: R.image.kindom_Blue()!, style: .alert)
        alertVC.alertTitle.textColor = Constants.kRedText
        alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { _ in self.dismiss(animated: true, completion: nil) } ))
        alertVC.addAction(PMAlertAction(title: "Leave", style: .default, action: { _ in
            self.dismiss(animated: true, completion: nil)
            UserViewModel().logoutSignal()
                .on(value: { _ in Motion.delay(1.0) { self.navigationDrawerController!.closeLeftView() } })
                .start()
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
            SettingsViewModel().calculateAverageRoyaltySignal()
                .on(value: { value in self.fact1Bar.setProgress(value, animated: true) })
                .start()
            SettingsViewModel().calculatePrevAverageRoyaltySignal(day: .LastWeek)
                .on(value: { value in self.fact2Bar.setProgress(value, animated: true) })
                .start()
            SettingsViewModel().calculatePrevAverageRoyaltySignal(day: .LastMonth)
                .on(value: { value in self.fact3Bar.setProgress(value, animated: true) })
                .start()
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
        Motion.delay(0.75) {
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
        SettingsViewModel().updateSettingSignal(value: checkBox.on as AnyObject, settingType: .onCountdown).start()
        if checkBox.on {
            let alertVC = PMAlertController(title: "Coronation Notification", description: OverlayInfo.countdown.message(), image: OverlayInfo.countdown.logo(), style: .alert)
            alertVC.alertTitle.textColor = Constants.kBlueText
            alertVC.addAction(PMAlertAction(title: Constants.kAlertAction, style: .default, action: { _ in
                self.dismiss(animated: true, completion: nil) }))
            alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
            alertVC.view.isOpaque = false
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    //MARK: DidLayoutSubviews Helpers
    func setupMaterialView(frame: CGRect) -> View {
        let materialView = View(frame: frame)
        materialView.depthPreset = .depth1
        materialView.layer.cornerRadius = frame.height > 40 ? Constants.kCornerRadius : 5.0
        materialView.backgroundColor = Constants.kGreyBackground
        return materialView
    }
    
    func setupCheckBoxNode(title: String, maxWidth: CGFloat, yPosition: CGFloat, status: Bool) -> ASDisplayNode {
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: 40))
        let publicServiceLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - Constants.kPadding, height: 40))
        publicServiceLabel.textAlignment = .center
        publicServiceLabel.backgroundColor = .clear
        let box = BEMCheckBox(frame: CGRect(x: maxWidth - 40, y: 5, width: 30, height: 30))
        box.delegate = self
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
        let factsLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: 0, width: maxWidth - 2 * Constants.kPadding, height: 25))
        bar.frame = CGRect(x: Constants.kPadding, y: factsLabel.bottom, width: maxWidth - 2 * Constants.kPadding, height: 15)
        bar.type = .flat
        bar.isStripesAnimated = false
        bar.hideStripes = true
        bar.hideGloss = true
        bar.uniformTintColor = true
        bar.progressTintColor = Constants.kBlueShade
        bar.trackTintColor = Constants.kRedShade
        bar.backgroundColor = Constants.kRedShade
        bar.indicatorTextDisplayMode = .progress
        materialView.addSubview(factsLabel)
        materialView.addSubview(bar)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
}
