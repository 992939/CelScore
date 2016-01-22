//
//  NSDateExt.swift
//  RFZodiacExt
//
//  Created by Rich Fellure on 3/6/15.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import Foundation


public extension NSDate {

    //MARK: Public Methods
    public func zodiacSign()-> Zodiac {
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

    public func checkIfDateIsBetween(firstDate firstDate: NSDate, secondDate: NSDate)-> Bool {
        let first = NSDate(date: firstDate)
        let second = NSDate(date: secondDate)
        let d = NSDate(date: self)
        if d.compare(first) == .OrderedDescending && d.compare(second) == .OrderedAscending { return true }
        return false
    }

    public func stringMMddyyyyFormat()-> String {
        let f = NSDateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        return f.stringFromDate(self)
    }

    public func stringMMMMddyyyyFormat()-> String {
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