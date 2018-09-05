//
//  IDUNSManagedObject.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

public extension NSManagedObject {
    
    
    class func listInstances(inContext context: NSManagedObjectContext, withRequest request: NSFetchRequest<NSFetchRequestResult>, withKeys orderKeys: [String]?) {
        
        if let keys = orderKeys {
            request.sortDescriptors = [NSSortDescriptor]()
            
            for key in keys {
                let sortDescriptor = NSSortDescriptor(key: key, ascending: true)
                request.sortDescriptors?.append(sortDescriptor)
            }
            print("Sort decriptors: \(request.sortDescriptors!)")
        }
        
        if let items = try? context.fetch(request) {
            for item in items {
                print(String(describing: item))
            }
        }
        else {
            print("something went wrong")
        }
    }
    
    class func retrieve(withFetchRequest request: NSFetchRequest<NSFetchRequestResult>, inContext context: NSManagedObjectContext) -> Any? {
        
        if let items = try? context.fetch(request) {
            if items.count == 1 {
                return items[0]
            }
        }
        
        print("Unable to access item")
        return nil
    }
    
    /**
     
     - Parameters:
         - context: The NSManagedObjectContext for retrieving the entities.
         - request: The request to use to access the required records.
     
     - Returns: An array of `CKRecord` objects that were created from the fetch request.
     */
    class func retrieveCKRecords(inContext context: NSManagedObjectContext, withRequest request: NSFetchRequest<NSFetchRequestResult>, withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        
        var ckRecords = [String:CKRecord]()
        
        if let items = try? context.fetch(request) {
            for item in items {
                if let record = item as? NSManagedObject,
                   let ckRecord = record.prepareCKRecord(withCache: cache) {
                    ckRecords["\(ckRecord.recordID.recordName)"] = ckRecord
                }
                else {
                    print("unable to convert \(item)")
                }
            }
        }
        else {
            print("something went wrong")
        }
        
        return ckRecords
    }
    
    /**
     Prepares a CKRecord using the infomration in the NSManagedObject subclass. This function is a
     placeholder and should be overriden by subclasses if this functionality is needed. This
     default implementation returns `nil`.
     
     - Returns: A CKRecord with the revelvant fields added for the type, or nil if it was not possible
     to create the record or the function was not overriden
     */
    @objc func prepareCKRecord(withCache cache: [String:CKRecord]) -> CKRecord? {
        return nil
    }
    
    /**
     Updates the data in the current managed object with the information stored in the CKRecord.
     This function is a placeholder and should be overriden by subclasses if this functionality is
     needed. The default implementation returns `false`.
     
     - Parameters:
          - record: The data that is to be used to update this record.
     
     - Returns: `true` if the record was successfully processed, otherwise `false` is returned.
     */
    @objc func update(with record: CKRecord) -> Bool {
        return false
    }
    
}
