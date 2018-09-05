//
//  SessionItem+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 13/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData


extension SessionItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SessionItem> {
        return NSFetchRequest<SessionItem>(entityName: "SessionItem")
    }

    @NSManaged public var active: Bool
    @NSManaged public var content: String?
    @NSManaged public var listOnFrontScreen: Bool
    @NSManaged public var order: Int32
    @NSManaged public var recordName: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var location: Location?
    @NSManaged public var note: Note?
    @NSManaged public var session: Session?
    @NSManaged public var speakers: NSSet?
    @NSManaged public var userSelected: UserSettings?

}

// MARK: Generated accessors for speakers
extension SessionItem {

    @objc(addSpeakersObject:)
    @NSManaged public func addToSpeakers(_ value: Speaker)

    @objc(removeSpeakersObject:)
    @NSManaged public func removeFromSpeakers(_ value: Speaker)

    @objc(addSpeakers:)
    @NSManaged public func addToSpeakers(_ values: NSSet)

    @objc(removeSpeakers:)
    @NSManaged public func removeFromSpeakers(_ values: NSSet)

}
