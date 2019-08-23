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

/**
 Stores the selected status for a given session item.
 */
class SelectedSessionItemSetting: Codable {
    
    var name: String
    
    /** Indicates if the session item is selected. */
    var selected: Bool {
        didSet {
            self.dateUpdated = Date()
        }
    }
    
    /** Indicates the date when this setting was updated. */
    var dateUpdated: Date
    
    init(name: String, selected: Bool) {
        self.name = name
        self.selected = selected
        self.dateUpdated = Date()
    }
}

class IDUAppSettings: AppSettings {
    
    let ScheduleKeyPrefix = "schedule_"
    
    func key(forName name: String) -> String {
        return "\(ScheduleKeyPrefix)\(name)"
    }
    
    fileprivate func createScheduleItem(withName name: String, selected: Bool) -> [String:Any] {
        return [
            "name": name,
            "selected": selected,
            "date": Date()
        ]
    }
    
    fileprivate func updateSchedule(item: inout [String:Any], withSelected selected: Bool) {
        item["selected"] = selected
        item["date"] = Date()
    }
    
    func addMyScheduleItem(withRecordName recordName: String) {
        let keystore = NSUbiquitousKeyValueStore.default
        
        if var item = keystore.object(forKey: key(forName: recordName)) as? [String:Any] {
            updateSchedule(item: &item, withSelected: true)
            keystore.set(item, forKey: key(forName: recordName))
        }
        else {
            let itemToAdd = createScheduleItem(withName: recordName, selected: true)
            keystore.set(itemToAdd, forKey: key(forName: recordName))
        }
    }
    
    func removeMyScheduleItem(withRecordName recordName: String) {
        let keystore = NSUbiquitousKeyValueStore.default
        
        if var item = keystore.object(forKey: key(forName: recordName)) as? [String:Any] {
            updateSchedule(item: &item, withSelected: false)
            keystore.set(item, forKey: key(forName: recordName))
        }
    }
    
    func isInMySchedule(withRecordName recordName: String) -> Bool {
        
        let keystore = NSUbiquitousKeyValueStore.default
        if let item = keystore.object(forKey: key(forName: recordName)) as? [String:Any],
           let selected = item["selected"] as? Bool {
            return selected
        }
        
        return false
    }
    
    func scheduleItems() -> [String]? {
        
        let keystore = NSUbiquitousKeyValueStore.default
        
        var selectedItems = [String]()
        
        let keys = keystore.dictionaryRepresentation.keys
        for key in keys {
            if key.starts(with: ScheduleKeyPrefix) {
                if let item = keystore.object(forKey: key) as? [String:Any],
                   let selected = item["selected"] as? Bool,
                   let name = item["name"] as? String {
                    
                    if(selected) {
                        selectedItems.append(name)
                    }
                }
            }
            else {
                print("\(key) does not begin with \(ScheduleKeyPrefix)")
            }
        }
        
        return selectedItems
        
    }
    
    func synchronize() {
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
}
