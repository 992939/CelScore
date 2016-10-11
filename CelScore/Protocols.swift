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
        Animation.delay(time: 0.5) { self.present(mail, animated: true, completion: nil) }
    }
    
    func sendAlert(_ info: OverlayInfo, with loginType: SocialLogin) {
        let alertVC = PMAlertController(title: "cloud error", description: info.message(loginType.getTitle()), image: R.image.cloud_big_red()!, style: .alert)
        alertVC.alertTitle.textColor = Constants.kBlueText
        alertVC.addAction(PMAlertAction(title: "Ok", style: .cancel, action: { _ in self.dismiss(animated: true, completion: nil) }))
        alertVC.addAction(PMAlertAction(title: "Contact Us", style: .default, action: { _ in
            self.dismiss(animated: true, completion: { _ in Animation.delay(time: 0.5) { self.sendEmail() }})
        }))
        alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
        alertVC.view.isOpaque = false
        self.present(alertVC, animated: true, completion: nil)
    }
}

@objc protocol Sociable: HUDable, Supportable {
    @objc func handleMenu(_ open: Bool)
    @objc func socialButton(_ button: UIButton)
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
            .on(starting: { _ in
                self.dismissHUD()
                self.handleMenu(false)
                TAOverlay.show(withLabel: OverlayInfo.loginSuccess.message(), image: OverlayInfo.loginSuccess.logo(), options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in self.socialRefresh() }) })
            .on(failed: { error in self.dismissHUD(); self.sendAlert(.loginError, with: loginType) })
            .start()
    }
    
    func socialButtonTapped(buttonTag: Int, hideButton: Bool) {
        if buttonTag == 1 { self.facebookLogin(hideButton) }
        else { self.twitterLogin(hideButton) }
    }
    
    func facebookLogin(_ hideButton: Bool) {
        let readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
        FBSDKLoginManager().logIn(withReadPermissions: readPermissions, from: self, handler: { (result:FBSDKLoginManagerLoginResult!, error:Error?) -> Void in
            guard error == nil else {
                return TAOverlay.show(withLabel: OverlayInfo.loginError.message("Facebook"), image: OverlayInfo.loginError.logo(), options: OverlayInfo.getOptions())
            }
            guard result.isCancelled == false else { return }
            FBSDKAccessToken.setCurrent(result.token)
            self.loginFlow(token: result.token.tokenString, with: .facebook, hide: hideButton)
        })
    }
    
    func twitterLogin(_ hideButton: Bool) {
        Twitter.sharedInstance().logIn { (session: TWTRSession?, error: Error?) -> Void in
            guard error == nil else {
                return TAOverlay.show(withLabel: OverlayInfo.loginError.message("Twitter"), image: OverlayInfo.loginError.logo(), options: OverlayInfo.getOptions())
            }
            self.loginFlow(token: "", with: .twitter, hide: hideButton)
        }
    }
    
    func setUpSocialButton(_ menuView: MenuController, controller: UIViewController, origin: CGPoint, buttonColor: UIColor) {
        let btn1: FabButton = FabButton()
        btn1.depthPreset = .depth2
        btn1.pulseAnimation = .none
        btn1.backgroundColor = buttonColor
        btn1.tintColor = Color.white
        btn1.setImage(R.image.ic_add_black()!, for: .disabled)
        btn1.setImage(R.image.ic_add_white()!.withRenderingMode(.alwaysTemplate), for: .normal)
        btn1.setImage(R.image.ic_add_white()!.withRenderingMode(.alwaysTemplate), for: .highlighted)
        btn1.addTarget(controller, action: #selector(self.handleMenu(_:)), for: .touchUpInside)
        menuView.menu.addSubview(btn1)
        
        var image = R.image.facebooklogo()!
        let btn2: FabButton = FabButton()
        btn2.tag = 1
        btn2.clipsToBounds = true
        btn2.contentMode = .scaleToFill
        btn2.depthPreset = .depth1
        btn2.pulseColor = Color.white
        btn2.backgroundColor = Color.indigo.darken1
        btn2.borderColor = Color.white
        btn2.borderWidth = 2
        btn2.setImage(image, for: .normal)
        btn2.setImage(image, for: .highlighted)
        btn2.addTarget(controller, action: #selector(self.socialButton(_:)), for: .touchUpInside)
        menuView.menu.addSubview(btn2)
        
        image = R.image.twitterlogo()!
        let btn3: FabButton = FabButton()
        btn3.tag = 2
        btn3.contentMode = .scaleToFill
        btn3.clipsToBounds = true
        btn3.depthPreset = .depth1
        btn3.backgroundColor = Color.lightBlue.base
        btn3.pulseColor = Color.white
        btn3.borderColor = Color.white
        btn3.borderWidth = 2
        btn3.setImage(image, for: .normal)
        btn3.setImage(image, for: .highlighted)
        btn3.addTarget(controller, action: #selector(self.socialButton(_:)), for: .touchUpInside)
        menuView.menu.addSubview(btn3)
        
        menuView.menu.center = origin
        menuView.menu.baseSize = CGSize(width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        menuView.menu.direction = .up
        menuView.menu.views = [btn1, btn2, btn3]
        menuView.menu.translatesAutoresizingMaskIntoConstraints = false
    }
}
