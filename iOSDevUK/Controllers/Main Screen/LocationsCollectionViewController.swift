//
//  LocationsCollectionViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 06/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import CoreData

class LocationsCollectionViewController: UICollectionViewController {
    
    var collectionDataManager: ImageTextCollectionViewDataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionDataManager?.numberOfSections() ?? 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDataManager?.numberOfItemsInSection(section) ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCollectionCell", for: indexPath) as! ImageTextCollectionViewCell
        collectionDataManager?.configureCell(cell, atIndexPath: indexPath, withBorderRadius: nil)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let locationController = segue.destination as? MapLocationViewController,
           let indexPaths = collectionView?.indexPathsForSelectedItems,
           let indexPath = indexPaths.first,
           let location = collectionDataManager?.object(at: indexPath) as? Location {
            locationController.location = location
        }
        else {
            fatalError()
        }
    }
    
}
