//
//  SettingsViewController.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 11/6/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    //MARK: Properties
    let userVM: UserViewModel
    
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.userVM = UserViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    
    //MARK: Methods
    override func viewWillLayoutSubviews() {}
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userVM.getUserVotePercentageSignal()
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("getUserVotePercentageSignalValue: \(value)")
                case let .Error(error):
                    print("getUserVotePercentageSignal Error: \(error)")
                case .Completed:
                    print("getUserVotePercentageSignal Completed")
                case .Interrupted:
                    print("getUserVotePercentageSignal Interrupted")
                }
        }
    }
}