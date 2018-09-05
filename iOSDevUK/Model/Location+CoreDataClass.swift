//
//  Location+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

@objc(Location)
public class Location: NSManagedObject {

    static let typeName = "Location"
    
    class func createInstance(inContext context: NSManagedObjectContext) -> Location {
        return NSEntityDescription.insertNewObject(forEntityName: Location.typeName, into: context) as! Location
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- \(Location.typeName) ---")
        let request = NSFetchRequest<Location>(entityName: Location.typeName) as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["name"])
    }
    
    public override var description: String {
        return "Location [name '\(name ?? "<not specified>")', " +
            "record name '\(recordName ?? "<nil>")', " +
            "short name '\(shortName ?? "<nil>")', " +
            "longitude '\(longitude)', " +
            "latitude '\(latitude)', " +
            "active '\(active)', " +
            "locationType {'}\(String(describing: locationType))}, " +
            "number of sessions \(sessions?.count ?? -1)" +
        "]"
    }
    
    /**
     Prepares a new CKRecord for this location. It contains the followig fields:
     
     - active
     - frontListPosition
     - locationType - this will be a CKReference to a record that has a CKRecordId for the
     recordName field in the LocationType entity.
     - name
     - note
     - shortName
     - showImage
     
     - Returns: A CKRecord with the fields completed.
     
     */
    public override func prepareCKRecord(withCache cache: [String:CKRecord]) -> CKRecord? {
        
        if let recordName = recordName {
            let recordId = CKRecordID(recordName: "\(Location.typeName)-\(recordName)")
            let ckRecord = CKRecord(recordType: Location.typeName, recordID: recordId)
            
            ckRecord[RemoteLocation.active] = NSNumber(booleanLiteral: active)
            ckRecord[RemoteLocation.frontListPosition] = NSNumber(integerLiteral: Int(frontListPosition))
            
            if let locationTypeRecordName = locationType?.recordName,
                let locationTypeCKRecord = cache["\(LocationType.typeName)-\(locationTypeRecordName)"] {
                ckRecord[RemoteLocation.locationType] = CKReference(record: locationTypeCKRecord, action: .none)
            }
            
            if let webLinkRecordName = webLink?.recordName,
                let webLinkCKRecord = cache["\(WebLink.typeName)-\(webLinkRecordName)"] {
                
                ckRecord[RemoteLocation.webLink] = CKReference(record: webLinkCKRecord, action: .none)
            }
            
            ckRecord[RemoteLocation.name] = name as NSString?
            ckRecord[RemoteLocation.note] = note as NSString?
            ckRecord[RemoteLocation.shortName] = shortName as NSString?
            ckRecord[RemoteLocation.showImage] = NSNumber(booleanLiteral: showImage)
            
            return ckRecord
        }
        
        return nil
        
    }
    
    /**
 
     */
    class func prepareCKRecords(inContext context: NSManagedObjectContext, withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let request = NSFetchRequest<Location>(entityName: Location.typeName) as! NSFetchRequest<NSFetchRequestResult>
        return retrieveCKRecords(inContext: context, withRequest: request, withCache: cache)
    }
    
    /**
 
     */
    class func find(recordName: String, inContext context: NSManagedObjectContext) -> Location? {
        let request = NSFetchRequest<Location>(entityName: Location.typeName) as! NSFetchRequest<NSFetchRequestResult>
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        
        if let location = retrieve(withFetchRequest: request, inContext: context) as? Location {
            return location
        }
        
        return nil
    }
    
}
