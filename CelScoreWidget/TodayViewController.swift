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
import AIRTimer
import Dwifft


final class TodayViewController: UITableViewController, NCWidgetProviding {
    
    //MARK: Properties
    let userDefaults: NSUserDefaults!
    let expandButton = UIButton()
    let defaultNumRows = 10
    let maxNumberOfRows = 10
    var items = [AnyObject]()
    var expanded: Bool {
        get { return true }
        set (newExpanded) { self.userDefaults.setBool(newExpanded, forKey: "expanded"); self.userDefaults.synchronize() }
    }
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) {
        self.userDefaults = NSUserDefaults(suiteName:"group.NotificationApp")!
        self.userDefaults.synchronize()
        let rowsNumber = self.userDefaults.integerForKey("count")
        super.init(coder: aDecoder)!
        
        guard rowsNumber > 0 else { return }
        for index in 0..<rowsNumber {
            let x = self.userDefaults.objectForKey(String(index))!
            self.items.append(x)
        }
    }
    
    //MARK: Methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.userDefaults.synchronize()
        self.items = []
        let rowsNumber = self.userDefaults.integerForKey("count")
        guard rowsNumber > 0 else { return }
        for index in 0..<rowsNumber {
            let x = self.userDefaults.objectForKey(String(index))!
            self.items.append(x)
        }
        self.toggleExpand()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePreferredContentSize()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) { return UIEdgeInsetsZero }
    
    func updatePreferredContentSize() {
        preferredContentSize = CGSizeMake(CGFloat(0), CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * CGFloat(tableView.rowHeight) + tableView.sectionFooterHeight)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    // MARK: Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.items.count > 0 { return min(items.count, expanded ? self.maxNumberOfRows : self.defaultNumRows) }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CelebItem", forIndexPath: indexPath) as! TodayTableViewCell
        let celebDictionary = items[indexPath.row]
        cell.nickNameLabel.text = celebDictionary["nickName"] as? String
        cell.celscoreLabel.text = String(celebDictionary["currentScore"]! as! Double)
        var percent: Double = (celebDictionary["currentScore"] as! Double)/(celebDictionary["prevScore"] as! Double)
        percent = (percent * 100) - 100
        cell.changeLabel.text = (percent < 0 ? String(percent.roundToPlaces(2)) : "+" + String(percent.roundToPlaces(2))) + "% "
        cell.changeLabel.textColor = percent < 0 ? UIColor(red: 225/255, green: 190/255, blue: 231/255, alpha: 1) : UIColor(red: 100/255, green: 255/255, blue: 218/255, alpha: 1)
        cell.profileImage.image = NSURL(string: celebDictionary["image"] as! String).flatMap { NSData(contentsOfURL: $0) }.flatMap { UIImage(data: $0) }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.extensionContext?.openURL(NSURL(string: "CelScoreWidget://")!, completionHandler: nil)
    }
    
    // MARK: expand
    func toggleExpand() {
        self.expanded = !self.expanded
        self.updatePreferredContentSize()
        self.tableView.reloadData()
    }
}

extension Double {
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}
