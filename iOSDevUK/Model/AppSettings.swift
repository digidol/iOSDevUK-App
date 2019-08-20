//
//  AppSettings.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 20/08/2019.
//  Copyright © 2019 Aberystwyth University. All rights reserved.
//

import Foundation

protocol AppSettings {
    
    func addMyScheduleItem(withRecordName recordName: String)
    
    func removeMyScheduleItem(withRecordName recordName: String)
    
    func isInMySchedule(withRecordName recordName: String) -> Bool
    
    func scheduleItems() -> [String]?
}


class IDUAppSettings: AppSettings {
    
    let ScheduleKey = "schedule"
    
    func addMyScheduleItem(withRecordName recordName: String) {
        let keystore = NSUbiquitousKeyValueStore()
        
        var items: [String]
        
        if let scheduledItems = keystore.object(forKey: ScheduleKey) as? [String] {
            items = scheduledItems
        }
        else {
            items = [String]()
        }
        
        if !items.contains(recordName) {
            items.append(recordName)
            keystore.set(items, forKey: ScheduleKey)
            keystore.synchronize()
        }
        
    }
    
    func removeMyScheduleItem(withRecordName recordName: String) {
        let keystore = NSUbiquitousKeyValueStore()
        
        if var storedSchedule = keystore.object(forKey: ScheduleKey) as? [String] {
            if let index = storedSchedule.firstIndex(of: recordName) {
                storedSchedule.remove(at: index)
                keystore.synchronize()
            }
        }
    }
    
    func isInMySchedule(withRecordName recordName: String) -> Bool {
        
        let keystore = NSUbiquitousKeyValueStore()
        if let storedSchedule = keystore.object(forKey: ScheduleKey) as? [String] {
            return storedSchedule.contains(recordName)
        }
        
        return false
    }
    
    func scheduleItems() -> [String]? {
        
        let keystore = NSUbiquitousKeyValueStore()
        return keystore.object(forKey: ScheduleKey) as? [String]
        
    }
    
}
