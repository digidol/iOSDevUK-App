//
//  Speaker+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 01/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData


extension Speaker {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Speaker> {
        return NSFetchRequest<Speaker>(entityName: "Speaker")
    }

    @NSManaged public var biography: String?
    @NSManaged public var linkedIn: String?
    @NSManaged public var name: String?
    @NSManaged public var recordName: String?
    @NSManaged public var twitterId: String?
    @NSManaged public var sessionItems: NSSet?
    @NSManaged public var webLinks: NSSet?

}

// MARK: Generated accessors for sessionItems
extension Speaker {

    @objc(addSessionItemsObject:)
    @NSManaged public func addToSessionItems(_ value: SessionItem)

    @objc(removeSessionItemsObject:)
    @NSManaged public func removeFromSessionItems(_ value: SessionItem)

    @objc(addSessionItems:)
    @NSManaged public func addToSessionItems(_ values: NSSet)

    @objc(removeSessionItems:)
    @NSManaged public func removeFromSessionItems(_ values: NSSet)

}

// MARK: Generated accessors for webLinks
extension Speaker {

    @objc(addWebLinksObject:)
    @NSManaged public func addToWebLinks(_ value: WebLink)

    @objc(removeWebLinksObject:)
    @NSManaged public func removeFromWebLinks(_ value: WebLink)

    @objc(addWebLinks:)
    @NSManaged public func addToWebLinks(_ values: NSSet)

    @objc(removeWebLinks:)
    @NSManaged public func removeFromWebLinks(_ values: NSSet)

}
