//
//  LocationType+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(LocationType)
public class LocationType: NSManagedObject {

    static let typeName = "LocationType"
    
    // MARK: - Class functions
    
    class func createInstance(inContext context: NSManagedObjectContext) -> LocationType {
        return NSEntityDescription.insertNewObject(forEntityName: LocationType.typeName, into: context) as! LocationType
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- \(LocationType.typeName) ---")
        let request = NSFetchRequest<LocationType>(entityName: LocationType.typeName) as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["name"])
    }
    
    // MARK: - Instance functions
    
    public override var description: String {
        return "LocationType [name '\(name ?? "<nil>")', " +
            "record name: '\(recordName ?? "<nil>")', " +
            "number of locations: \(locations?.count ?? -1)" +
        "]"
    }
    
    class func prepareCKRecords(inContext context: NSManagedObjectContext, withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let request = NSFetchRequest<LocationType>(entityName: LocationType.typeName) as! NSFetchRequest<NSFetchRequestResult>
        return retrieveCKRecords(inContext: context, withRequest: request, withCache: cache)
    }
    
    /**
     Creates a CKRecord for this location type. The record Id will be set to
     the recordName for this record.
     
     - name
     - order
     - note
     
     - Returns: A record with the values for the specified fields.
     */
    public override func prepareCKRecord(withCache cache: [String:CKRecord]) -> CKRecord? {
        
        if let recordName = recordName {
            let recordId = CKRecordID(recordName: "\(Location.typeName)-\(recordName)")
            let ckRecord = CKRecord(recordType: LocationType.typeName, recordID: recordId)
        
            ckRecord[RemoteLocationType.name] = name as NSString?
            ckRecord[RemoteLocationType.order] = order as NSNumber?
            ckRecord[RemoteLocationType.note] = note as NSString?
        
            return ckRecord
        }
        
        return nil
    }
    
    
    
}
