//
//  SessionBlock+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData


extension SessionBlock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionBlock> {
        return NSFetchRequest<SessionBlock>(entityName: "SessionBlock")
    }

    @NSManaged public var name: String?
    @NSManaged public var recordName: String?
    @NSManaged public var footer: String?
    @NSManaged public var header: String?
    @NSManaged public var sessions: NSSet?

}

// MARK: Generated accessors for sessions
extension SessionBlock {

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: Session)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: Session)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

}
