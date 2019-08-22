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
    
    func synchronize()
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
        let keystore = NSUbiquitousKeyValueStore.default
        
        if var storedSchedule = keystore.object(forKey: ScheduleKey) as? [String] {
            if let index = storedSchedule.firstIndex(of: recordName) {
                let removedValue = storedSchedule.remove(at: index)
                print("Removing \(recordName) and removed \(removedValue)")
                keystore.set(storedSchedule, forKey: ScheduleKey)
                //keystore.synchronize()
            }
        }
    }
    
    func isInMySchedule(withRecordName recordName: String) -> Bool {
        
        let keystore = NSUbiquitousKeyValueStore.default
        if let storedSchedule = keystore.object(forKey: ScheduleKey) as? [String] {
            return storedSchedule.contains(recordName)
        }
        
        return false
    }
    
    func scheduleItems() -> [String]? {
        
        let keystore = NSUbiquitousKeyValueStore.default
        
        let keys = keystore.dictionaryRepresentation.keys
        for k in keys {
            if k.starts(with: "sch") {
                print(k)
            }
            else {
                print("\(k) does not begin with sch")
            }
        }
        
        return keystore.object(forKey: ScheduleKey) as? [String]
        
    }
    
    func synchronize() {
        let keystore = NSUbiquitousKeyValueStore.default
        keystore.synchronize()
    }
    
}
