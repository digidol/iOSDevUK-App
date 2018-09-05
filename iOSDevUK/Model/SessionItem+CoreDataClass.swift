//
//  SessionItem+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(SessionItem)
public class SessionItem: NSManagedObject {

    static let typeName = "SessionItem"
    
    class func createInstance(inContext context: NSManagedObjectContext) -> SessionItem {
        return NSEntityDescription.insertNewObject(forEntityName: typeName, into: context) as! SessionItem
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- \(SessionItem.typeName) ---")
        let request = NSFetchRequest<SessionItem>(entityName: typeName) as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["title"])
    }
    
    public override var description: String {
        return "SessionItem [title '\(title ?? "<not specified>")', " +
            "record name '\(recordName ?? "<not specified>")', " +
            "active '\(active))', " +
            "location: '\(String(describing: location)), " +
            "session: '\(String(describing: session))'," +
            "number of speakers: \(speakers?.count ?? -1)" +
        "]"
    }
    
    /**
     Create a list of names for the speakers associated with this talk.
     
     - Returns: A string that contains a list of speaker names, ordered by the name field.
     The names are joined together with the & character. If no names are found, the value
     -- (double dash) is returned. If there is no name for a speaker, the value Unknown is
     used for that speaker's name.
     */
    func speakerNames() -> String {
        
        var names = "--"
        
        if let speakers = self.speakers {
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            let speakerArray = speakers.sortedArray(using: [sortDescriptor]) as! [Speaker]
            names = speakerArray.reduce("", {
                partial, item in
                
                var result = partial
                
                if result.count != 0 {
                    result += " & "
                }
                result += item.name ?? "Unknown"
                return result
            })
        }
        
        return names
    }
    
    /**
     An array of speakers, sorted by the name field and in an ascending order.
     */
    var sortedSpeakerArray: [Speaker]? {
        if let speakers = self.speakers {
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            return speakers.sortedArray(using: [sortDescriptor]) as? [Speaker]
        }
        return nil
    }
    
    class func update(forRecordName recordName: String, inContext context: NSManagedObjectContext, withValues values: [String:Any?]) -> Bool {
        let request = NSFetchRequest<SessionItem>(entityName: typeName) as! NSFetchRequest<NSFetchRequestResult>
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        
        if let sessionItem = retrieve(withFetchRequest: request, inContext: context) as? SessionItem {
            // SessionItem(forRecordName: recordName, inContext: context) {
            return sessionItem.update(values: values)
        }
        
        return false
    }
    
    func update(values: [String:Any?]) -> Bool {
        
        var successCount = 0
        
        for (key, value) in values {
            print("Key: \(key) with value: \(String(describing: value))")
            if key == "title" {
                title = value as? String
                successCount += 1
            }
            else if key == "content" {
                content = value as? String
                successCount += 1
            }
            else if key == "session" {
                session = value as? Session
                successCount += 1
            }
            else if key == "recordName" {
                recordName = value as? String
                successCount += 1
            }
            else if key == "location" {
                location = value as? Location
                successCount += 1
            }
            else if key == "speakers" {
                if let speakerSet = speakers,
                   let speakerArray = value as? [Speaker] {
                    
                    removeFromSpeakers(speakerSet)
                    addToSpeakers(NSSet(array: speakerArray))
                    successCount += 1
                }
            }
            
        }
        
        return successCount == values.count
    }
    
    public override func prepareCKRecord(withCache cache: [String:CKRecord]) -> CKRecord? {
        if let recordName = recordName {
           let recordId = CKRecordID(recordName: "\(SessionItem.typeName)-\(recordName)")
            
            let ckRecord = CKRecord(recordType: SessionItem.typeName, recordID: recordId)
            
            ckRecord[RemoteSessionItem.title] = title as NSString?
            ckRecord[RemoteSessionItem.active] = NSNumber(booleanLiteral: active)
            ckRecord[RemoteSessionItem.content] = content as NSString?
            ckRecord[RemoteSessionItem.listOnFrontScreen] = NSNumber(booleanLiteral: listOnFrontScreen)
            ckRecord[RemoteSessionItem.order] = NSNumber(integerLiteral: Int(order))
            ckRecord[RemoteSessionItem.type] = type as NSString?
            
            if let sessionCKRecord = cache["\(Session.typeName)-\(session?.recordName ?? "Unknown")"] {
                ckRecord[RemoteSessionItem.session] = CKReference(record: sessionCKRecord, action: .none)
            }
            
            return ckRecord
        }
        
        return nil
        
    }
    
    class func prepareCKRecords(inContext context: NSManagedObjectContext, withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let request = NSFetchRequest<SessionItem>(entityName: typeName) as! NSFetchRequest<NSFetchRequestResult>
        return retrieveCKRecords(inContext: context, withRequest: request, withCache: cache)
    }
    
}
