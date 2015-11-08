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
    let settingsVM: SettingsViewModel
    var defaultListId: String = "0001"
    enum RankSetting: Int { case All = 0, A_List, B_List }
    enum NotificationSetting: Int { case Daily = 0, Weekly, Never }
    
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    init() {
        self.settingsVM = SettingsViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    
    //MARK: Methods
    override func viewWillLayoutSubviews() {}
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingsVM.getUserRatingsPercentageSignal()
            .start { event in
                switch(event) {
                case let .Next(value):
                    print("getUserRatingsPercentageSignal Value: \(value)")
                case let .Error(error):
                    print("getUserRatingsPercentageSignal Error: \(error)")
                case .Completed:
                    print("getUserRatingsPercentageSignal Completed")
                case .Interrupted:
                    print("getUserRatingsPercentageSignal Interrupted")
                }
        }
       //TO DO: switch that selects and saves defaultListId
       //TO DO: switch that selects and saves RankSetting
       //TO DO: switch that selects and saves NotificationSetting
    }
    
    
}