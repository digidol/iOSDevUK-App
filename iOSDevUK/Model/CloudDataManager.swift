//
//  CloudDataManager.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 29/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

/**
 This class is designed to provide functionality to transmit data from
 the CoreData store to iCloud using CloudKit. This has been done in stages
 and driven manually. A better way is desired for the future, probably starting
 with the data on the server and modifying how that data is loaded into the
 app.
 */
class CloudDataManager {
    
    /**
     The container that will be used for the cloud access. This is different from the default container
     that the CKContainer can provide.
     */
    let container: CKContainer
    
    /**
     Managed Object Context that is used to access the local data.
     */
    var viewContext: NSManagedObjectContext
    
    /**
     Initiliases the manager by setting the managed object context and initilisting the container
     in iCloud.
     
     - Parameter context: The Managed Object Context that will provide access to the local data store.
     */
    init(context: NSManagedObjectContext) {
        viewContext = context
        container = CKContainer.init(identifier: "iCloud.uk.ac.aber.iOSDevUK.programme")
    }
    
    /**
     Retrieves a set of updates from the server. This currently accesses all updates. This should be
     modified to only request updates that have a version number greater than any updates we have
     previously downloaded.
     
     Once the updates are downloaded, the information is sent to the console.
     
     A `CKOperation` is started to download the different types of remote records that are
     identified in the list of references that are updated.
     */
    func retrieveUpdates() {
        let predicate = NSPredicate(format: "active == 1")
        let query = CKQuery(recordType: "Update", predicate: predicate)
        query.sortDescriptors = [
            NSSortDescriptor(key: "version", ascending: true)
        ]
        
        container.publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print("Error \(error?.localizedDescription ?? "Missing Description")")
            }
            else {
                guard let records = records else { return }
                
                for record in records {
                    print("Retrieved record \(record)")
                    
                    if let sessionItems = record["sessionItemChanges"] as? [CKReference] {
                        
                        var recordNames = [String]()
                        
                        for sessionItem in sessionItems {
                            recordNames.append(sessionItem.recordID.recordName)
                        }
                        
                        let predicate = NSPredicate(format: "recordID IN %@", sessionItems)
                        let query = CKQuery(recordType: "SessionItem", predicate: predicate)
                        let operation = CKQueryOperation(query: query)
                        operation.queryCompletionBlock = {
                            cursor, error in
                            if error != nil {
                                print("Error accessing session items: \(error?.localizedDescription ?? "No error message")")
                            }
                            else {
                                if cursor != nil {
                                    print("there are more records")
                                }
                                else {
                                    print("completed the query?")
                                }
                            }
                            
                        }
                        
                        operation.completionBlock = {
                            print("finished..")
                        }
                        
                        operation.recordFetchedBlock = {
                            record in
                            print("the record is: \(record)")
                        }
                        
                        self.container.publicCloudDatabase.add(operation)
                    }
                
                    
                }
                
                print("Number of records: \(records.count)")
            }
        }
    }
    
    /**
     Downloads all of the remote records for the given entity. The predicate used will
     download every record for the type. No sort descriptor is used.
     
     Once downloaded, the records are printed.
     
     - Parameter entity: The name of the entity that is to be downloaded.
     */
    func retrieve(entity: String) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: entity, predicate: predicate)
        
        container.publicCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print("Error \(error?.localizedDescription ?? "Missing Description")")
            }
            else {
                guard let records = records else { return }
                
                for record in records {
                    print("Retrieved record \(record)")
                    
                    if entity == "Update" {
                        
                        if let sessionItems = record["sessionItemChanges"] as? [CKReference] {
                            
                            var recordNames = [String]()
                            
                            for sessionItem in sessionItems {
                                recordNames.append(sessionItem.recordID.recordName)
                            }
                            
                            let predicate = NSPredicate(format: "recordID IN %@", sessionItems)
                            let query = CKQuery(recordType: "SessionItem", predicate: predicate)
                            let operation = CKQueryOperation(query: query)
                            operation.queryCompletionBlock = {
                                cursor, error in
                                if error != nil {
                                    print("Error accessing session items: \(error?.localizedDescription ?? "No error message")")
                                }
                                else {
                                    if cursor != nil {
                                        print("there are more records")
                                    }
                                    else {
                                        print("completed the query?")
                                    }
                                }
                            }
                            
                            operation.completionBlock = {
                                print("finished..")
                            }
                            
                            operation.recordFetchedBlock = {
                                record in
                                print("the record is: \(record)")
                            }
                            
                            self.container.publicCloudDatabase.add(operation)
                        }
                    }
                    
                }
                
                print("Number of records: \(records.count)")
            }
        }
    }
    
    func save(records: [String:CKRecord]) {
        
        let array = records.values.filter { (record) -> Bool in
            //print(record)
            return true
        }
        
        for record in array {
            container.publicCloudDatabase.save(record) {
                
                record,error in
                if error != nil {
                    print(error?.localizedDescription ?? "Missing Error Message")
                    if let recordName = record?["recordName"] {
                        print("error for record: \(recordName)")
                    }
                }
                else {
                    print("Saved record: \(String(describing: record))")
                }
            }
        }
        
    }
    
    /**
 
     */
    func upload() {
        
        var recordCache = [String:CKRecord]()
        
        let dayRecords = prepareDays(withCache: recordCache)
        print("Number of day: \(dayRecords.count)")
        recordCache.merge(dayRecords) { (current, new) -> CKRecord in new }
        
        let webLinkRecords = prepareWebLinks(withCache: recordCache)
        print("Number of web links: \(webLinkRecords.count)")
        recordCache.merge(webLinkRecords) { (current, new) -> CKRecord in new }
        
        let locationTypeRecords = prepareLocationTypes(withCache: recordCache)
        print("Number of location types: \(locationTypeRecords.count)")
        recordCache.merge(locationTypeRecords) { (current, new) -> CKRecord in new }
 
        let locationRecords = prepareLocations(withCache: recordCache)
        print("Number of locations: \(locationRecords.count)")
        recordCache.merge(locationRecords) { (current, new) -> CKRecord in new }
        
        let sectionRecords = prepareSections(withCache: recordCache)
        print("Number of sections: \(sectionRecords.count)")
        recordCache.merge(sectionRecords) { (current, new) -> CKRecord in new }
        
        let sessionRecords = prepareSessions(withCache: recordCache)
        print("Number of sessions: \(sessionRecords.count)")
        recordCache.merge(sessionRecords) { (current, new) -> CKRecord in new }
        
        let sessionItemRecords = prepareSessionItems(withCache: recordCache)
        print("Number of sessions items: \(sessionItemRecords.count)")
        recordCache.merge(sessionItemRecords) { (current, new) -> CKRecord in new }
        
        let speakerRecords = prepareSpeakers(withCache: recordCache)
        print("Number of speakers: \(speakerRecords.count)")
        recordCache.merge(speakerRecords) { (current, new) -> CKRecord in new }
        
        let sponsorRecords = prepareSponsors(withCache: recordCache)
        print("Number of sponsors: \(sponsorRecords.count)")
        recordCache.merge(sponsorRecords) { (current, new) -> CKRecord in new }
        
        //retrieve(entity: RemoteRecord.day)
        //save(records: dayRecords)
        
        //retrieve(entity: RemoteRecord.locationType)
        //save(records: locationTypeRecords)
        
        //retrieve(entity: RemoteRecord.webLink)
        //save(records: webLinkRecords)
        
        //retrieve(entity: RemoteRecord.location)
        //save(records: locationRecords)
        
        //retrieve(entity: RemoteRecord.section)
        //save(records: sectionRecords)
        
        //retrieve(entity: RemoteRecord.session)
        //save(records: sessionRecords)
        
        //retrieve(entity: RemoteRecord.sessionItem)
        //save(records: sessionItemRecords)
        
        //retrieve(entity: RemoteRecord.speaker)
        //save(records: speakerRecords)
        
        //retrieve(entity: RemoteRecord.sponsor)
        //save(records: sponsorRecords)
        
        retrieveUpdates()
        
    }
    
    // MARK: - Prepare records
    
    /**
     Prepare CKRecords to describe the Days and place them into a cache.
     
     - Parameter cache: The cache of any existing CKRecords prepared prior to
     calling this function.
     
     - Returns: A dictionary of CKRecords generated from within this function.
     This only includes new CKRecords and is not currently merged with those passed
     in as a parameter.
     */
    func prepareDays(withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let records = Day.prepareCKRecords(inContext: viewContext, withCache: cache)
        display(records)
        return records
    }
    
    /**
     Prepare CKRecords to describe the Location Types and place them into a cache.
     
     - Parameter cache: The cache of any existing CKRecords prepared prior to
     calling this function.
     
     - Returns: A dictionary of CKRecords generated from within this function.
     This only includes new CKRecords and is not currently merged with those passed
     in as a parameter.
     */
    func prepareLocationTypes(withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let records = LocationType.prepareCKRecords(inContext: viewContext, withCache: cache)
        display(records)
        return records
    }
    
    /**
     Prepare CKRecords to describe the Locations and place them into a cache.
     
     - Parameter cache: The cache of any existing CKRecords prepared prior to
     calling this function.
     
     - Returns: A dictionary of CKRecords generated from within this function.
     This only includes new CKRecords and is not currently merged with those passed
     in as a parameter.
     */
    func prepareLocations(withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let records = Location.prepareCKRecords(inContext: viewContext, withCache: cache)
        display(records)
        return records
    }
    
    /**
     Prepare CKRecords to describe the Sections and place them into a cache.
     
     - Parameter cache: The cache of any existing CKRecords prepared prior to
     calling this function.
     
     - Returns: A dictionary of CKRecords generated from within this function.
     This only includes new CKRecords and is not currently merged with those passed
     in as a parameter.
     */
    func prepareSections(withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let records = Section.prepareCKRecords(inContext: viewContext, withCache: cache)
        display(records)
        return records
    }
    
    /**
     Prepare CKRecords to describe the Sessions and place them into a cache.
     
     - Parameter cache: The cache of any existing CKRecords prepared prior to
     calling this function.
     
     - Returns: A dictionary of CKRecords generated from within this function.
     This only includes new CKRecords and is not currently merged with those passed
     in as a parameter.
     */
    func prepareSessions(withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let records = Session.prepareCKRecords(inContext: viewContext, withCache: cache)
        display(records)
        return records
    }
    
    /**
     Prepare CKRecords to describe the SessionItems and place them into a cache.
     
     - Parameter cache: The cache of any existing CKRecords prepared prior to
     calling this function.
     
     - Returns: A dictionary of CKRecords generated from within this function.
     This only includes new CKRecords and is not currently merged with those passed
     in as a parameter.
     */
    func prepareSessionItems(withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let records = SessionItem.prepareCKRecords(inContext: viewContext, withCache: cache)
        display(records)
        return records
    }
    
    /**
     Prepare CKRecords to describe the Speakers and place them into a cache.
     
     - Parameter cache: The cache of any existing CKRecords prepared prior to
     calling this function.
     
     - Returns: A dictionary of CKRecords generated from within this function.
     This only includes new CKRecords and is not currently merged with those passed
     in as a parameter.
     */
    func prepareSpeakers(withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let records = Speaker.prepareCKRecords(inContext: viewContext, withCache: cache)
        display(records)
        return records
    }
    
    /**
     Prepare CKRecords to describe the Sponsors and place them into a cache.
     
     - Parameter cache: The cache of any existing CKRecords prepared prior to
     calling this function.
     
     - Returns: A dictionary of CKRecords generated from within this function.
     This only includes new CKRecords and is not currently merged with those passed
     in as a parameter.
     */
    func prepareSponsors(withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let records = Sponsor.prepareCKRecords(inContext: viewContext, withCache: cache)
        display(records)
        return records
    }
    
    /**
     Prepare CKRecords to describe the Web Links and place them into a cache.
     
     - Parameter cache: The cache of any existing CKRecords prepared prior to
     calling this function.
     
     - Returns: A dictionary of CKRecords generated from within this function.
     This only includes new CKRecords and is not currently merged with those passed
     in as a parameter.
     */
    func prepareWebLinks(withCache cache: [String:CKRecord]) -> [String:CKRecord] {
        let records = WebLink.prepareCKRecords(inContext: viewContext, withCache: cache)
        display(records)
        return records
    }
    
    // MARK: - Utilities
    
    /**
     Prints a log of the specified dictionary. The records will be displayed
     between a START and END banner and the count of the number of records will be
     shown.
     
     - Parameter records: A dictionary of records to be displayed.
     */
    fileprivate func display(_ records: [String : CKRecord]) {
        print("========================== START ==============================")
        for record in records {
            print("record: \(record)")
        }
        print("Record count: \(records.count)")
        print("============================ END ==============================")
    }
    
}
