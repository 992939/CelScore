//
//  CelebrityScoreUITests.swift
//  CelebrityScoreUITests
//
//  Created by Gareth.K.Mensah on 6/28/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest

class CelebrityScoreUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        let taylorSwiftElement = app.tables.cells.otherElements.containingType(.StaticText, identifier:"Taylor Swift").element
        taylorSwiftElement.tap()
        
        let celebritySegmentViewElement = app.otherElements["Celebrity Segment View"]
        celebritySegmentViewElement.tap()
        celebritySegmentViewElement.tap()
        celebritySegmentViewElement.tap()
        celebritySegmentViewElement.tap()
        app.buttons["Back Button"].tap()
        
        let listSegmentedControlElement = app.otherElements["List Segmented Control"]
        listSegmentedControlElement.tap()
        listSegmentedControlElement.tap()
        taylorSwiftElement.tap()
        
    }
    
}
