//
//  SpeakersCollectionViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 06/08/2018.
//  Copyright © 2018-2019 Aberystwyth University. All rights reserved.
//

import UIKit

class SpeakersCollectionViewController: UICollectionViewController {
    
    /** List of speakers to display when search is not used. */
    var speakers: [IDUSpeaker]?
    
    /** Contains any matches to be displayed when searching for content. */
    var filteredSpeakers: [IDUSpeaker]?
    
    var appSettings: AppSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        searchController.searchBar.scopeButtonTitles = ["All", "Name", "Biography"]
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Who do you want to search for?"
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
        if let _ = self.collectionView?.hasAmbiguousLayout {
            print("ambiguous layout in SpeakersCollectionViewController")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.insetsLayoutMarginsFromSafeArea = true
        collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
   // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count =  filteredSpeakers?.count ?? (speakers?.count ?? 0)
        return count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "speakersCollectionCell2", for: indexPath) as! ImageTextCollectionViewCell
        
        if let speaker = filteredSpeakers?[indexPath.row] ?? speakers?[indexPath.row] {
            cell.configure(name: speaker.name, imageName: speaker.recordName, twitterId: speaker.twitterId, withBorderRadius: 4.0)
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let speakerController = segue.destination as? SpeakerTableViewController {
            
            if let indexPaths = collectionView?.indexPathsForSelectedItems,
               let indexPath = indexPaths.first,
               let speaker = filteredSpeakers?[indexPath.row] ?? speakers?[indexPath.row] {
               
                speakerController.appSettings = appSettings
                speakerController.speaker = speaker
            }
            else {
                fatalError()
            }
        }
    }
    
    private let cellSize = CGSize(width: 140.0, height: 140.0)
    private let sectionInsets = UIEdgeInsets(top: 15, left: 30.0, bottom: 15.0, right: 30.0)
}

// properties above and the following code based on example at https://www.raywenderlich.com/5758454-uiscrollview-tutorial-getting-started
extension SpeakersCollectionViewController : UICollectionViewDelegateFlowLayout {
    
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
}

/**
 Manages the search functionality on the screen.
 */
extension SpeakersCollectionViewController: UISearchBarDelegate {
    
    func search(searchBar: UISearchBar, text: String, selectedScope: Int) {
        if text.isEmpty {
            filteredSpeakers = nil
        }
        else {
            let searchName = selectedScope == 0 || selectedScope == 1
            
            let searchBiography = selectedScope == 0 || selectedScope == 2
            
            filteredSpeakers = speakers?.filter({ speaker in
                if searchName && speaker.name.lowercased().contains(text.lowercased()) {
                    return true
                }
                
                if searchBiography && speaker.biography.lowercased().contains(text.lowercased()) {
                    return true
                }
                
                return false
            })
        }
        
        collectionView?.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        guard let text = searchBar.text else {
            filteredSpeakers = nil
            collectionView?.reloadData()
            return
        }
        
        search(searchBar: searchBar, text: text, selectedScope: selectedScope)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchBar: searchBar, text: searchText, selectedScope: searchBar.selectedScopeButtonIndex)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredSpeakers = nil
        
        collectionView?.reloadData()
    }
}
