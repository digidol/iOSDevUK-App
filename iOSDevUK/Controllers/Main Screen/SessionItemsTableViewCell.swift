//
//  SessionItemsTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 04/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import CoreData

class SessionItemsTableViewCell: UITableViewCell { // , IDUDataManager {
    
    /*var dataManager: DataManager? {
        didSet {
            initialiseFetchedResultsController()
        }
    }*/
    
    var sessionItems: [IDUSessionItem]?
    
    var selectedItem: ((Any) -> Void)?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //var fetchedResultsController: NSFetchedResultsController<SessionItem>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(sessionItems items: [IDUSessionItem]) {
        sessionItems = items.filter { $0.listOnFrontScreen }
    }
    
    /*
    func initialiseFetchedResultsController() {
        if let dataManager = dataManager {
            
            let fetchRequest: NSFetchRequest<SessionItem> = SessionItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "listOnFrontScreen = true")
            
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
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
    }
 */

}

extension SessionItemsTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("collection view item selected")
        if let sessionItem = sessionItems?[indexPath.row], //fetchedResultsController?.object(at: indexPath),
            let selectedItem = selectedItem {
            //print("I will ask it to prepare for the segue")
            selectedItem(sessionItem)
        }
    }
}

extension SessionItemsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*guard let section = fetchedResultsController?.sections?[section] else {
            return 0
        }
        
        return section.numberOfObjects*/
        return sessionItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sessionItemCellAlternative", for: indexPath) as! SessionItemCollectionViewCell
        
        if let sessionItem = sessionItems?[indexPath.row] {
            //fetchedResultsController?.object(at: indexPath) {
            cell.title.text = sessionItem.title
            cell.speakerOneImage.image = UIImage(named: "DefaultImage")
            
            //if let speakers = sessionItem.speakers {
                
                if sessionItem.speakers.count == 2 {
                    cell.speakerTwoImage.image = UIImage(named: "DefaultImage")
                    cell.speakerTwoImage.isHidden = false
                }
                else {
                    cell.speakerTwoImage.isHidden = true
                }
                
                cell.speaker.text = sessionItem.speakerNames()
                
                //if let speakerArray = sessionItem.sortedSpeakerArray {
                if sessionItem.speakers.count > 0 {
                    cell.speakerOneImage.displayImage(named: sessionItem.speakers[0].name)
                    if sessionItem.speakers.count == 2 {
                        cell.speakerTwoImage.displayImage(named: sessionItem.speakers[1].name)
                    }
                }
                //}
            //}
            
            var room = "To be confirmed"
            if let location = sessionItem.location {
                room = location.shortName
            }
            
            //if let startTime = sessionItem.session.startTime as Date? {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "Europe/London")
            formatter.dateFormat = "EEE HH:mm"
            cell.room.text = room + " (\(formatter.string(from: sessionItem.session.startTime)))"
            //}
            
            cell.addBorderWithCorner(withRadius: 4.0)
        }
        else {
            cell.title.text = "Unknown"
            cell.speakerOneImage.backgroundColor = .white
            cell.speakerTwoImage.backgroundColor = .white
        }
        
        return cell
    }
    
    
}
