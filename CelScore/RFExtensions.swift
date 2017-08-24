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

extension Date {
    
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
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    static func getRowHeight() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 70
        case Constants.kIPhone6_height: height = 80
        default: height = 95
        }
        return height
    }
    
    static func getRankingSize() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 29
        case Constants.kIPhone6_height: height = 40
        default: height = 50
        }
        return height
    }
    
    static func getPastSize() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 28
        case Constants.kIPhone6_height: height = 33
        default: height = 38
        }
        return height
    }
    
    static func getTransitionProfileX() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 58.0
        case Constants.kIPhone6_height: height = 64.0
        default: height = 68.0
        }
        return height
    }
    
    static func getSwitchDistance() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 37
        case Constants.kIPhone6_height: height = 75
        default: height = 85
        }
        return height
    }
    
    static func getVerticalStackPercent() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 0.65
        case Constants.kIPhone6_height: height = 0.8
        default: height = 0.9
        }
        return height
    }
    
    static func getGaugeFontSize() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 50
        case Constants.kIPhone6_height: height = 60
        default: height = 70
        }
        return height
    }
    
    static func getPickerHeight() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 80
        case Constants.kIPhone6_height: height = 160
        default: height = 180
        }
        return height
    }
    
    static func getProfileDiameter() -> CGFloat {
        let diameter: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: diameter = 170.0
        case Constants.kIPhone6_height: diameter = 200.0
        default: diameter = 250.0
        }
        return diameter
    }
    
    static func getGaugeDiameter() -> CGFloat {
        let diameter: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: diameter = 160.0
        case Constants.kIPhone6_height: diameter = 185.0
        default: diameter = 210.0
        }
        return diameter
    }
    
    static func getPulseBarHeight() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 25.0
        case Constants.kIPhone6_height: height = 30.0
        default: height = 30.0
        }
        return height
    }
    
    static func getStarsSize() -> Double {
        let offset: Double
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: offset = 18
        case Constants.kIPhone6_height: offset = 20
        default: offset = 22
        }
        return offset
    }
    
    static func getStarsWidth() -> CGFloat {
        let offset: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: offset = 120
        case Constants.kIPhone6_height: offset = 150
        default: offset = 150
        }
        return offset
    }
    
    static func getFontSize() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 14
        case Constants.kIPhone6_height: height = 16
        default: height = 18
        }
        return height
    }
}
