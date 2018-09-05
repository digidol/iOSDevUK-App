//
//  LocationType+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 15/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData


extension LocationType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationType> {
        return NSFetchRequest<LocationType>(entityName: "LocationType")
    }

    @NSManaged public var name: String?
    @NSManaged public var order: Int32
    @NSManaged public var recordName: String?
    @NSManaged public var note: String?
    @NSManaged public var locations: NSSet?

}

// MARK: Generated accessors for locations
extension LocationType {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: Location)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: Location)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}
