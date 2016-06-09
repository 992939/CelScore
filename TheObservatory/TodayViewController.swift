//
//  TodayViewController.swift
//  TheObservatory
//
//  Created by Gareth.K.Mensah on 4/30/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift
import AIRTimer
import PINCache


final class TodayViewController: UITableViewController, NCWidgetProviding {
    
    //MARK: Properties
    let userDefaults: NSUserDefaults = NSUserDefaults(suiteName:"group.NotificationApp")!
    let maxNumberOfRows: Int = 10
    var items = [AnyObject]()
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toggleExpand()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        self.userDefaults.synchronize()
        let rowsNumber: Int = self.userDefaults.integerForKey("count")
        guard rowsNumber > 0 else { return completionHandler(.Failed) }
        
        for index in 0..<rowsNumber {
            let x = self.userDefaults.objectForKey(String(index))!
            self.items.append(x)
        }
        self.toggleExpand()
        completionHandler(.NewData)
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
        guard self.items.count > 0 else { return 0 }
        return min(items.count, self.maxNumberOfRows)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TodayTableViewCell = tableView.dequeueReusableCellWithIdentifier("CelebItem", forIndexPath: indexPath) as! TodayTableViewCell
        let celebDictionary = items[indexPath.row]
        cell.nickNameLabel.text = celebDictionary["nickName"] as? String
        cell.celscoreLabel.text = String(celebDictionary["currentScore"]! as! Double)
        let percent: Double = (celebDictionary["currentScore"] as! Double)/(celebDictionary["prevScore"] as! Double)
        let percentage: Double = (percent * 100) - 100
        cell.changeLabel.text = (percent < 0 ? String(percentage.roundToPlaces(2)) : "+" + String(percentage.roundToPlaces(2))) + "% "
        cell.changeLabel.textColor = percentage < 0 ? UIColor(red: 225/255, green: 190/255, blue: 231/255, alpha: 1) : UIColor(red: 100/255, green: 255/255, blue: 218/255, alpha: 1)
        cell.profileImage.image = NSURL(string: celebDictionary["image"] as! String).flatMap { NSData(contentsOfURL: $0) }.flatMap { UIImage(data: $0) }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let celebDictionary = items[indexPath.row]
        let celebId: String = celebDictionary["id"] as! String
        self.extensionContext?.openURL(NSURL(string: "TheScore://display/celebId?\(celebId)")!, completionHandler: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: expand
    func toggleExpand() {
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