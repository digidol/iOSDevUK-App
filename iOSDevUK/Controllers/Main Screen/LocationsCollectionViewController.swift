//
//  LocationsCollectionViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 06/08/2018.
//  Copyright © 2018-2022 Aberystwyth University. All rights reserved.
//

import UIKit

class LocationsCollectionViewController: UICollectionViewController {
    
    /**
     Used to hold a list of locations, extracted from the locationTypes when they are set
     on the object.
     */
    private var locations: [IDULocation]?
    
    /**
     A list of locations that match the search term. If this is not nil, then a search is being performed.
     If this is nil, then there is no active search and the data is taken from the locationTypes instead.
     */
    var filteredLocations: [IDULocation]?
    
    /**
     A set of location types, with their associated locations.
     */
    var locationTypes: [IDULocationType]? {
        didSet {
            setupLocations()
        }
    }
    
    /**
     Extracts the list of locations from each of the location types and make them into an array that
     can be used during search.
     */
    private func setupLocations() {
        
        var allLocations = [IDULocation]()
        
        locationTypes?.forEach({ type in
            allLocations.append(contentsOf: type.locations)
        })
        
        locations = allLocations
    }
    
    /**
     Initialises the view, adding a Search Controller to the screen and configuring it for use.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = ["All", "Name", "Note"]
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Where do you want to search for?"
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
        if let _ = self.collectionView?.hasAmbiguousLayout {
            print("ambiguous layout in LocationsCollectionViewController")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if filteredLocations != nil {
            return 1
        }
        
        return locationTypes?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        
        guard let typedView = headerView as? HeaderCollectionReusableView else {
            return headerView
        }
        
        if filteredLocations != nil {
            typedView.titleText?.text = "Search results"
        }
        else {
            typedView.titleText?.text = locationTypes?[indexPath.section].name ?? "Items"
        }
        return typedView
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filteredLocations?.count ?? locationTypes?[section].locations.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCollectionCell", for: indexPath) as! ImageTextCollectionViewCell
        
        if let location = filteredLocations?[indexPath.row] ?? locationTypes?[indexPath.section].locations[indexPath.row] {
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
    
    // MARK: UICollectionViewDelegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let locationController = segue.destination as? MapLocationViewController,
           let indexPaths = collectionView?.indexPathsForSelectedItems,
           let indexPath = indexPaths.first,
           let location = filteredLocations?[indexPath.row] ?? locationTypes?[indexPath.section].locations[indexPath.row] {
            
            locationController.location = location
        }
        else {
            fatalError()
        }
    }
    
    private let cellSize = CGSize(width: 110.0, height: 140.0)
    private let sectionInsets = UIEdgeInsets(top: 15, left: 20.0, bottom: 15.0, right: 20.0)
}

// properties above and the following code based on example at https://www.raywenderlich.com/5758454-uiscrollview-tutorial-getting-started
extension LocationsCollectionViewController : UICollectionViewDelegateFlowLayout {
    
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
  }
}

extension LocationsCollectionViewController: UISearchBarDelegate {
    func search(searchBar: UISearchBar, text: String, selectedScope: Int) {
        if text.isEmpty {
            filteredLocations = nil
        }
        else {
            let searchName = selectedScope == 0 || selectedScope == 1
            
            let searchNote = selectedScope == 0 || selectedScope == 2
            
            filteredLocations = locations?.filter({ location in
                if searchName && location.name.lowercased().contains(text.lowercased()) {
                    return true
                }
                
                if let note = location.note {
                    if searchNote && note.lowercased().contains(text.lowercased()) {
                        return true
                    }
                }
                
                return false
            })
        }
        
        collectionView?.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        guard let text = searchBar.text else {
            filteredLocations = nil
            collectionView?.reloadData()
            return
        }
        
        search(searchBar: searchBar, text: text, selectedScope: selectedScope)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchBar: searchBar, text: searchText, selectedScope: searchBar.selectedScopeButtonIndex)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredLocations = nil
        collectionView?.reloadData()
    }
}
