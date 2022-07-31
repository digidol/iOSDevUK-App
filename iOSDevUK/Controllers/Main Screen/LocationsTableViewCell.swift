//
//  LocationsTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 09/08/2018.
//  Copyright © 2018-2022 Aberystwyth University. All rights reserved.
//

import UIKit

class LocationsTableViewCell: UITableViewCell, IDUDataManager {

    var selectedItem: ((_ item: Any) -> Void)?
    
    private var locations: [IDULocation]?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(locations: [IDULocation]?) {
        self.locations = locations?.filter({$0.frontListPosition > 0})
                                   .sorted(by: {$0.frontListPosition > $1.frontListPosition})
    }
}

extension LocationsTableViewCell: UICollectionViewDelegate {
    
    /**
     The cell has been selected, so call the selected item in order to share this
     selected value with the enclosing view controller. The view controller then handles
     the transition to the relevent next screen.
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let location = locations?[indexPath.row], let selectedItem = selectedItem {
            selectedItem(location)
        }
    }
}

extension LocationsTableViewCell: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell", for: indexPath) as! ImageTextCollectionViewCell
        
        if let location = locations?[indexPath.row] {
            cell.name.text = location.name
            cell.image.displayImage(named: location.recordName, inCategory: .locations, withDefault: "LocationPin")
            cell.image.addBorderWithCorner()
        }
        else {
            cell.name.text = "Unknown"
            cell.image.displayImage(named: "LocationPin", inCategory: .locations)
        }
        
        cell.twitterId?.text = nil
        
        return cell
    }
    
}
