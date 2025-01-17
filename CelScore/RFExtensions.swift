//
//  NSDateExt.swift
//  RFZodiacExt
//
//  Created by Rich Fellure on 3/6/15.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit


extension Notification.Name {
    static let onSelectedBox = Notification.Name("on-selected-box")
    static let onFirstLoginFail = Notification.Name("on-first-login-fail")
}

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

    func stringMMddyyyyFormat() -> String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy"
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

extension Int {
    func toRoman() -> String {
        let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        let arabicValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        var romanValue = ""
        var startingValue = self
        
        for (index, romanChar) in romanValues.enumerated() {
            let arabicValue = arabicValues[index]
            let div = startingValue / arabicValue
            
            if div > 0 {
                for _ in 0..<div { romanValue += romanChar }
                startingValue -= arabicValue * div
            }
        }
        return romanValue
    }
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

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
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
        case Constants.kIPhoneX: height = 80
        default: height = 95
        }
        return height
    }
    
    static func getBubbleSpace() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 4.3
        case Constants.kIPhone6_height: height = 4.5
        case Constants.kIPhoneX: height = 4.5
        default: height = 5.5
        }
        return height
    }
    
    static func getPastSpacing() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 6.5
        case Constants.kIPhone6_height: height = 7.5
        case Constants.kIPhoneX: height = 7.5
        default: height = 8.5
        }
        return height
    }
    
    static func getCelScoreSpacing() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 5.0
        case Constants.kIPhone6_height: height = 25.0
        case Constants.kIPhoneX: height = 25.0
        default: height = 30.0
        }
        return height
    }
    
    static func getRankingSize() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 29
        case Constants.kIPhone6_height: height = 40
        case Constants.kIPhoneX: height = 40
        default: height = 50
        }
        return height
    }
    
    static func getPastSize() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 28
        case Constants.kIPhone6_height: height = 33
        case Constants.kIPhoneX: height = 33
        default: height = 38
        }
        return height
    }
    
    static func getTransitionX() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 53.0
        case Constants.kIPhone6_height: height = 64.0
        case Constants.kIPhoneX: height = 64.0
        default: height = 68.0
        }
        return height
    }
    
    static func getTransitionY() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 137.0
        case Constants.kIPhone6_height: height = 143.0
        case Constants.kIPhoneX: height = 167.0
        default: height = 143.0
        }
        return height
    }
    
    static func getVerticalStackPercent() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 0.48
        case Constants.kIPhone6_height: height = 0.46
        case Constants.kIPhoneX: height = 0.46
        default: height = 0.45
        }
        return height
    }
    
    static func getMiniCircle() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 15
        case Constants.kIPhone6_height: height = 17
        case Constants.kIPhoneX: height = 17
        default: height = 18
        }
        return height
    }
    
    static func getPickerHeight() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 110
        case Constants.kIPhone6_height: height = 160
        case Constants.kIPhoneX: height = 170
        default: height = 180
        }
        return height
    }
    
    static func getCelScoreTitleWidth() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 150
        case Constants.kIPhone6_height: height = 165
        case Constants.kIPhoneX: height = 165
        default: height = 185
        }
        return height
    }
    
    static func getProfileDiameter() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 170.0
        case Constants.kIPhone6_height: height = 200.0
        case Constants.kIPhoneX: height = 250.0
        default: height = 240.0
        }
        return height
    }
    
    static func getGaugeFontSize() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 45
        case Constants.kIPhone6_height: height = 60
        case Constants.kIPhoneX: height = 62
        default: height = 70
        }
        return height
    }
    
    static func getGaugeDiameter() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 145.0
        case Constants.kIPhone6_height: height = 185.0
        case Constants.kIPhoneX: height = 200.0
        default: height = 195.0
        }
        return height
    }
    
    static func getLabelWidth() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 122.0
        case Constants.kIPhone6_height: height = 122.0
        case Constants.kIPhoneX: height = 122.0
        default: height = 140.0
        }
        return height
    }
    
    static func getPulseBarHeight() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 25.0
        case Constants.kIPhone6_height: height = 30.0
        case Constants.kIPhoneX: height = 33.0
        default: height = 32.0
        }
        return height
    }
    
    static func getCelScoreBarHeight() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 30.0
        case Constants.kIPhone6_height: height = 30.0
        case Constants.kIPhoneX: height = 30.0
        default: height = 38.0
        }
        return height
    }
    
    static func getStarsSize() -> Double {
        let height: Double
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 18
        case Constants.kIPhone6_height: height = 20
        case Constants.kIPhoneX: height = 19
        default: height = 22
        }
        return height
    }
    
    static func getStarsWidth() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 120
        case Constants.kIPhone6_height: height = 150
        case Constants.kIPhoneX: height = 160.0
        default: height = 150
        }
        return height
    }
    
    static func getFontSize() -> CGFloat {
        let height: CGFloat
        switch Constants.kScreenHeight {
        case Constants.kIPhone5_height: height = 14
        case Constants.kIPhone6_height: height = 16
        case Constants.kIPhoneX: height = 16
        default: height = 18
        }
        return height
    }
}
