//
//  Sponsor+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 28/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(Sponsor)
public class Sponsor: NSManagedObject {

    static let typeName = "Sponsor"
    
    class func createInstance(inContext context: NSManagedObjectContext) -> Sponsor {
        return NSEntityDescription.insertNewObject(forEntityName: Sponsor.typeName, into: context) as! Sponsor
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- \(Sponsor.typeName) ---")
        let request = NSFetchRequest<Sponsor>(entityName: Sponsor.typeName) as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["sponsorOrder"])
    }
    
    public override var description: String {
        return "Sponsor [name '\(name ?? "<not specified>")', " +
               "tagline '\(tagline ?? "<not specified>")', " +
               "sponsorOrder '\(sponsorOrder)', " +
               "]"
    }
    
    public override func prepareCKRecord(withCache cache: [String:CKRecord]) -> CKRecord? {
        
        if let recordName = recordName {
            let recordId = CKRecordID(recordName: "\(Sponsor.typeName)-\(recordName)")
            let ckRecord = CKRecord(recordType: Sponsor.typeName, recordID: recordId)
            
            ckRecord[RemoteSponsor.active] = NSNumber(booleanLiteral: active)
            ckRecord[RemoteSponsor.name] = name as NSString?
            ckRecord[RemoteSponsor.url] = url?.absoluteString as NSString?
            ckRecord[RemoteSponsor.cellType] = cellType as NSString?
            ckRecord[RemoteSponsor.note] = note as NSString?
            ckRecord[RemoteSponsor.sponsorCategory] = sponsorCategory as NSString?
            ckRecord[RemoteSponsor.sponsorOrder] = NSNumber(integerLiteral: Int(sponsorOrder))
            ckRecord[RemoteSponsor.tagline] = tagline as NSString?
            
            return ckRecord
        }
        
        return nil
    }
    
    class func prepareCKRecords(inContext context: NSManagedObjectContext, withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let request = NSFetchRequest<Sponsor>(entityName: Sponsor.typeName) as! NSFetchRequest<NSFetchRequestResult>
        return retrieveCKRecords(inContext: context, withRequest: request, withCache: cache)
    }
    
}
