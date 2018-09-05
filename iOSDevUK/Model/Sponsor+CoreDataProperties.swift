//
//  Sponsor+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 14/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData


extension Sponsor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sponsor> {
        return NSFetchRequest<Sponsor>(entityName: "Sponsor")
    }

    @NSManaged public var active: Bool
    @NSManaged public var image: NSData?
    @NSManaged public var name: String?
    @NSManaged public var recordName: String?
    @NSManaged public var sponsorCategory: String?
    @NSManaged public var sponsorOrder: Int16
    @NSManaged public var tagline: String?
    @NSManaged public var url: URL?
    @NSManaged public var cellType: String?
    @NSManaged public var note: String?

}
