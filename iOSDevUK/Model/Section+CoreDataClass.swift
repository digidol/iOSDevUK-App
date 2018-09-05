//
//  Section+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(Section)
public class Section: NSManagedObject {

    static let typeName = "Section"
    
    class func createInstance(inContext context: NSManagedObjectContext) -> Section {
        return NSEntityDescription.insertNewObject(forEntityName: Section.typeName, into: context) as! Section
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- \(Section.typeName) ---")
        let request = NSFetchRequest<Section>(entityName: Section.typeName) as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["day.date", "recordName"])
    }
    
    public override var description: String {
        return "Section [name '\(name ?? "<not specified>")', " +
            "record name: '\(recordName ?? "<nil>")', " +
            "number of sessions: \(sessions?.count ?? -1), " +
        "]"
    }
    
    public override func prepareCKRecord(withCache cache: [String:CKRecord]) -> CKRecord? {
        
        if let recordName = recordName {
            let recordId = CKRecordID(recordName: "\(Section.typeName)-\(recordName)")
            let ckRecord = CKRecord(recordType: Section.typeName, recordID: recordId)
            
            ckRecord[RemoteSection.name] = name as NSString?
            ckRecord[RemoteSection.header] = header as NSString?
            ckRecord[RemoteSection.footer] = footer as NSString?
            
            if let date = day?.dateAsString(),
               let dayCKRecord = cache["\(Day.typeName)-\(date)"] {
                ckRecord[RemoteSection.day] = CKReference(record: dayCKRecord, action: .none)
            }
            
            return ckRecord
        }
        
        return nil
    }
    
    class func prepareCKRecords(inContext context: NSManagedObjectContext, withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let request = NSFetchRequest<Section>(entityName: Section.typeName) as! NSFetchRequest<NSFetchRequestResult>
        return retrieveCKRecords(inContext: context, withRequest: request, withCache: cache)
    }
    
    class func find(recordName: String, inContext context: NSManagedObjectContext) -> Section? {
        let request = NSFetchRequest<Section>(entityName: Section.typeName) as! NSFetchRequest<NSFetchRequestResult>
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        
        if let section = retrieve(withFetchRequest: request, inContext: context) as? Section {
            return section
        }
        
        return nil
    }
}
