//
//  NSDateExt.swift
//  RFZodiacExt
//
//  Created by Rich Fellure on 3/6/15.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit


extension UIView {
    func slide(right right: Bool, duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let transition = CATransition()
        if let delegate: AnyObject = completionDelegate { transition.delegate = delegate }
        transition.type = kCATransitionPush
        transition.subtype = right ? kCATransitionFromRight : kCATransitionFromLeft
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.fillMode = kCAFillModeBoth
        self.layer.addAnimation(transition, forKey: "slideTransition")
    }
}

extension UIButton {
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let buttonSize = self.frame.size
        let widthToAdd = (60-buttonSize.width > 0) ? 60-buttonSize.width : 0
        let heightToAdd = (60-buttonSize.height > 0) ? 60-buttonSize.height : 0
        let largerFrame = CGRect(x: 0-(widthToAdd/2), y: 0-(heightToAdd/2), width: buttonSize.width+widthToAdd, height: buttonSize.height+heightToAdd)
        return (CGRectContainsPoint(largerFrame, point)) ? self : nil
    }
}

extension NSDate {

    //MARK: Methods
    func zodiacSign() -> Zodiac {
        let dates = ["March 20", "April 19", "May 20", "June 20", "July 22", "August 22", "September 23", "October 22", "November 21", "December 21", "January 19", "February 18"]
        
        for i in 0...11 {
            let date = NSDate(aString: dates[i])
            let second = i < 11 ? dates[i + 1] : dates[0] as String
            let sD = NSDate(aString: second)
            let d = NSDate(anDate: self)
            if d.compare(date) == NSComparisonResult.OrderedDescending && d.compare(sD) == .OrderedAscending { return Zodiac(rawValue: i)! }
        }
        return Zodiac(rawValue: 1)!
    }

    func checkIfDateIsBetween(firstDate firstDate: NSDate, secondDate: NSDate)-> Bool {
        let first = NSDate(date: firstDate)
        let second = NSDate(date: secondDate)
        let d = NSDate(date: self)
        if d.compare(first) == .OrderedDescending && d.compare(second) == .OrderedAscending { return true }
        return false
    }

    func stringMMddyyyyFormat()-> String {
        let f = NSDateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        return f.stringFromDate(self)
    }

    func stringMMMMddyyyyFormat()-> String {
        let f = NSDateFormatter()
        f.dateFormat = "MMMM dd, yyyy"
        return f.stringFromDate(self)
    }

    //MARK: Private Methods
    private convenience init(date: NSDate) {
        let f = NSDateFormatter()
        f.dateFormat = "MM dd yyyy"
        let s = f.stringFromDate(date)
        let d = f.dateFromString(s)!
        self.init(timeInterval: 0, sinceDate: d)
    }

    private convenience init(anDate: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d"
        let string = formatter.stringFromDate(anDate)
        let date = formatter.dateFromString(string)
        self.init(timeInterval: 0, sinceDate:date!)
    }

    convenience init(adate: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy"
        let s = formatter.stringFromDate(adate)
        let date = formatter.dateFromString(s)
        self.init(timeInterval: 0, sinceDate:date!)
    }

    private convenience init(aString: String) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d"
        let date = formatter.dateFromString(aString)
        self.init(timeInterval: 0, sinceDate:date!)
    }

    convenience init(string: String) {
        let f = NSDateFormatter()
        f.dateFormat = "MMM dd yyyy"
        let d = f.dateFromString(string)
        self.init(timeInterval: 0, sinceDate:d!)
    }
}

extension CGPoint {
    func minus(p: CGPoint) -> CGPoint { return CGPoint(x: x - p.x, y: y - p.y) }
    var length: CGFloat { return sqrt(x * x + y * y) }
}

extension Double {
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}

extension NSBundle {
    var releaseVersionNumber: String? { return self.infoDictionary?["CFBundleShortVersionString"] as? String }
    var buildVersionNumber: String? { return self.infoDictionary?["CFBundleVersion"] as? String }
}

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    static func getVerticalStackPercent() -> CGFloat {
        let position: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: position =  0.55
        case Constants.kIPhone5_height: position = 0.55
        case Constants.kIPhone6_height: position = 0.65
        default: position = 0.65
        }
        return position
    }
    
    static func getFollowCheckBoxPosition() -> CGFloat {
        let position: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: position = Constants.kScreenWidth - 80
        case Constants.kIPhone5_height: position = Constants.kScreenWidth - 80
        case Constants.kIPhone6_height: position = Constants.kScreenWidth - 55
        default: position = Constants.kScreenWidth - 55
        }
        return position
    }
    
    static func getLogoViewHeightOffset() -> CGFloat {
        let offset: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: offset = 30
        case Constants.kIPhone5_height: offset = 0
        case Constants.kIPhone6_height: offset = 0
        default: offset = 0
        }
        return offset
    }
    
    static func getprofilePicDiameter() -> CGFloat {
        let diameter: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: diameter = 70.0
        case Constants.kIPhone5_height: diameter = 130.0
        case Constants.kIPhone6_height: diameter = 200.0
        default: diameter = 250.0
        }
        return diameter
    }
}