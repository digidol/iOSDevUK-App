//
//  LocationsTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 09/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class LocationsTableViewCell: UITableViewCell, IDUDataManager {

    var dataManager: DataManager?
    
    var collectionDataManager: LocationImageTextCollectionViewCellDataManager?
    
    var selectedItem: ((_ item: Any) -> Void)?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension LocationsTableViewCell: UICollectionViewDelegate {
    
    /**
     The cell has been selected, so call the selected item in order to share this
     selected value with the enclosing view controller. The view controller then handles
     the transition to the relevent next screen.
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let speaker = collectionDataManager?.object(at: indexPath) as? Location,
            let selectedItem = selectedItem {
            selectedItem(speaker)
        }
    }
}

extension LocationsTableViewCell: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDataManager?.numberOfItemsInSection(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell", for: indexPath) as! ImageTextCollectionViewCell
        collectionDataManager?.configureCell(cell, atIndexPath: indexPath, withBorderRadius: 4.0)
        return cell
    }
    
}
