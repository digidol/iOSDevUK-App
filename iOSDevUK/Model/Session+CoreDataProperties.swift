//
//  Session+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 31/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var startTime: NSDate?
    @NSManaged public var endTime: NSDate?
    @NSManaged public var recordName: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var sessionItems: NSSet?
    @NSManaged public var section: Section?

}

// MARK: Generated accessors for sessionItems
extension Session {

    @objc(addSessionItemsObject:)
    @NSManaged public func addToSessionItems(_ value: SessionItem)

    @objc(removeSessionItemsObject:)
    @NSManaged public func removeFromSessionItems(_ value: SessionItem)

    @objc(addSessionItems:)
    @NSManaged public func addToSessionItems(_ values: NSSet)

    @objc(removeSessionItems:)
    @NSManaged public func removeFromSessionItems(_ values: NSSet)

}
