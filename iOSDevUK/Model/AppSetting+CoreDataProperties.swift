//
//  Setting+CoreDataProperties.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 30/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData


extension AppSetting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppSetting> {
        return NSFetchRequest<AppSetting>(entityName: "AppSetting")
    }

    @NSManaged public var dateValue: NSDate?
    @NSManaged public var intValue: Int32
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var stringValue: String?

}
