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


protocol DetailSubViewable {
    func socialSharing(message message: String)
    func enableVoteButton(positive positive: Bool)
    func rippleEffect(positive positive: Bool, gold: Bool)
}

protocol HUDable{}

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

protocol Sociable {
    func handleMenu(open: Bool)
    func socialButton(button: UIButton)
}

extension Sociable {
    func setUpSocialButton(menuView: MenuView, controller: UIViewController, origin: CGPoint, buttonColor: UIColor) {
        let btn1: FabButton = FabButton()
        btn1.depth = .Depth2
        btn1.pulseScale = false
        btn1.backgroundColor = buttonColor
        btn1.tintColor = MaterialColor.white
        btn1.setImage(R.image.ic_add_black()!, forState: .Disabled)
        btn1.setImage(R.image.ic_add_white()!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        btn1.setImage(R.image.ic_add_white()!.imageWithRenderingMode(.AlwaysTemplate), forState: .Highlighted)
        btn1.addTarget(controller, action: Selector("handleMenu:"), forControlEvents: .TouchUpInside)
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
        btn2.addTarget(controller, action: Selector("socialButton:"), forControlEvents: .TouchUpInside)
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
        btn3.addTarget(controller, action: Selector("socialButton:"), forControlEvents: .TouchUpInside)
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
