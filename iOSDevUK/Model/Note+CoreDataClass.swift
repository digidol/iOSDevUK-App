//
//  Note+CoreDataClass.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 01/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {

    class func createInstance(inContext context: NSManagedObjectContext) -> Note {
        return NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
    }
    
    class func listInstances(inContext context: NSManagedObjectContext) {
        print("--- Note ---")
        let request = NSFetchRequest<Note>(entityName: "Note") as! NSFetchRequest<NSFetchRequestResult>
        listInstances(inContext: context, withRequest: request, withKeys: ["lastEdited"])
    }
    
    // Instance functions
    
    public override var description: String {
        return "Note [lastEdited '\(String(describing: lastEdited))', " +
            "content: '\(content ?? "<nil>")', " +
        "]"
    }
}
