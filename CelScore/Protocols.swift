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


protocol DetailSubViewable {
    func socialSharing(message message: String)
    func enableVoteButton(positive positive: Bool)
    func rippleEffect(positive positive: Bool, gold: Bool)
}

@objc protocol HUDable{}

extension HUDable{
    func showHUD() {
        SVProgressHUD.setDefaultStyle(.Custom)
        SVProgressHUD.setRingThickness(4)
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setBackgroundColor(Constants.kMainShade)
        SVProgressHUD.setForegroundColor(Constants.kLightGreenShade)
        SVProgressHUD.show()
    }
    
    func dismissHUD() { SVProgressHUD.dismiss() }
}

protocol Labelable{}

extension Labelable {
    func setupLabel(title title: String, frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = title
        label.textColor = MaterialColor.white
        label.font = UIFont(name: label.font.fontName, size: Constants.kFontSize)
        return label
    }
}

@objc protocol Sociable: HUDable {
    var socialButton: MenuView { get }
    @objc func handleMenu(open: Bool)
    @objc func socialButton(button: UIButton)
    @objc func socialRefresh()
}

extension Sociable {
    func loginFlow(token token: String, with loginType: SocialLogin, hide hideButton: Bool) {
        self.showHUD()
        UserViewModel().loginSignal(token: token, with: loginType)
            .retry(Constants.kNetworkRetry)
            .observeOn(UIScheduler())
            .on(next: { _ in
                self.dismissHUD()
                self.handleMenu(false)
                TAOverlay.showOverlayWithLabel(OverlayInfo.LoginSuccess.message(), image: OverlayInfo.LoginSuccess.logo(), options: OverlayInfo.getOptions())
                TAOverlay.setCompletionBlock({ _ in if hideButton == true { self.hideSocialButton(self.socialButton) }}) })
            .on(failed: { _ in self.dismissHUD() })
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getUserInfoFromSignal(loginType: loginType == .Facebook ? .Facebook : .Twitter) }
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().updateCognitoSignal(object: value, dataSetType: loginType == .Facebook ? .FacebookInfo : .TwitterInfo) }
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<SettingsModel, NSError> in
                return SettingsViewModel().updateUserName(username: value.objectForKey(loginType == .Facebook ? "name" : "screen_name") as! String) }
            .flatMapError { _ in SignalProducer.empty }
            .flatMap(.Latest) { (value:AnyObject) -> SignalProducer<SettingsModel, NSError> in
                return SettingsViewModel().updateSettingSignal(value: loginType.rawValue, settingType: .LoginTypeIndex) }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getFromCognitoSignal(dataSetType: .UserRatings) }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getFromCognitoSignal(dataSetType: .UserSettings) }
            .map({ _ in self.socialRefresh() })
            .start()
    }
    
    func socialButtonTapped(buttonTag buttonTag: Int, from: UIViewController, hideButton: Bool) {
        if buttonTag == 1 {
            let readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
            FBSDKLoginManager().logInWithReadPermissions(readPermissions, fromViewController: from, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                guard error == nil else { print("Facebook Login error: \(error!.localizedDescription)"); return }
                guard result.isCancelled == false else { return }
                FBSDKAccessToken.setCurrentAccessToken(result.token)
                self.loginFlow(token: result.token.tokenString, with: .Facebook, hide: hideButton)
            })
        } else {
            Twitter.sharedInstance().logInWithCompletion { (session: TWTRSession?, error: NSError?) -> Void in
                guard error == nil else { print("Twitter login error: \(error!.localizedDescription)"); return }
                self.loginFlow(token: "", with: .Twitter, hide: hideButton)
            }
        }
    }
    
    func setUpSocialButton(menuView: MenuView, controller: UIViewController, origin: CGPoint, buttonColor: UIColor) {
        let btn1: FabButton = FabButton()
        btn1.depth = .Depth2
        btn1.pulseScale = false
        btn1.backgroundColor = buttonColor
        btn1.tintColor = MaterialColor.white
        btn1.setImage(R.image.ic_add_black()!, forState: .Disabled)
        btn1.setImage(R.image.ic_add_white()!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        btn1.setImage(R.image.ic_add_white()!.imageWithRenderingMode(.AlwaysTemplate), forState: .Highlighted)
        btn1.addTarget(controller, action: #selector(self.handleMenu(_:)), forControlEvents: .TouchUpInside)
        menuView.addSubview(btn1)
        
        var image = R.image.facebooklogo()!
        let btn2: FabButton = FabButton()
        btn2.tag = 1
        btn2.clipsToBounds = true
        btn2.contentMode = .ScaleToFill
        btn2.depth = .Depth1
        btn2.pulseColor = MaterialColor.white
        btn2.backgroundColor = MaterialColor.indigo.darken1
        btn2.borderColor = MaterialColor.white
        btn2.borderWidth = 2
        btn2.setImage(image, forState: .Normal)
        btn2.setImage(image, forState: .Highlighted)
        btn2.addTarget(controller, action: #selector(self.socialButton(_:)), forControlEvents: .TouchUpInside)
        menuView.addSubview(btn2)
        
        image = R.image.twitterlogo()!
        let btn3: FabButton = FabButton()
        btn3.tag = 2
        btn3.contentMode = .ScaleToFill
        btn3.clipsToBounds = true
        btn3.depth = .Depth1
        btn3.backgroundColor = MaterialColor.lightBlue.base
        btn3.pulseColor = MaterialColor.white
        btn3.borderColor = MaterialColor.white
        btn3.borderWidth = 2
        btn3.setImage(image, forState: .Normal)
        btn3.setImage(image, forState: .Highlighted)
        btn3.addTarget(controller, action: #selector(self.socialButton(_:)), forControlEvents: .TouchUpInside)
        menuView.addSubview(btn3)
        
        menuView.menu.origin = origin
        menuView.menu.baseViewSize = CGSize(width: Constants.kFabDiameter, height: Constants.kFabDiameter)
        menuView.menu.direction = .Up
        menuView.menu.views = [btn1, btn2, btn3]
        menuView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func hideSocialButton(menuView: MenuView) {
        menuView.menu.close()
        menuView.hidden = true
        let first: MaterialButton? = menuView.menu.views?.first as? MaterialButton
        first!.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
    }
}
