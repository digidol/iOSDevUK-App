//
//  Speaker+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(Speaker)
public class Speaker: NSManagedObject {

    static let typeName = "Speaker"
    
    class func createInstance(inContext context: NSManagedObjectContext) -> Speaker {
        return NSEntityDescription.insertNewObject(forEntityName: Speaker.typeName, into: context) as! Speaker
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- \(Speaker.typeName) ---")
        let request = NSFetchRequest<Speaker>(entityName: Speaker.typeName) as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["name"])
    }
    
    public override var description: String {
        return "Speaker [name '\(name ?? "<not specified>")', " +
            "record name: '\(recordName ?? "<nil>")', " +
            "twitterId: '\(twitterId ?? "<nil>")', " +
            "linkedIn: '\(linkedIn ?? "<nil>")', " +
            "number of sessionsItems: \(sessionItems?.count ?? -1), " +
            "number of weblinks: \(webLinks?.count ?? -1)" +
        "]"
    }
    
    /**
     Access the session item for the given record name.
     
     - Parameters:
     - forRecordName: The name that is used for the SessionItem.
     - inContext: The managed object context used to access the data.
     
     - Returns: The session item or nil if no session item matches the given record name.
     */
    /*class func retrieveSpeaker(forRecordName recordName: String, inContext context: NSManagedObjectContext) -> Speaker? {
        let request = NSFetchRequest<Speaker>(entityName: "Speaker")
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        
        if let speakers = try? context.fetch(request) {
            if speakers.count == 1 {
                return speakers[0]
            }
        }
        
        print("Unable to access Speaker for the given name")
        return nil
    }*/
    
    class func update(forRecordName recordName: String, inContext context: NSManagedObjectContext, withValues values: [String:Any?]) -> Bool {
        let request = NSFetchRequest<Speaker>(entityName: Speaker.typeName) as! NSFetchRequest<NSFetchRequestResult>
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        
        if let speaker = retrieve(withFetchRequest: request, inContext: context) as? Speaker {
            return speaker.update(values: values)
        }
        
        return false
    }
    
    func update(values: [String:Any?]) -> Bool {
        
        var successCount = 0
        
        for (key, value) in values {
            print("Key: \(key) with value: \(String(describing: value))")
            
            if key == "biography" {
                biography = value as? String
                successCount += 1
            }
        }
        
        return successCount == values.count
    }
    
    public override func prepareCKRecord(withCache cache: [String:CKRecord]) -> CKRecord? {
        if let recordName = recordName {
            let recordId = CKRecordID(recordName: "\(Speaker.typeName)-\(recordName)")
            
            let ckRecord = CKRecord(recordType: Speaker.typeName, recordID: recordId)
            
            ckRecord[RemoteSpeaker.name] = name as NSString?
            ckRecord[RemoteSpeaker.twitterId] = twitterId as NSString?
            ckRecord[RemoteSpeaker.linkedIn] = linkedIn as NSString?
            ckRecord[RemoteSpeaker.biography] = biography as NSString?
            
            var webLinkArray = [CKReference]()
            
            if let webLinks = webLinks {
                for webLink in webLinks {
                    if let link = webLink as? WebLink,
                       let recordName = link.recordName,
                       let webLinkCKRecord = cache["\(WebLink.typeName)-\(recordName)"] {
                        
                        webLinkArray.append(CKReference(record: webLinkCKRecord, action: .none))
                    }
                }
            }
            
            if webLinkArray.count > 0 {
                ckRecord[RemoteSpeaker.webLinks] = webLinkArray as NSArray
            }
            
            var sessionItemArray = [CKReference]()
            
            if let sessionItems = sessionItems {
                for sessionItem in sessionItems {
                    if let item = sessionItem as? SessionItem,
                        let recordName = item.recordName,
                        let sessionItemCKRecord = cache["\(SessionItem.typeName)-\(recordName)"] {
                        
                        sessionItemArray.append(CKReference(record:sessionItemCKRecord, action: .none))
                    }
                }
            }
            
            if sessionItemArray.count > 0 {
                ckRecord[RemoteSpeaker.sessionItems] = sessionItemArray as NSArray
            }
            
            return ckRecord
        }
        
        return nil
        
    }
    
    class func prepareCKRecords(inContext context: NSManagedObjectContext, withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let request = NSFetchRequest<Speaker>(entityName: Speaker.typeName) as! NSFetchRequest<NSFetchRequestResult>
        return retrieveCKRecords(inContext: context, withRequest: request, withCache: cache)
    }
    
    /**
     Retrieves a speaker for the given record name.
     */
    class func find(recordName: String, inContext context: NSManagedObjectContext) -> Speaker? {
        let request = NSFetchRequest<Speaker>(entityName: Speaker.typeName) as! NSFetchRequest<NSFetchRequestResult>
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        
        if let speaker = retrieve(withFetchRequest: request, inContext: context) as? Speaker {
            return speaker
        }
        
        return nil
    }
    
}
