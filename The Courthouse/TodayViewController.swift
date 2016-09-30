//
//  TodayViewController.swift
//  The Courthouse
//
//  Created by Gareth.K.Mensah on 6/9/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import NotificationCenter


final class TodayViewController: UITableViewController, NCWidgetProviding {
    
    //MARK: Properties
    let userDefaults: UserDefaults = UserDefaults(suiteName:"group.NotificationApp")!
    let maxNumberOfRows: Int = 10
    var items = [AnyObject]()
    
    //MARK: Initializers
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toggleExpand()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.userDefaults.synchronize()
        let rowsNumber: Int = self.userDefaults.integer(forKey: "count")
        guard rowsNumber > 0 else { return completionHandler(.failed) }
        
        for index in 0..<rowsNumber {
            let x = self.userDefaults.object(forKey: String(index))!
            self.items.append(x as AnyObject)
        }
        self.toggleExpand()
        completionHandler(.newData)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) { return UIEdgeInsets.zero }
    
    func updatePreferredContentSize() {
        preferredContentSize = CGSize(width: CGFloat(0), height: CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * CGFloat(tableView.rowHeight) + tableView.sectionFooterHeight)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.items.count > 0 else { return 0 }
        return min(items.count, self.maxNumberOfRows)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TodayTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CelebItem", for: indexPath) as! TodayTableViewCell
        let celebDictionary = items[(indexPath as NSIndexPath).row]
        cell.nickNameLabel.text = celebDictionary["nickName"] as? String
        cell.celscoreLabel.text = String(celebDictionary["currentScore"]! as! Double)
        let percent: Double = (celebDictionary["currentScore"] as! Double)/(celebDictionary["prevScore"] as! Double)
        let percentage: Double = (percent * 100) - 100
        cell.changeLabel.text = String(format: "%.2f", percentage) + "% "
        cell.changeLabel.textColor = percentage < 0 ? UIColor(red: 255/255, green: 82/255, blue: 82/255, alpha: 1) : UIColor(red: 64/255, green: 196/255, blue: 255/255, alpha: 1)
        cell.profileImage.image = URL(string: celebDictionary["image"] as! String).flatMap { (try? Data(contentsOf: $0)) }.flatMap { UIImage(data: $0) }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let celebDictionary = items[(indexPath as NSIndexPath).row]
        let celebId: String = celebDictionary["id"] as! String
        self.extensionContext?.open(URL(string: "TheScore://display/celebId?\(celebId)")!, completionHandler: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: expand
    func toggleExpand() {
        self.updatePreferredContentSize()
        self.tableView.reloadData()
    }
}
