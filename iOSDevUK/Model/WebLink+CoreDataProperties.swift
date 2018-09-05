//
//  WebLink+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 09/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData

extension WebLink {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WebLink> {
        return NSFetchRequest<WebLink>(entityName: "WebLink")
    }

    @NSManaged public var active: Bool
    @NSManaged public var name: String?
    @NSManaged public var recordName: String?
    @NSManaged public var url: URL?
    @NSManaged public var speakers: Speaker?
    @NSManaged public var locations: NSSet?

}

// MARK: Generated accessors for locations
extension WebLink {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: Location)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: Location)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}
