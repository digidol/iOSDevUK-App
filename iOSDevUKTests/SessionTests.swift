//
//  SessionTests.swift
//  iOSDevUKTests
//
//  Created by Neil Taylor on 22/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import XCTest
@testable import iOSDevUK

class SessionTests: XCTestCase {
    
    var dataManager: DataManager?
    var isoDateFormatter: ISO8601DateFormatter?
    
    
    override func setUp() {
        super.setUp()
        isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter?.timeZone = TimeZone(identifier: "Europe/London")
        dataManager = DataManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNowBeforeStartOfDayOne() {
        let date = isoDateFormatter?.date(from: "2018-09-03T15:00:00+01:00")
        let now = Session.nowSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssertNil(now)
    }
    
    func testNextBeforeStartOfDayOne() {
        let date = isoDateFormatter?.date(from: "2018-09-03T15:00:00+01:00")
        let next = Session.nextSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssert(next?.recordName == "d1_s1_1")
    }
    
    func testNowAtStartOfDayOne() {
        let date = isoDateFormatter?.date(from: "2018-09-03T16:00:00+01:00")
        let now = Session.nowSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssert(now?.recordName == "d1_s1_1")
    }
    
    func testNextAtStartOfDayOne() {
        let date = isoDateFormatter?.date(from: "2018-09-03T16:00:00+01:00")
        let next = Session.nextSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssert(next?.recordName == "d1_s2_1")
    }
    
    func testNowAtEndOfDayOne() {
        let date = isoDateFormatter?.date(from: "2018-09-03T23:59:59+01:00")
        let now = Session.nowSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssert(now?.recordName == "d1_s2_1")
    }
    
    func testNextAtEndOfDayOne() {
        let date = isoDateFormatter?.date(from: "2018-09-03T23:59:59+01:00")
        let next = Session.nextSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssert(next?.recordName == "d2_s1_1")
    }
    
    func testNowBeforeStartOfDayTwo() {
        let date = isoDateFormatter?.date(from: "2018-09-04T08:00:00+01:00")
        let now = Session.nowSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssertNil(now)
    }
    
    func testNowAtEndOfDayThree() {
        let date = isoDateFormatter?.date(from: "2018-09-06T16:30:00+01:00")
        let now = Session.nowSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssert(now?.recordName == "d4_s2_2")
    }
    
    func testNextAtEndOfDayFour() {
        let date = isoDateFormatter?.date(from: "2018-09-06T16:30:00+01:00")
        let next = Session.nextSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssertNil(next)
    }
    
    func testNowAfterEndOfConference() {
        let date = isoDateFormatter?.date(from: "2018-09-06T16:30:01+01:00")
        let now = Session.nowSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssertNil(now)
    }
    
    func testNextAfterEndOfConference() {
        let date = isoDateFormatter?.date(from: "2018-09-06T16:30:01+01:00")
        let next = Session.nextSession(forDate: date!, inContext: dataManager!.persistentContainer.viewContext)
        XCTAssertNil(next)
    }
    
}
