//
//  Location+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 15/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var active: Bool
    @NSManaged public var frontListPosition: Int32
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var recordName: String?
    @NSManaged public var shortName: String?
    @NSManaged public var showImage: Bool
    @NSManaged public var locationType: LocationType?
    @NSManaged public var sessions: NSSet?
    @NSManaged public var webLink: WebLink?

}

// MARK: Generated accessors for sessions
extension Location {

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: SessionItem)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: SessionItem)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

}
