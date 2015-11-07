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
    var defaultListId: String = "0001"
    enum RankSetting: Int { case All = 0, A_List, B_List }
    enum NotificationSetting: Int { case Daily = 0, Weekly, Never }
    
    
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
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let id = defaults.stringForKey("defaultListId") { self.defaultListId = id }
        
        self.userVM.getUserVotePercentageSignal()
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("getUserVotePercentageSignal Value: \(value)")
                case let .Error(error):
                    print("getUserVotePercentageSignal Error: \(error)")
                case .Completed:
                    print("getUserVotePercentageSignal Completed")
                case .Interrupted:
                    print("getUserVotePercentageSignal Interrupted")
                }
        }
        
       //TO DO: switch that selects and saves defaultListId in NSUserDefaults
       //TO DO: switch that selects and saves RankSetting in NSUserDefaults
       //TO DO: switch that selects and saves NotificationSetting in NSUserDefaults
    }
    
    
}