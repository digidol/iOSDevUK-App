//
//  SpeakersTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 04/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import CoreData

class SpeakersTableViewCell: UITableViewCell, IDUDataManager {
    
    //var dataManager: DataManager?
    
    var speakers: [IDUSpeaker]?
    
    //var collectionDataManager: SpeakerImageTextCollectionViewCellDataManager?
    
    var selectedItem: ((_ item: Any) -> Void)?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension SpeakersTableViewCell: UICollectionViewDelegate {
    
    /**
     The cell has been selected, so call the selected item in order to share this
     selected value with the enclosing view controller. The view controller then handles
     the transition to the relevent next screen.
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let speaker = speakers?[indexPath.row],
            //let speaker = collectionDataManager?.object(at: indexPath) as? Speaker,
           let selectedItem = selectedItem {  //fetchedResultsController?.object(at: indexPath),
            //{
            selectedItem(speaker)
        }
    }
}

extension SpeakersTableViewCell: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return collectionDataManager?.numberOfItemsInSection(section) ?? 0
        return speakers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "speakerCell", for: indexPath) as! ImageTextCollectionViewCell
        
        if let speaker = speakers?[indexPath.row] {
            cell.configure(name: speaker.name, imageName: speaker.recordName, twitterId: speaker.twitterId, withBorderRadius: nil)
        }
        //configureCell(cell, atIndexPath: indexPath, withBorderRadius: nil)
        //collectionDataManager?.configureCell(cell, atIndexPath: indexPath, withBorderRadius: nil)
        return cell
    }
    
    /*
    func configureCell(_ cell: ImageTextCollectionViewCell, atIndexPath indexPath: IndexPath, withBorderRadius radius: CGFloat?) {
        if let speaker = speakers?[indexPath.row] {
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
    }*/
    
    
}
