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
    let defaultNumRows = 3
    let maxNumberOfRows = 10
    var items: Results<CelebrityModel>!
    let userDefaults = NSUserDefaults(suiteName:"group.NotificationApp")
    var expanded: Bool {
        get { return userDefaults!.boolForKey("expanded") }
        set (newExpanded) {
            userDefaults!.setBool(newExpanded, forKey: "expanded")
            userDefaults!.synchronize()
        }
    }
    
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        let x = userDefaults!.integerForKey("King")
        print(x)
    }
    
    
    //MARK: Methods
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    override func viewDidAppear(animated: Bool) { super.viewDidAppear(animated) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userDefaults?.synchronize()
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
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) { return UIEdgeInsetsZero }
    
    func updatePreferredContentSize() {
        preferredContentSize = CGSizeMake(CGFloat(0), CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * CGFloat(tableView.rowHeight) + tableView.sectionFooterHeight)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//        coordinator.animateAlongsideTransition(nil, completion:{ context in
//            self.tableView.frame = CGRectMake(0, 0, size.width, size.height)
//            })
    }

    
    // MARK: Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count > 0 {
            return min(items.count, expanded ? self.maxNumberOfRows : self.defaultNumRows)
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
