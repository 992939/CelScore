//
//  NSDateExt.swift
//  RFZodiacExt
//
//  Created by Rich Fellure on 3/6/15.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit


extension UIView {
    func slide(right: Bool, duration: TimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = nil) {
        let transition = CATransition()
        if let delegate = completionDelegate { transition.delegate = delegate }
        transition.type = kCATransitionPush
        transition.subtype = right ? kCATransitionFromRight : kCATransitionFromLeft
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.fillMode = kCAFillModeBoth
        self.layer.add(transition, forKey: "slideTransition")
    }
}

extension UIViewController {
    func getCountdownHours() -> Int {
        var calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.hour, .year, .minute])
        calendar.timeZone = TimeZone(identifier: "PST")!
        let components = calendar.dateComponents(unitFlags, from: NSDate() as Date)
        let countdown = components.hour! < 21 ? (21 - components.hour!) : (24 - (components.hour! - 21))
        return countdown
    }
}


extension Date {

    //MARK: Methods
    func zodiacSign() -> Zodiac {
        let dates = ["March 20", "April 19", "May 20", "June 20", "July 22", "August 22", "September 23", "October 22", "November 21", "December 21", "January 19", "February 18"]
        
        for i in 0...11 {
            let date = Date(aString: dates[i])
            let second = i < 11 ? dates[i + 1] : dates[0] as String
            let sD = Date(aString: second)
            let d = Date(anDate: self)
            if d.compare(date) == ComparisonResult.orderedDescending && d.compare(sD) == .orderedAscending { return Zodiac(rawValue: i)! }
        }
        return Zodiac(rawValue: 1)!
    }
    
    func checkIfDateIsBetween(firstDate: Date, secondDate: Date)-> Bool {
        return firstDate.compare(self) == self.compare(secondDate)
    }

    func stringMMddyyyyFormat()-> String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        return f.string(from: self)
    }

    func stringMMMMddyyyyFormat()-> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM dd, yyyy"
        return f.string(from: self)
    }
    
    private init(anDate: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let string = formatter.string(from: anDate)
        let date = formatter.date(from: string)
        self.init(timeInterval: 0, since:date!)
    }
    
    private init(aString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let date = formatter.date(from: aString)
        self.init(timeInterval: 0, since:date!)
    }
}

extension CGPoint {
    func minus(_ p: CGPoint) -> CGPoint { return CGPoint(x: x - p.x, y: y - p.y) }
    var length: CGFloat { return sqrt(x * x + y * y) }
}

extension Double {
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Bundle {
    var releaseVersionNumber: String? { return self.infoDictionary?["CFBundleShortVersionString"] as? String }
    var buildVersionNumber: String? { return self.infoDictionary?["CFBundleVersion"] as? String }
}

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
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
    
    static func getRowHeight() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: height =  70
        case Constants.kIPhone5_height: height = 70
        case Constants.kIPhone6_height: height = 80
        default: height = 80
        }
        return height
    }
    
    static func getButtonExtraArea() -> CGFloat {
        let position: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: position =  30
        case Constants.kIPhone5_height: position = 45
        case Constants.kIPhone6_height: position = 65
        default: position = 65
        }
        return position
    }
    
    static func getPickerHeight() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: height =  65
        case Constants.kIPhone5_height: height = 80
        case Constants.kIPhone6_height: height = 160
        default: height = 180
        }
        return height
    }
    
    static func getFollowCheckBoxPosition() -> CGFloat {
        let position: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: position = Constants.kScreenWidth - 80
        case Constants.kIPhone5_height: position = Constants.kScreenWidth - 80
        case Constants.kIPhone6_height: position = Constants.kScreenWidth - 80
        default: position = Constants.kScreenWidth - 80
        }
        return position
    }
    
    static func getOffset() -> CGFloat {
        let offset: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: offset = 30
        case Constants.kIPhone5_height: offset = 0
        case Constants.kIPhone6_height: offset = 0
        default: offset = 0
        }
        return offset
    }
    
    static func getProfileDiameter() -> CGFloat {
        let diameter: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: diameter = 110.0
        case Constants.kIPhone5_height: diameter = 170.0
        case Constants.kIPhone6_height: diameter = 200.0
        default: diameter = 250.0
        }
        return diameter
    }
    
    static func getProfilePadding() -> CGFloat {
        let padding: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: padding = 0.0
        case Constants.kIPhone5_height: padding = 0.0
        case Constants.kIPhone6_height: padding = 20.0
        default: padding = 20.0
        }
        return padding
    }
    
    static func getGaugeDiameter() -> CGFloat {
        let diameter: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: diameter = 140.0
        case Constants.kIPhone5_height: diameter = 160.0
        case Constants.kIPhone6_height: diameter = 185.0
        default: diameter = 210.0
        }
        return diameter
    }
    
    static func getSegmentHeight() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: height = 25.0
        case Constants.kIPhone5_height: height = 35.0
        case Constants.kIPhone6_height: height = 40.0
        default: height = 40.0
        }
        return height
    }
    
    static func getPulseBarHeight() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: height = 25.0
        case Constants.kIPhone5_height: height = 25.0
        case Constants.kIPhone6_height: height = 30.0
        default: height = 30.0
        }
        return height
    }
    
    static func getScreenshotPosition() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: height = 95
        case Constants.kIPhone5_height: height = 65
        case Constants.kIPhone6_height: height = 80
        default: height = 75
        }
        return height
    }
    
    static func getStarsWidth() -> CGFloat {
        let offset: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: offset = 110
        case Constants.kIPhone5_height: offset = 110
        case Constants.kIPhone6_height: offset = 140
        default: offset = 140
        }
        return offset
    }
    
    static func getFontSize() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone4_height: height = 14
        case Constants.kIPhone5_height: height = 14
        case Constants.kIPhone6_height: height = 16
        default: height = 16
        }
        return height
    }
}
