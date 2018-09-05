//
//  UserSettings+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 13/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData


extension UserSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserSettings> {
        return NSFetchRequest<UserSettings>(entityName: "UserSettings")
    }

    @NSManaged public var showMySchedulePrompt: Bool
    @NSManaged public var sessionItems: NSSet?

}

// MARK: Generated accessors for sessionItems
extension UserSettings {

    @objc(addSessionItemsObject:)
    @NSManaged public func addToSessionItems(_ value: SessionItem)

    @objc(removeSessionItemsObject:)
    @NSManaged public func removeFromSessionItems(_ value: SessionItem)

    @objc(addSessionItems:)
    @NSManaged public func addToSessionItems(_ values: NSSet)

    @objc(removeSessionItems:)
    @NSManaged public func removeFromSessionItems(_ values: NSSet)

}
