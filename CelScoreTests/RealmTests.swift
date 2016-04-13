//
//  RealmTests.swift
//  CelScore
//
//  Created by Gareth.K.Mensah on 4/13/16.
//  Copyright © 2016 Gareth.K.Mensah. All rights reserved.
//

import XCTest
import RealmSwift
@testable import CelebrityScore

class RealmTests: XCTestCase {
    
    override func setUp() { super.setUp(); Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name }
    override func tearDown() { super.tearDown() }
    
}
