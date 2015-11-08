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
    enum RankSetting: Int { case All = 1, A_List, B_List }
    enum NotificationSetting: Int { case Daily = 1, Weekly, Never }
    enum LoginType: Int { case None = 1, Facebook, Twitter }
    
    
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
        
//        self.settingsVM.getUserRatingsPercentageSignal()
//            .start { event in
//                switch(event) {
//                case let .Next(value):
//                    print("getUserRatingsPercentageSignal Value: \(value)")
//                case let .Error(error):
//                    print("getUserRatingsPercentageSignal Error: \(error)")
//                case .Completed:
//                    print("getUserRatingsPercentageSignal Completed")
//                case .Interrupted:
//                    print("getUserRatingsPercentageSignal Interrupted")
//                }
//        }
        
//        self.settingsVM.updateSettingOnLocalStoreSignal(value: 1, settingType: .RankSettingIndex)
//            .start { event in
//                switch(event) {
//                case let .Next(value):
//                    print("pdateSettingOnLocalStoreSignal Value: \(value)")
//                case let .Error(error):
//                    print("pdateSettingOnLocalStoreSignal Error: \(error)")
//                case .Completed:
//                    print("pdateSettingOnLocalStoreSignal Completed")
//                case .Interrupted:
//                    print("pdateSettingOnLocalStoreSignal Interrupted")
//                }
//        }
        
//        self.settingsVM.getSettingsFromLocalStoreSignal()
//            .start { event in
//                switch(event) {
//                case let .Next(value):
//                    print("getSettingsFromLocalStoreSignal Value: \(value)")
//                case let .Error(error):
//                    print("getSettingsFromLocalStoreSignal Error: \(error)")
//                case .Completed:
//                    print("getSettingsFromLocalStoreSignal Completed")
//                case .Interrupted:
//                    print("getSettingsFromLocalStoreSignal Interrupted")
//                }
//        }
    }
}