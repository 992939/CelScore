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
import TTGSnackbar


protocol DetailSubViewable {
    func updateVoteButton(positive: Bool)
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

protocol Labelable {}

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

@objc protocol Snackable {}

extension Snackable where Self: UIViewController {
    func displaySnack(message: String, icon: SnackIcon) {
        let snackbar = TTGSnackbar(message: message, duration: .long, actionText: "Ok", actionBlock: { (snackbar) in print("Click action!") })
        snackbar.actionTextColor = Constants.kBlueShade
        snackbar.actionTextNumberOfLines = 1
        snackbar.messageTextAlign = .center
        snackbar.messageTextColor = Color.white
        snackbar.actionMaxWidth = Constants.kMaxWidth
        snackbar.leftMargin = Constants.kPadding
        snackbar.rightMargin = Constants.kPadding
        snackbar.bottomMargin = Constants.kPadding
        snackbar.messageTextFont = UIFont.systemFont(ofSize: UIDevice.getFontSize())
        snackbar.backgroundColor = Color.darkGray
        snackbar.icon = icon.icon()
        snackbar.animationType = .slideFromBottomBackToBottom
        snackbar.show()
    }
}

@objc protocol Supportable {}

extension Supportable where Self: UIViewController {
    func sendAlert(_ info: OverlayInfo, with loginType: SocialLogin) {
        let alertVC = PMAlertController(title: "cloud error", description: info.message(loginType.getTitle()), image: R.image.cloud_big_red()!, style: .alert)
        alertVC.alertTitle.textColor = Constants.kBlueText
        alertVC.addAction(PMAlertAction(title: "Ok", style: .cancel, action: { _ in self.dismiss(animated: true, completion: nil) }))
        alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
        alertVC.view.isOpaque = false
        self.present(alertVC, animated: true, completion: nil)
    }
}

@objc protocol Sociable: HUDable, Supportable, FABMenuDelegate, Snackable {
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
            .flatMap(.latest) { (myValue:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getUserInfoFromSignal(loginType: loginType == .facebook ? .facebook : .twitter) }
            .flatMap(.latest) { (myValue:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().updateCognitoSignal(object: myValue, dataSetType: loginType == .facebook ? .facebookInfo : .twitterInfo) }
            .retry(upTo: Constants.kNetworkRetry)
            .flatMap(.latest) { (myValue:AnyObject) -> SignalProducer<SettingsModel, NSError> in
                return SettingsViewModel().updateUserNameSignal(username: myValue.object(forKey: loginType == .facebook ? "name" : "screen_name") as! String) }
            .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getFromCognitoSignal(dataSetType: .userRatings) }
            .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getFromCognitoSignal(dataSetType: .userSettings) }
            .flatMap(.latest) { (_) -> SignalProducer<SettingsModel, NSError> in
                return SettingsViewModel().updateSettingSignal(value: loginType.rawValue as AnyObject, settingType: .loginTypeIndex) }
            .flatMap(.latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().updateCognitoSignal(object: "" as AnyObject!, dataSetType: .userSettings) }
            .observe(on: UIScheduler())
            .on(value: { _ in
                self.dismissHUD()
                self.handleMenu(open: false)
                let alertVC = PMAlertController(title: Constants.kAlertName, description: OverlayInfo.loginSuccess.message(), image: OverlayInfo.loginSuccess.logo(), style: .alert)
                alertVC.alertTitle.textColor = Constants.kBlueText
                alertVC.addAction(PMAlertAction(title: Constants.kAlertAction, style: .default, action: { _ in self.socialRefresh() }))
                alertVC.view.backgroundColor = UIColor.clear.withAlphaComponent(0.7)
                alertVC.view.isOpaque = false
                self.present(alertVC, animated: true, completion: nil)
            })
            .on(failed: { error in
                self.dismissHUD()
                self.sendAlert(.loginError, with: loginType) })
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
                return self.displaySnack(message: OverlayInfo.loginError.message("Facebook"), icon: .nuclear)
            }
            guard result?.isCancelled == false else { return }
            FBSDKAccessToken.setCurrent(result?.token)
            self.loginFlow(token: (result?.token.tokenString)!, with: .facebook, hide: hideButton)
        }
    }
    
    func twitterLogin(hideButton: Bool) {
        Twitter.sharedInstance().logIn { (session: TWTRSession?, error: Error?) -> Void in
            guard error == nil else {
                return self.displaySnack(message: OverlayInfo.loginError.message("Twitter"), icon: .nuclear)
            }
            self.loginFlow(token: "", with: .twitter, hide: hideButton)
        }
    }
    
    func setUpSocialButton(menu: FABMenu, buttonColor: UIColor) {
        let btn1 = FABButton(image: R.image.ic_add_white()!, tintColor: .white)
        btn1.depthPreset = .depth2
        btn1.pulseAnimation = .centerWithBacking
        btn1.backgroundColor = buttonColor
        
        var image = R.image.facebooklogo()!
        let btn2: FABMenuItem = FABMenuItem()
        btn2.fabButton.tag = 1
        btn2.depthPreset = .depth1
        btn2.fabButton.pulseColor = Color.white
        btn2.fabButton.backgroundColor = Color.indigo.darken1
        btn2.fabButton.borderColor = Color.white
        btn2.fabButton.borderWidth = 2
        btn2.fabButton.image = image
        btn2.fabButton.addTarget(self, action: #selector(self.socialButton(button:)), for: .touchUpInside)
        
        image = R.image.twitterlogo()!
        let btn3: FABMenuItem = FABMenuItem()
        btn3.fabButton.tag = 2
        btn3.depthPreset = .depth1
        btn3.fabButton.backgroundColor = Color.lightBlue.base
        btn3.fabButton.pulseColor = Color.white
        btn3.fabButton.borderColor = Color.white
        btn3.fabButton.borderWidth = 2
        btn3.fabButton.image = image
        btn3.fabButton.addTarget(self, action: #selector(self.socialButton(button:)), for: .touchUpInside)
        
        menu.fabButton = btn1
        menu.fabMenuDirection = .up
        menu.delegate = self
        menu.fabMenuItems = [btn2, btn3]
    }
}
