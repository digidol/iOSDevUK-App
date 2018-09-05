//
//  Session+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

enum SessionType {
    static let coffeeBiscuits = "biscuits"
    static let coffeeCake = "cake"
    static let dinner = "dinner"
    static let lunch = "lunch"
    static let registration = "registration"
    static let social = "social"
    static let talk = "talk"
    static let workshop = "workshop"
    static let train = "train"
}

@objc(Session)
public class Session: NSManagedObject {

    static let typeName = "Session"
    
    class func createInstance(inContext context: NSManagedObjectContext) -> Session {
        return NSEntityDescription.insertNewObject(forEntityName: Session.typeName, into: context) as! Session
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- \(Session.typeName) ---")
        let request = NSFetchRequest<Session>(entityName: Session.typeName) as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["recordName"])
    }
    
    public override var description: String {
        return "Session [name '\(name ?? "<nil>")', " +
               "record name '\(recordName ?? "<nil>")', " +
               "startTime: \(String(describing: startTime))" + 
        "]"
    }
    
    func sessionItem(atPosition position: Int) -> SessionItem? {
        
        if let items = sessionItems?.sortedArray(using: [NSSortDescriptor(key: "location.recordName", ascending: false)]) as? [SessionItem] {
            if position < items.count {
                 return items[position]
            }
        }
        
        return nil
    }
    
    func sessionItems(whereUserSelected isUserSelected: Bool) -> [SessionItem]? {
        if let items = sessionItems?.sortedArray(using: [NSSortDescriptor(key: "location.recordName", ascending: false)]) as? [SessionItem] {
            
            var itemsToProcess = items
            
            if isUserSelected {
                itemsToProcess = items.filter({ (item) -> Bool in
                    return item.userSelected != nil
                })
            }
            
            return itemsToProcess
        }
        
        return nil
    }
    
    
    func sessionItem(atPosition position: Int, whereUserSelected isUserSelected: Bool) -> SessionItem? {
        
        if let items = sessionItems(whereUserSelected: isUserSelected) {
            if position < items.count {
                return items[position]
            }
        }
        
        return nil
    }
    
    /**
     Checks for a session that is running at the given time. The comparison is done
     on the basis that the specified date is within the start and end times for the
     session.
     
     - Parameters:
         - date: The date used for the comparison.
         - context: The context used to access the data.
     
     - Returns: If a matching session is found, it is returned. If no session is found, `nil` is returned.
     */
    class func nowSession(forDate date: Date, inContext context: NSManagedObjectContext) -> Session? {
        let nowRequest = NSFetchRequest<Session>(entityName: Session.typeName)
        nowRequest.predicate = NSPredicate(format: "startTime <= %@ and endTime >= %@", date as NSDate, date as NSDate)
        nowRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        
        var nowSession: Session?
        
        if let items = try? context.fetch(nowRequest) {
            if items.count > 0 {
                nowSession = items[0]
            }
        }
        else {
            print("IDU->ERROR : Unable to access now items")
        }
        
        return nowSession
    }
    
    /**
     Checks for a session that is running after the given. The comparison is done
     on the basis that the specified date is before the start of the session.
     
     This is only intended to be called when the conference is running. If called
     before the conference has started, the session returned should be the first session
     of the first day.
     
     - Parameters:
         - date: The date used for the comparison.
         - context: The context used to access the data.
     
     - Returns: If a matching session is found, it is returned. If no session is found, `nil` is returned.
     
     */
    class func nextSession(forDate date: Date, inContext context: NSManagedObjectContext) -> Session? {
        
        let nextRequest = NSFetchRequest<Session>(entityName: Session.typeName)
        nextRequest.predicate = NSPredicate(format: "startTime > %@", date as NSDate)
        nextRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        
        var nextSession: Session?
        
        if let items = try? context.fetch(nextRequest) {
            if items.count > 0 {
                nextSession = items[0]
            }
        }
        else {
            print("IDU->ERROR : Unable to access now items")
        }
        
        return nextSession
    }
    
    class func update(forRecordName recordName: String, inContext context: NSManagedObjectContext, withValues values: [String:Any?]) -> Bool {
        let request = NSFetchRequest<Session>(entityName: Session.typeName) as! NSFetchRequest<NSFetchRequestResult>
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        
        if let session = retrieve(withFetchRequest: request, inContext: context) as? Session {
            return session.update(values: values)
        }
        
        return false
    }
    
    func update(values: [String:Any?]) -> Bool {
        
        var successCount = 0
        
        for (key, value) in values {
            print("Key: \(key) with value: \(String(describing: value))")
            if key == "endTime" {
                endTime = value as? NSDate
                successCount += 1
            }
        }
        
        return successCount == values.count
    }
    
    public override func prepareCKRecord(withCache cache: [String:CKRecord]) -> CKRecord? {
        if let recordName = recordName {
            let recordId = CKRecordID(recordName: "\(Session.typeName)-\(recordName)")
            let ckRecord = CKRecord(recordType: Session.typeName, recordID: recordId)
            
            ckRecord[RemoteSession.name] = name as NSString?
            
            if let startTime = startTime as NSDate? {
                ckRecord[RemoteSession.startTime] = startTime
            }
            
            if let endTime = endTime as NSDate? {
                ckRecord[RemoteSession.endTime] = endTime
            }
            
            ckRecord[RemoteSession.type] = type as NSString?
            
            if let sectionCKRecord = cache["\(Section.typeName)-\(section?.recordName ?? "Unknown")"] {
                ckRecord[RemoteSession.section] = CKReference(record: sectionCKRecord, action: .none)
            }
            
            return ckRecord
        }
        
        return nil
        
    }
    
    class func prepareCKRecords(inContext context: NSManagedObjectContext, withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let request = NSFetchRequest<Session>(entityName: Session.typeName) as! NSFetchRequest<NSFetchRequestResult>
        return retrieveCKRecords(inContext: context, withRequest: request, withCache: cache)
    }
    
    class func find(recordName: String, inContext context: NSManagedObjectContext) -> Session? {
        let request = NSFetchRequest<Session>(entityName: Session.typeName) as! NSFetchRequest<NSFetchRequestResult>
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        
        if let session = retrieve(withFetchRequest: request, inContext: context) as? Session {
            return session
        }
        
        return nil
    }
    
}
