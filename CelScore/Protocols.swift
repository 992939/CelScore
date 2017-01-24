//
//  Socialized.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 3/22/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import Material
import SVProgressHUD
import TwitterKit
import FBSDKLoginKit
import ReactiveCocoa
import ReactiveSwift
import RevealingSplashView
import PMAlertController
import MessageUI


protocol DetailSubViewable {
    func socialSharing(message: String)
    func enableVoteButton(positive: Bool)
    func rippleEffect(positive: Bool, gold: Bool)
}

@objc protocol HUDable{}

extension HUDable{
    func showHUD() {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setRingThickness(4)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setBackgroundColor(Constants.kRedShade)
        SVProgressHUD.setForegroundColor(Color.white)
        SVProgressHUD.show()
    }
    
    func dismissHUD() { SVProgressHUD.dismiss() }
}

protocol Labelable{}

extension Labelable {
    func setupLabel(title: String, frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = title
        label.textColor = Color.black
        label.backgroundColor = Constants.kGreyBackground
        label.font = UIFont(name: label.font.fontName, size: Constants.kFontSize)
        return label
    }
}

@objc protocol Supportable: MFMailComposeViewControllerDelegate {}

extension Supportable where Self: UIViewController {
    func sendEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            return TAOverlay.show(withLabel: "We are unable to verify that an email has been setup on this device.", image: OverlayInfo.networkError.logo(), options: OverlayInfo.getOptions())
        }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["support@greyecology.io"])
        mail.setSubject("CelScore Issue")
        mail.setMessageBody("voter: \(Constants.kCredentialsProvider.identityId!)\n\n***Please provide as much information as possible about the issue below and we'll try to address it in a timely manner. ***", isHTML: false)
        Motion.delay(time: 0.5, execute: { self.present(mail, animated: true, completion: nil) })
    }
    
    func sendAlert(_ info: OverlayInfo, with loginType: SocialLogin) {
        let alertVC = PMAlertController(title: "cloud error", description: info.message(loginType.getTitle()), image: R.image.cloud_big_red()!, style: .alert)
        alertVC.alertTitle.textColor = Constants.kBlueText
        alertVC.addAction(PMAlertAction(title: "Ok", style: .cancel, action: { _ in self.dismiss(animated: true, completion: nil) }))
        alertVC.addAction(PMAlertAction(title: "Contact Us", style: .default, action: { _ in
            self.dismiss(animated: true, completion: { _ in Motion.delay(time: 0.5) { self.sendEmail() }})
        }))
        alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
        alertVC.view.isOpaque = false
        self.present(alertVC, animated: true, completion: nil)
    }
}

@objc protocol Sociable: HUDable, Supportable {
    @objc func handleMenu(open: Bool)
    @objc func socialButton(button: UIButton)
    @objc func socialRefresh()
}

extension Sociable where Self: UIViewController {
    func loginFlow(token: String, with loginType: SocialLogin, hide hideButton: Bool) {
        self.showHUD()
        UserViewModel().loginSignal(token: token, with: loginType)
            .retry(upTo: Constants.kNetworkRetry)
            .observe(on: UIScheduler())
            .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getUserInfoFromSignal(loginType: loginType == .facebook ? .facebook : .twitter) }
            .flatMap(.latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().updateCognitoSignal(object: value, dataSetType: loginType == .facebook ? .facebookInfo : .twitterInfo) }
            .flatMap(.latest) { (value:AnyObject) -> SignalProducer<SettingsModel, NSError> in
                return SettingsViewModel().updateUserNameSignal(username: (loginType == .facebook ? "name" : "screen_name")) }
            .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getFromCognitoSignal(dataSetType: .userRatings) }
            .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getFromCognitoSignal(dataSetType: .userSettings) }
            .flatMap(.latest) { (_) -> SignalProducer<SettingsModel, NSError> in
                return SettingsViewModel().updateSettingSignal(value: loginType.rawValue as AnyObject, settingType: .loginTypeIndex) }
            .flatMap(.latest) { (_) -> SignalProducer<SettingsModel, NSError> in
                return SettingsViewModel().updateSettingSignal(value: false as AnyObject, settingType: .firstLaunch) }
            .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().updateCognitoSignal(object: "" as AnyObject!, dataSetType: .userSettings) }
            .observe(on: UIScheduler())
            .on(value: { _ in
                self.dismissHUD()
                self.handleMenu(open: false)
                
                var calendar = NSCalendar.current
                let unitFlags = Set<Calendar.Component>([.hour, .year, .minute])
                calendar.timeZone = TimeZone(identifier: "PST")!
                let components = calendar.dateComponents(unitFlags, from: NSDate() as Date)
                let countdown = components.hour! < 21 ? (21 - components.hour!) : (24 - (components.hour! - 21))
                let registration = OverlayInfo.loginSuccess.message() + "\n\n" + String(countdown) + " hour(s) left until we crown the King of Hollywood."

                TAOverlay.show(withLabel: registration, image: OverlayInfo.loginSuccess.logo(), options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in self.socialRefresh() }) })
            .on(failed: { error in self.dismissHUD(); self.sendAlert(.loginError, with: loginType) })
            .start()
    }
    
    func socialButtonTapped(buttonTag: Int, hideButton: Bool) {
        if buttonTag == 1 { self.facebookLogin(hideButton: hideButton) }
        else { self.twitterLogin(hideButton: hideButton) }
    }
    
    func facebookLogin(hideButton: Bool) {
        let readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
        FBSDKLoginManager().logIn(withReadPermissions: readPermissions, from: self) { (result:FBSDKLoginManagerLoginResult?, error:Error?) in
            guard error == nil else {
                return TAOverlay.show(withLabel: OverlayInfo.loginError.message("Facebook"), image: OverlayInfo.loginError.logo(), options: OverlayInfo.getOptions())
            }
            guard result?.isCancelled == false else { return }
            FBSDKAccessToken.setCurrent(result?.token)
            self.loginFlow(token: (result?.token.tokenString)!, with: .facebook, hide: hideButton)
        }
    }
    
    func twitterLogin(hideButton: Bool) {
        Twitter.sharedInstance().logIn { (session: TWTRSession?, error: Error?) -> Void in
            guard error == nil else {
                return TAOverlay.show(withLabel: OverlayInfo.loginError.message("Twitter"), image: OverlayInfo.loginError.logo(), options: OverlayInfo.getOptions())
            }
            self.loginFlow(token: "", with: .twitter, hide: hideButton)
        }
    }
    
    func setUpSocialButton(menu: Menu, buttonColor: UIColor) {
        let btn1: FabButton = FabButton()
        btn1.depthPreset = .depth2
        btn1.pulseAnimation = .centerWithBacking
        btn1.backgroundColor = buttonColor
        btn1.tintColor = Color.white
        btn1.setImage(R.image.ic_add_black()!, for: .disabled)
        btn1.image = R.image.ic_add_white()!
        btn1.addTarget(self, action: #selector(self.handleMenu(open:)), for: .touchUpInside)
        
        var image = R.image.facebooklogo()!
        let btn2: FabButton = FabButton()
        btn2.tag = 1
        btn2.contentMode = .scaleToFill
        btn2.depthPreset = .depth1
        btn2.pulseColor = Color.white
        btn2.backgroundColor = Color.indigo.darken1
        btn2.borderColor = Color.white
        btn2.borderWidth = 2
        btn2.image = image
        btn2.addTarget(self, action: #selector(self.socialButton(button:)), for: .touchUpInside)
        
        image = R.image.twitterlogo()!
        let btn3: FabButton = FabButton()
        btn3.tag = 2
        btn3.contentMode = .scaleToFill
        btn3.depthPreset = .depth1
        btn3.backgroundColor = Color.lightBlue.base
        btn3.pulseColor = Color.white
        btn3.borderColor = Color.white
        btn3.borderWidth = 2
        btn3.image = image
        btn3.addTarget(self, action: #selector(self.socialButton(button:)), for: .touchUpInside)
        
        menu.direction = .up
        menu.views = [btn1, btn2, btn3]
    }
}
