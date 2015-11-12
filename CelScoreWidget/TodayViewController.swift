//
//  TodayViewController.swift
//  CelScoreWidget
//
//  Created by Gareth.K.Mensah on 11/9/15.
//  Copyright © 2015 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift

final class TodayViewController: UITableViewController, NCWidgetProviding {
    
    //MARK: Properties
    let expandButton = UIButton()
    var settingsVM: SettingsViewModel
    var items: Results<CelebrityModel>!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var expanded: Bool {
        get { return userDefaults.boolForKey("expanded") }
        set (newExpanded) {
            userDefaults.setBool(newExpanded, forKey: "expanded")
            userDefaults.synchronize()
        }
    }
    
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) {
        self.settingsVM = SettingsViewModel()
        super.init(coder: aDecoder)!
        
        self.settingsVM.getFollowedCelebritiesSignal()
            .start { event in
                switch(event) {
                case let .Next(value):
                    self.items = value
                    print("getFollowedCelebritiesSignal Value: \(value)")
                case let .Error(error):
                    print("getFollowedCelebritiesSignal Error: \(error)")
                case .Completed:
                    print("getFollowedCelebritiesSignal Completed")
                case .Interrupted:
                    print("getFollowedCelebritiesSignalInterrupted")
                }
        }
    }
    
    
    //MARK: Methods
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateExpandButtonTitle()
        self.expandButton.addTarget(self, action: "toggleExpand", forControlEvents: .TouchUpInside)
        tableView.sectionFooterHeight = 44
        updatePreferredContentSize()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    func updatePreferredContentSize() {
        preferredContentSize = CGSizeMake(CGFloat(0), CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * CGFloat(tableView.rowHeight) + tableView.sectionFooterHeight)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ context in
            self.tableView.frame = CGRectMake(0, 0, size.width, size.height)
            }, completion: nil)
    }

    
    // MARK: Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count > 0 {
            return min(items.count, expanded ? self.settingsVM.maxTodayExtensionNumberOfRows : self.settingsVM.defaultTodayExtensionNumRows)
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CelebItem", forIndexPath: indexPath) as! TodayTableViewCell
        cell.nickNameLabel.text = items[indexPath.row].nickName
        cell.celscoreLabel.text = "3.0"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("celeb is \(items[indexPath.row].nickName)")
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { return expandButton }
    
    
    // MARK: expand
    func updateExpandButtonTitle() { expandButton.setTitle(expanded ? "Show less" : "Show more", forState: .Normal) }
    
    func toggleExpand() {
        expanded = !expanded
        updateExpandButtonTitle()
        updatePreferredContentSize()
        tableView.reloadData()
    }
}
