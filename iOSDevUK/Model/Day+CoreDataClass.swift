//
//  Day+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(Day)
public class Day: NSManagedObject {
    
    static let typeName = "Day"
    
    class func createInstance(inContext context: NSManagedObjectContext) -> Day {
        return NSEntityDescription.insertNewObject(forEntityName: Day.typeName, into: context) as! Day
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- \(Day.typeName) ---")
        let request = NSFetchRequest<Day>(entityName: Day.typeName) as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["date"])
    }
    
    public override var description: String {
        return "Location [date '\(String(describing: date))', " +
            "number of sections \(sections?.count ?? -1)" +
        "]"
    }
    
    /**
     Creates a string representation for the date value. The `ISO8601DateFormatter` is
     used to format the date.
     
     - Returns: If the `date` is not set to a value, `nil` will be returned.
     */
    func dateAsString() -> String? {
        
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/London")
        
        if let date = date as Date? {
            return formatter.string(from: date)
        }
        
        return nil
    }
    
    
    /**
     Prepares a set of CKRecords for all instances of this data type. The data is accessed from
     the given context. The cache is available to lookup any references.
     
     The records will be retrieved by calling `retrieveCKRecords` from this function.
     
     - Parameters:
         - context: The managed object context that will be used to retrieve the data.
         - cache: The cache of any existing CKRecords that have been created locally on the device,
                  prior to calling this function.
     
     - Returns: A dictionary of CKRecords generated for this data type. A string is created as a key to
     enable lookup later in the process.
     */
    class func prepareCKRecords(inContext context: NSManagedObjectContext, withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let request = NSFetchRequest<Day>(entityName: Day.typeName) as! NSFetchRequest<NSFetchRequestResult>
        return retrieveCKRecords(inContext: context, withRequest: request, withCache: cache)
    }
    
    /**
     Prepares a CKRecord for the data in this object.
     
     - Parameters:
         - cache: The dictionary of existing CKRecords to setup any references.
     
     - Returns: An record with the data for this object. If the date field cannot
     be converted to a string representation by calling `dateAsString()`, the result will be nil.
     */
    public override func prepareCKRecord(withCache cache: [String:CKRecord]) -> CKRecord? {
        
        if let dateString = dateAsString() {
            let ckRecord = CKRecord(recordType: Day.typeName, recordID: CKRecordID(recordName: "\(Day.typeName)-\(dateString)"))
            ckRecord[RemoteDay.date] = date
            return ckRecord
        }
        
        return nil
        
    }
    
       
}
