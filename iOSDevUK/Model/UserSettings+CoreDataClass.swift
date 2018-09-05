//
//  UserSettings+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 13/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData

@objc(UserSettings)
public class UserSettings: NSManagedObject {

    class func createInstance(inContext context: NSManagedObjectContext) -> UserSettings {
        return NSEntityDescription.insertNewObject(forEntityName: "UserSettings", into: context) as! UserSettings
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- UserSettings ---")
        let request = NSFetchRequest<UserSettings>(entityName: "UserSettings") as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["name"])
    }
    
    class func retrieveInstance(inContext context: NSManagedObjectContext) -> UserSettings? {
        let request = NSFetchRequest<UserSettings>(entityName: "UserSettings") as! NSFetchRequest<NSFetchRequestResult>
        if let items = try? context.fetch(request) {
            return items.first as? UserSettings
        }
        else {
            print("unable to load UserSettings object")
            return nil
        }
    }
}
