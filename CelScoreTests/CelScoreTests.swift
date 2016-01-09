//
//  CelScoreTests.swift
//  CelScoreTests
//
//  Created by Gareth.K.Mensah on 6/19/15.
//  Copyright (c) 2015 Gareth.K.Mensah. All rights reserved.
//

import UIKit
import XCTest
@testable import CelScore

class CelScoreTests: XCTestCase {
    
    let celscoreVM: CelScoreViewModel
    
    override func setUp() {
        super.setUp()
        celscoreVM = CelScoreViewModel()
    }
    
    func testShareVoteOnSignal() {
        let composer = celscoreVM.shareVoteOnSignal
        //expect(composer).willNot.beNil
    }
    
    override func tearDown() {
        celscoreVM = nil
        super.tearDown()
    }
}
