//
//  ConferenceDateTests.swift
//  iOSDevUKTests
//
//  Created by Neil Taylor on 11/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import XCTest
@testable import iOSDevUK

class ConferenceDateTests: XCTestCase {
    
    var isoDateFormatter: ISO8601DateFormatter?
    var startDate: Date!
    var endDate: Date!
    
    override func setUp() {
        super.setUp()
        isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter?.timeZone = TimeZone(identifier: "Europe/London")
        
        startDate = isoDateFormatter?.date(from: "2018-09-03T16:00:00+01:00")!
        endDate = isoDateFormatter?.date(from: "2018-09-06T16:30:00+01:00")!
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBeforeConferenceStatus() {
        
        let date = isoDateFormatter?.date(from: "2018-08-03T16:00:00+01:00")
        let conferenceDate = ConferenceDate(currentDate: date!, startDate: startDate, endDate: endDate)
    
        XCTAssert(conferenceDate.conferenceDateStatus() == .beforeConference, "Incorrect date status - should be before")
    }
    
    func testAtStartOfConferenceStatus() {
        
        let date = isoDateFormatter?.date(from: "2018-09-03T16:00:00+01:00")
        let conferenceDate = ConferenceDate(currentDate: date!, startDate: startDate, endDate: endDate)
        
        XCTAssert(conferenceDate.conferenceDateStatus() == .duringConference, "Incorrect date status - should be during conference")
    }
    
    func testDuringOfConferenceStatus() {
        
        let date = isoDateFormatter?.date(from: "2018-09-04T16:00:00+01:00")
        let conferenceDate = ConferenceDate(currentDate: date!, startDate: startDate, endDate: endDate)
        
        XCTAssert(conferenceDate.conferenceDateStatus() == .duringConference, "Incorrect date status - should be during conference")
    }
    
    func testAtEndOfConferenceStatus() {
        
        let date = isoDateFormatter?.date(from: "2018-09-06T16:30:00+01:00")
        let conferenceDate = ConferenceDate(currentDate: date!, startDate: startDate, endDate: endDate)
        
        XCTAssert(conferenceDate.conferenceDateStatus() == .duringConference, "Incorrect date status - should be during conference")
    }
    
    func testAfterConferenceStatus() {
        
        let date = isoDateFormatter?.date(from: "2018-09-06T17:00:00+01:00")
        let conferenceDate = ConferenceDate(currentDate: date!, startDate: startDate, endDate: endDate)
        
        XCTAssert(conferenceDate.conferenceDateStatus() == .afterConference, "Incorrect date status - should be after")
    }
    
}
