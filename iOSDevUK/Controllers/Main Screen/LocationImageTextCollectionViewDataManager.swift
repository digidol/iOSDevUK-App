//
//  LocationImageTextCollectionViewDataManager.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 09/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class LocationImageTextCollectionViewCellDataManager: ImageTextCollectionViewDataManager {
    
    var dataManager: DataManager?
    
    var fetchedResultsController: NSFetchedResultsController<Location>?
    
    init(dataManager: DataManager, withSortKey sortKey: String, withPredicate predicate: NSPredicate?) {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: dataManager.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try fetchedResultsController?.performFetch()
        }
        catch {
            print("Unable to fetch list of speaker.")
        }
        
    }
    
    func numberOfSections() -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        guard let section = fetchedResultsController?.sections?[section] else {
            return 0
        }
        
        return section.numberOfObjects
    }
    
    func configureCell(_ cell: ImageTextCollectionViewCell, atIndexPath indexPath: IndexPath, withBorderRadius radius: CGFloat?) {
        if let location = fetchedResultsController?.object(at: indexPath) {
            cell.name.text = location.name
            cell.image.displayImage(named: location.recordName, withDefault: "LocationPin")
            cell.image.addBorderWithCorner()
        }
        else {
            cell.name.text = "Unknown"
            cell.image.displayImage(named: "LocationPin")
        }
        
        cell.twitterId?.text = nil
        
    }
    
    func object(at indexPath: IndexPath) -> Any? {
        return fetchedResultsController?.object(at: indexPath)
    }
    
}
