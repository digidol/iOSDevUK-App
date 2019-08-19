//
//  DataManager.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 28/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    var alternativeTime: Date?
    
    func currentTime() -> Date {
        return alternativeTime ?? Date()
    }
    
    /**
     Clears all of the data from the app from all entities, including ones with user data in.
     */
    func clearAllData(inContext context: NSManagedObjectContext) {
        let initialiser = DataInitialiser(context: persistentContainer.viewContext)
        initialiser.clearAllData()
    }
    
    func initialiseData(onCompletion callback: @escaping (Bool, String?) -> Void) {
        
        
        
        
            
            let client = AppDataClient(dataVersion: nil)
                    
            client.downloadMetadata{ (data) in
                if data != nil {
                    client.downloadUpdate { (data) in
                        print("Download returned \(String(describing: data))")
                        
                        callback(true, nil)
                    }
                } else {
                    print("Unable to retrieve the metadata")
                    callback(false, "Unable to access metadata.")
                }
            }
        }
    
    /**
     Initialise the data during the first installation of the app.
     */
    func initialiseData(inContext context: NSManagedObjectContext) {
        let initialiser = DataInitialiser(context: context)
        initialiser.initialiseData()
        
        do {
            try context.save()
        } catch {
            print("error initalising the data")
        }
    }
    
    /**
     Performs an updated for the specified identifier.
     
     - Parameters:
         - withIdentifier: A number that represents the version of the data model.
     */
    func updateData(withIdentifier identifier: Int, inContext context: NSManagedObjectContext) {
        print("Updating for \(identifier)")
        let initialiser = DataInitialiser(context: context)
        initialiser.updateDatastore(forIdentifier: identifier)
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("error updating the data: \(nserror.localizedDescription)")
        }
    }
    
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "iOSDevUK")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func save() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
