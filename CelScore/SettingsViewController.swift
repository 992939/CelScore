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
import ReactiveSwift
import Result
import SafariServices


final class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, BEMCheckBoxDelegate, Labelable, Supportable, Snackable, SFSafariViewControllerDelegate {
    
    //MARK: Property
    fileprivate let picker: UIPickerView
    fileprivate let fact1Bar: YLProgressBar
    fileprivate let fact2Bar: YLProgressBar
    fileprivate let fact3Bar: YLProgressBar
    fileprivate let logoCircle: Button
    fileprivate let countdownLabel = MZTimerLabel(timerType: MZTimerLabelTypeTimer)!

    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.picker = UIPickerView()
        self.fact1Bar = YLProgressBar()
        self.fact2Bar = YLProgressBar()
        self.fact3Bar = YLProgressBar()
        let diameter = Constants.kIsOriginalIphone ? 70 : 80
        let logoCircle_x = (Int(Constants.kSettingsViewWidth) - diameter)/2
        let logoCircle_y = Constants.kIsOriginalIphone ? 12 : 18
        self.logoCircle = Button(frame: CGRect(x: logoCircle_x, y: logoCircle_y, width: diameter, height: diameter))
        super.init(nibName: nil, bundle: nil)
        
        self.picker.dataSource = self
        self.picker.delegate = self
    }
    
    //MARK: Method
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maxWidth: CGFloat = Constants.kSettingsViewWidth - 2 * Constants.kPadding
        
        //Logo
        let logoView: View = setupMaterialView(frame: CGRect(x: 0, y: 0, width: Constants.kSettingsViewWidth, height: Constants.kLogoHeight))
        logoView.depthPreset = .none
        self.logoCircle.setImage(R.image.white_star_button()!, for: .normal) //R.image.geometry_white()!
        self.logoCircle.setImage(R.image.white_star_button()!, for: .highlighted)
        self.logoCircle.shapePreset = .circle
        self.logoCircle.depthPreset = .depth2
        self.logoCircle.backgroundColor = Constants.kBlueShade
        self.logoCircle.addTarget(self, action: #selector(SettingsViewController.refreshAction(_:)), for: .touchUpInside)
        logoView.addSubview(logoCircle)
        logoView.layer.shadowColor = Color.black.cgColor
        logoView.layer.cornerRadius = 0
        logoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoView.layer.shadowOpacity = 0.1
        logoView.backgroundColor = Constants.kRedShade
        let logoNode = ASDisplayNode(viewBlock: { () -> UIView in return logoView })
        self.view.addSubnode(logoNode)

        //Progress Bars
        let progressNodeHeight: CGFloat = Constants.kIsOriginalIphone ? 60 : 70
        
        let consensusBarNode = self.setupProgressBarNode(title: "Hollywood Royalty (avg.)", maxWidth: maxWidth, yPosition: logoView.bottom + Constants.kPadding, value: 20, bar: self.fact1Bar)
        self.view.addSubnode(consensusBarNode)
        
        let publicOpinionBarNode = self.setupProgressBarNode(title: "Last Week Royalty (avg.)", maxWidth: maxWidth, yPosition: logoView.bottom + progressNodeHeight + Constants.kPadding/2, value: 20, bar: self.fact2Bar)
        self.view.addSubnode(publicOpinionBarNode)

        let positiveBarNode = self.setupProgressBarNode(title: "Last Month Royalty (avg.)", maxWidth: maxWidth, yPosition: logoView.bottom + 2 * progressNodeHeight, value: 20, bar: self.fact3Bar)
        self.view.addSubnode(positiveBarNode)
        
        //PickerView
        let pickerView: View = self.setupMaterialView(frame: CGRect(x: Constants.kPadding, y: (logoView.bottom + 3 * progressNodeHeight - Constants.kPadding/2), width: maxWidth, height: UIDevice.getPickerHeight()))
        self.picker.frame = CGRect(x: Constants.kPadding, y: Constants.kPickerY, width: maxWidth - 2 * Constants.kPadding, height: 100)
        
        pickerView.addSubview(self.picker)
        let pickerNode = ASDisplayNode(viewBlock: { () -> UIView in return pickerView })
        self.view.addSubnode(pickerNode)
        
        let publicNodeHeight = logoView.bottom + UIDevice.getPickerHeight() + 3 * progressNodeHeight
        
        //Count Down
        let countdownView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: publicNodeHeight, width: maxWidth, height: 40))
        let clockLabel = self.setupLabel(title: "Coronation Clock:", frame: CGRect(x: 2.5 * Constants.kPadding, y: Constants.kPadding/2, width: maxWidth * 0.55, height: 30))
        clockLabel.font = UIFont(name: clockLabel.font.fontName, size: Constants.kFontSize)
        clockLabel.textAlignment = .right
        clockLabel.backgroundColor = .clear
        
        countdownLabel.frame = CGRect(x: maxWidth * 0.55 + 3 * Constants.kPadding, y: Constants.kPadding * 0.55, width: maxWidth/2, height: 30)
        countdownLabel.textAlignment = .left
        countdownLabel.font = UIFont(name: countdownLabel.font.fontName, size: Constants.kFontSize)
        countdownLabel.resetTimerAfterFinish = true
        countdownView.addSubview(clockLabel)
        countdownView.addSubview(countdownLabel)
        let issueNode = ASDisplayNode(viewBlock: { () -> UIView in return countdownView })
        self.view.addSubnode(issueNode)
        
        //Check Boxes
        SettingsViewModel().getSettingSignal(settingType: .onCountdown)
            .on(value: { status in
                let notificationNode = self.setupCheckBoxNode(title: "Coronation Notification", maxWidth: maxWidth, yPosition: publicNodeHeight + 45, status: (status as! Bool))
                self.view.addSubnode(notificationNode) })
            .start()
        
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day, .hour, .year, .minute, .second])
        calendar.timeZone = TimeZone(identifier: "PST")!
        let components = calendar.dateComponents(unitFlags, from: NSDate() as Date)
        let hours = (components.hour! < 21 ? (20 - components.hour!) : (24 - (components.hour! - 20))) * 3600
        let minutes = (60 - components.minute!) * 60
        let seconds = 60 - components.second!
        let totalTime = hours + minutes + seconds
        countdownLabel.reset()
        countdownLabel.setCountDownTime(TimeInterval(totalTime))
        countdownLabel.textColor = totalTime < 3600 ? Constants.kRedLight : Color.black
        countdownLabel.start { _ in self.countdownLabel.textColor = Color.black }
        
        SettingsViewModel().getSettingSignal(settingType: .defaultListIndex)
            .on(value: { index in self.picker.selectRow(index as! Int, inComponent: 0, animated: false) })
            .flatMap(.latest) { (value:AnyObject) -> SignalProducer<CGFloat, NoError> in
                return SettingsViewModel().calculateAverageRoyaltySignal() }
            .on(value: { value in self.fact1Bar.setProgress(value/100, animated: false) })
            .flatMap(.latest) { (_) -> SignalProducer<CGFloat, NoError> in
                return SettingsViewModel().calculatePrevAverageRoyaltySignal(day: .LastWeek) }
            .on(value: { value in self.fact2Bar.setProgress(value/100, animated: false) })
            .flatMap(.latest) { (_) -> SignalProducer<CGFloat, NoError> in
                return SettingsViewModel().calculatePrevAverageRoyaltySignal(day: .LastMonth) }
            .on(value: { value in self.fact3Bar.setProgress(value/100, animated: false) })
            .start()
    }
    
    override func viewDidAppear(_ animated: Bool = true) {
        super.viewDidAppear(animated)
        Motion.delay(1) {
            self.logoCircle.pulseAnimation = .centerWithBacking
            self.logoCircle.pulseColor = .white
            self.logoCircle.pulse()
        }
    }
    
    func logout() {
        let alertVC = PMAlertController(title: Constants.kAlertName, description: "All your votes will be discarded. Are you sure you want to leave?", image: R.image.kindom_Blue()!, style: .alert)
        alertVC.alertTitle.textColor = Constants.kBlueText
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
        button.isEnabled = true
        
        Timer.after(2.seconds){ _ in
            SettingsViewModel().calculateAverageRoyaltySignal()
                .on(value: { value in self.fact1Bar.setProgress(value/100, animated: true) })
                .flatMap(.latest) { (_) -> SignalProducer<CGFloat, NoError> in
                    return SettingsViewModel().calculatePrevAverageRoyaltySignal(day: .LastWeek) }
                .on(value: { value in self.fact2Bar.setProgress(value/100, animated: true) })
                .flatMap(.latest) { (_) -> SignalProducer<CGFloat, NoError> in
                    return SettingsViewModel().calculatePrevAverageRoyaltySignal(day: .LastMonth) }
                .on(value: { value in self.fact3Bar.setProgress(value/100, animated: true) })
                .start()
        }
    }
    
    func showPolicy() {
        let url = URL(string: Constants.kPolicyURL)
        let safariVC = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
        safariVC.preferredBarTintColor = Constants.kRedShade
        safariVC.preferredControlTintColor = Color.white
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
    }
    
    //MARK: SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        Motion.delay(0.75) {
            self.navigationDrawerController!.isEnabled = true
            self.navigationDrawerController!.closeLeftView()
        }
    }
    
    //MARK: UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return ListInfo.getCount() }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: ListInfo(rawValue: row)!.name(), attributes: [NSForegroundColorAttributeName : Color.black, NSBackgroundColorAttributeName : Constants.kGreyBackground])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SettingsViewModel().getSettingSignal(settingType: .firstInterest).startWithValues({ first in let firstTime = first as! Bool
            guard firstTime else { return }
            self.displaySnack(message: "The default list has been updated.", icon: .alert)
            SettingsViewModel().updateSettingSignal(value: false as AnyObject, settingType: .firstInterest).start()
        })
    }
    
    //MARK: BEMCheckBoxDelegate
    func didTap(_ checkBox: BEMCheckBox) {
        SettingsViewModel().updateSettingSignal(value: checkBox.on as AnyObject, settingType: .onCountdown).start()
        if checkBox.on {
            let alertVC = PMAlertController(title: "The Coronation", description: OverlayInfo.countdown.message(), image: OverlayInfo.countdown.logo(), style: .alert)
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
        materialView.depthPreset = .depth2
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
        box.lineWidth = 2.5
        box.backgroundColor = Constants.kGreyBackground
        box.setOn(status, animated: true)
        materialView.addSubview(publicServiceLabel)
        materialView.addSubview(box)
        return ASDisplayNode(viewBlock: { () -> UIView in return materialView })
    }
    
    func setupProgressBarNode(title: String, maxWidth: CGFloat, yPosition: CGFloat, value: CGFloat, bar: YLProgressBar) -> ASDisplayNode {
        let progressHeight: CGFloat = Constants.kIsOriginalIphone ? 50 : 60
        let barHeight: CGFloat = Constants.kIsOriginalIphone ? 15 : 20
        let padding: CGFloat = Constants.kIsOriginalIphone ? 1.5 : 2.5
        let materialView = setupMaterialView(frame: CGRect(x: Constants.kPadding, y: yPosition, width: maxWidth, height: progressHeight))
        let factsLabel = self.setupLabel(title: title, frame: CGRect(x: Constants.kPadding, y: padding, width: maxWidth - 2 * Constants.kPadding, height: 25))
        bar.frame = CGRect(x: Constants.kPadding, y: factsLabel.bottom + padding, width: maxWidth - 2 * Constants.kPadding, height: barHeight)
        bar.type = .flat
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
