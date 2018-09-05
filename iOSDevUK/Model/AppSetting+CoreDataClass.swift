//
//  Setting+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData

@objc(AppSetting)
public class AppSetting: NSManagedObject {

    class func createInstance(inContext context: NSManagedObjectContext) -> AppSetting {
        return NSEntityDescription.insertNewObject(forEntityName: "AppSetting", into: context) as! AppSetting
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- AppSettings ---")
        let request = NSFetchRequest<AppSetting>(entityName: "AppSetting") as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["name"])
    }
    
    fileprivate static func accessSetting(inContext context: NSManagedObjectContext, forName name: String) -> AppSetting? {
        let request = NSFetchRequest<AppSetting>(entityName: "AppSetting")
        request.predicate = NSPredicate(format: "name = %@", name)
        
        if let settings = try? context.fetch(request) {
            return settings.first
        }
        else {
            print("unable to access \(name)")
        }
        
        return nil
    }
    
    /**
     Accesses the date value for the given app setting.
     
     - Parameters:
         - context: The managed object context to use to access the data.
         - name: The name of the app setting to access.
     
     - Returns: The date value, if present, otherwise nil.
     */
    static func accessDateValue(inContext context: NSManagedObjectContext, forName name: String) -> NSDate? {
        if let setting = accessSetting(inContext: context, forName: name) {
            return setting.dateValue
        }
        else {
            print("unable to access \(name)")
            return nil
        }
    }
    
    class func conferenceStartTime(inContext context: NSManagedObjectContext) -> NSDate? {
        return accessDateValue(inContext: context, forName: "conference-start-time")
    }
    
    class func conferenceEndTime(inContext context: NSManagedObjectContext) -> NSDate? {
        return accessDateValue(inContext: context, forName: "conference-end-time")
    }
    
    class func dataModelVersion(inContext context: NSManagedObjectContext) -> Int32 {
        
        if let setting = accessSetting(inContext: context, forName: "data-model-version") {
            return setting.intValue
        }
        else {
            print("unable to access data-model-version")
            return 0
        }
    }
    
    public override var description: String {
        return "Setting [name '\(name ?? "<not specified>")', " +
        "]"
    }
    
    class func update(forRecordName recordName: String, inContext context: NSManagedObjectContext, withValues values: [String:Any?]) -> Bool {
        let request = NSFetchRequest<AppSetting>(entityName: "AppSetting") as! NSFetchRequest<NSFetchRequestResult>
        request.predicate = NSPredicate(format: "name = %@", recordName)
        
        if let setting = retrieve(withFetchRequest: request, inContext: context) as? AppSetting {
            return setting.update(values: values)
        }
        
        return false
    }
    
    /**
     Update the AppSetting. This currently supports update of the following fields.
     
     * `intValue` - Expects an Int value
     * `note` - Expects a String. This can be nil.
     
     - Parameter values: The dictionary of values that will be processed. The key is
     the field that will be updated. The value is assigned.
     
     - Returns: True if all of the data could be updated.
     */
    func update(values: [String:Any?]) -> Bool {
        
        var successCount = 0
        
        for (key, value) in values {
            print("Key: \(key) with value: \(String(describing: value))")
            if key == "intValue" {
                if let theValue = value as? Int {
                    intValue = Int32(theValue)
                    successCount += 1
                }
            }
            else if key == "note" {
                note = value as? String
                successCount += 1
            }
        }
        print("Success Count: \(successCount) Values: \(values.count)")
        return successCount == values.count
    }
    
}
