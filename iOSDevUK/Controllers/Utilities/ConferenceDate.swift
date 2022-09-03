//
//  ConferenceDate.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 11/08/2018.
//  Copyright © 2018-2022 Aberystwyth University. All rights reserved.
//

import Foundation

public enum ConferenceDateStatus {
    case beforeConference
    case duringConference
    case afterConference
}

public class ConferenceDate {
    
    var currentDate: Date
    var startDate: Date
    var endDate: Date
    
    init(currentDate: Date, startDate: Date, endDate: Date) {
        self.currentDate = currentDate
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func conferenceDateStatus() -> ConferenceDateStatus {
        let startDateComparisonResult = startDate.compare(currentDate)
        let endDateComparisonResult = endDate.compare(currentDate)
        
        if startDateComparisonResult == .orderedDescending {
            return .beforeConference
        }
        else if endDateComparisonResult == .orderedAscending {
            return .afterConference
        }
        else {
            return .duringConference
        }
    }
    
    func timeToStartOfConference() -> (days: Int, hours: Int, minutes: Int, seconds: Int)? {
        
        if conferenceDateStatus() == .beforeConference {
        
            let intervalAsSeconds = Int(startDate.timeIntervalSince(currentDate))
            
            let days = Int(intervalAsSeconds / (3600 * 24))
            let hours = Int((intervalAsSeconds % (3600 * 24)) / 3600)
            let minutes = Int((intervalAsSeconds % 3600) / 60)
            let seconds = Int(intervalAsSeconds % 60)
            
            return (days, hours, minutes, seconds)
        }
        
        return nil
    }
    
    func timeToStartAsString() -> String {
        
        var result = ""
        
        if let (days, hours, minutes, _) = timeToStartOfConference() {
            if days > 0 {
                if days == 1 {
                    if hours > 12 {
                        return "just under 2 days"
                    }
                    else {
                        return "just over \(days) day 🎉"
                    }
                }
                else {
                    result = "\(days) days"
                }
                
            }
            else if hours > 0 {
                let hour = (hours == 1) ? "hour" : "hours"
                result = "about \(hours) \(hour) 🥳"
            }
            else if minutes > 0 {
                let min = (minutes == 1) ? "minute" : "minutes"
                result = "about \(minutes) \(min) 🎉🥳"
            }
            else {
                result = "about a minute 🎉🎉🎉"
            }
        }
        
        return result
    }
    
    
}
