//
//  Socialized.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 3/22/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import Foundation
import Material


public protocol DetailSubViewable {
    func socialSharing(message message: String)
    func enableVoteButton(positive positive: Bool)
    func rippleEffect(positive positive: Bool, gold: Bool)
}

public protocol Sociable {
    func setUpSocialButton(menuView: MenuView, controller: UIViewController, origin: CGPoint, buttonColor: UIColor)
    func handleMenu(open: Bool)
    func socialButton(button: UIButton)
}
