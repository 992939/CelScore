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
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        self.tableView.reloadData()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.userDefaults.synchronize()
        let rowsNumber: Int = self.userDefaults.integer(forKey: "count")
        guard rowsNumber > 0 else { return completionHandler(.failed) }
        
        for index in 0..<rowsNumber {
            let x = self.userDefaults.object(forKey: String(index))!
            self.items.append(x as AnyObject)
        }
        self.tableView.reloadData()
        completionHandler(.newData)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) { return UIEdgeInsets.zero }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.items.count > 0 else { return 0 }
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TodayTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CelebItem", for: indexPath) as! TodayTableViewCell
        let celebDictionary = items[(indexPath as NSIndexPath).row]
        cell.nickNameLabel.text = celebDictionary["nickName"] as? String
        cell.celscoreLabel.text = String(format: "%.1f", (celebDictionary["currentScore"]! as! Double)) + "%"
        let percent: Double = (celebDictionary["currentScore"] as! Double) - ((celebDictionary["prevScore"] as! Double) * 20)
        let sign = percent >= 0 ? "+" : ""
        cell.changeLabel.text = sign + String(format: "%.f", percent) + "% "
        cell.changeLabel.textColor = percent < 0 ? UIColor(red: 255/255, green: 82/255, blue: 82/255, alpha: 1) : UIColor(red: 64/255, green: 196/255, blue: 255/255, alpha: 1)
        cell.profileImage.image = URL(string: celebDictionary["image"] as! String).flatMap { (try? Data(contentsOf: $0)) }.flatMap { UIImage(data: $0) }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let celebDictionary = items[(indexPath as NSIndexPath).row]
        let celebId: String = celebDictionary["id"] as! String
        self.extensionContext?.open(URL(string: "TheScore://display/celebId?\(celebId)")!, completionHandler: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @available(iOS 10.0, *)
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        self.preferredContentSize = (activeDisplayMode == .expanded) ? CGSize(width: 320, height: CGFloat(items.count)*121 + 44) : CGSize(width: maxSize.width, height: 110)
    }
}
