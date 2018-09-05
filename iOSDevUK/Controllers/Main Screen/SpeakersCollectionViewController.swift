//
//  SpeakersCollectionViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 06/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import CoreData

class SpeakersCollectionViewController: UICollectionViewController {

    var collectionDataManager: ImageTextCollectionViewDataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return collectionDataManager?.numberOfSections() ?? 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDataManager?.numberOfItemsInSection(section) ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "speakersCollectionCell2", for: indexPath) as! ImageTextCollectionViewCell
        collectionDataManager?.configureCell(cell, atIndexPath: indexPath, withBorderRadius: 4.0)
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let speakerController = segue.destination as? SpeakerTableViewController {
            speakerController.dataManager = collectionDataManager?.dataManager
            
            if let indexPaths = collectionView?.indexPathsForSelectedItems,
               let indexPath = indexPaths.first,
               let speaker = collectionDataManager?.object(at: indexPath) as? Speaker {
                speakerController.speaker = speaker
            }
            else {
                fatalError()
            }
        }
    }

}
