//
//  LoginViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 2/29/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import AsyncDisplayKit
import FBSDKLoginKit
import ReactiveCocoa


final class LoginViewController: ASViewController, FBSDKLoginButtonDelegate {

    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        super.init(node: ASDisplayNode())
    }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        let loginButton: FBSDKLoginButton = getLoginButton()
        self.view.addSubview(loginButton)
    }
    
    func getLoginButton() -> FBSDKLoginButton {
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_location", "user_birthday"]
        loginButton.frame = CGRect(x: 0, y: 70, width: 120, height: 44)
        loginButton.delegate = self
        return loginButton
    }
    
    //MARK: FBSDKLoginButtonDelegate Methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil else { print("FBSDKLogin error: \(error)"); return }
        guard result.isCancelled == false else { return }
        FBSDKAccessToken.setCurrentAccessToken(result.token)
        
        UserViewModel().loginSignal(token: result.token.tokenString, loginType: .Facebook)
            .observeOn(QueueScheduler.mainQueueScheduler)
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getUserInfoFromFacebookSignal()
            }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .Celebrity)
            }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .Ratings)
            }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return CelScoreViewModel().getFromAWSSignal(dataType: .List)
            }
            .flatMap(.Latest) { (_) -> SignalProducer<AnyObject, NSError> in
                return UserViewModel().getFromCognitoSignal(dataSetType: .UserRatings)
            }
            .flatMapError { _ in SignalProducer<AnyObject, NSError>.empty }
            .retry(2)
            .start()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) { UserViewModel().logoutSignal(.Facebook).start() }
}