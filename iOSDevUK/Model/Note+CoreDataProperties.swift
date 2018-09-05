//
//  Note+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 01/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var lastEdited: NSDate?
    @NSManaged public var sessionItem: SessionItem?

}
