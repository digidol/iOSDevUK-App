//
//  WebLink+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

@objc(WebLink)
public class WebLink: NSManagedObject {

    static let typeName = "WebLink"
    
    class func createInstance(inContext context: NSManagedObjectContext) -> WebLink {
        return NSEntityDescription.insertNewObject(forEntityName: WebLink.typeName, into: context) as! WebLink
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- \(WebLink.typeName) ---")
        let request = NSFetchRequest<WebLink>(entityName: WebLink.typeName) as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["name"])
    }
    
    public override var description: String {
        return "WebLink [name '\(name ?? "<not specified>")', " +
        "]"
    }
    
    public override func prepareCKRecord(withCache cache: [String:CKRecord]) -> CKRecord? {
        
        if let recordName = recordName {
            let recordId = CKRecordID(recordName: "\(WebLink.typeName)-\(recordName)")
            let ckRecord = CKRecord(recordType: WebLink.typeName, recordID: recordId)
            
            ckRecord[RemoteWebLink.active] = NSNumber(booleanLiteral: active)
            ckRecord[RemoteWebLink.name] = name as NSString?
            ckRecord[RemoteWebLink.url] = url?.absoluteString as NSString?
            
            return ckRecord
        }
        
        return nil
    }
    
    class func prepareCKRecords(inContext context: NSManagedObjectContext, withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let request = NSFetchRequest<WebLink>(entityName: WebLink.typeName) as! NSFetchRequest<NSFetchRequestResult>
        return retrieveCKRecords(inContext: context, withRequest: request, withCache: cache)
    }
}
