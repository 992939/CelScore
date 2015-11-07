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
    
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { fatalError("storyboards are incompatible with truth and beauty") }
    
    
    //MARK: Methods
    override func viewWillLayoutSubviews() {}
    override func prefersStatusBarHidden() -> Bool { return true }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}