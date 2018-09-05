//
//  SpeakerImageTextCollectionViewCellDataManager.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 09/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SpeakerImageTextCollectionViewCellDataManager: ImageTextCollectionViewDataManager {
    
    var dataManager: DataManager?
    
    var fetchedResultsController: NSFetchedResultsController<Speaker>?
    
    init(dataManager: DataManager) {
        
        self.dataManager = dataManager
        let fetchRequest: NSFetchRequest<Speaker> = Speaker.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
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
        if let speaker = fetchedResultsController?.object(at: indexPath) {
            cell.name.text = speaker.name
            cell.image.displayImage(named: speaker.name)
            if radius != nil {
                cell.image.addBorderWithCorner(radius: radius!)
            }
            else {
                cell.image.addBorderWithCorner()
            }
            
            if let twitterId = speaker.twitterId {
                cell.twitterId?.text = "@\(twitterId)"
            }
            else {
                cell.twitterId?.text = ""
            }
        }
        else {
            cell.name.text = "Unknown"
            cell.image.displayImage(named: "DefaultName")
            cell.twitterId?.text = ""
        }
        
    }
    
    func object(at indexPath: IndexPath) -> Any? {
        return fetchedResultsController?.object(at: indexPath)
    }
    
}
