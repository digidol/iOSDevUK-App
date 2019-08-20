//
//  SpeakersCollectionViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 06/08/2018.
//  Copyright © 2018-2019 Aberystwyth University. All rights reserved.
//

import UIKit

class SpeakersCollectionViewController: UICollectionViewController {

    var speakers: [IDUSpeaker]?
    
    var appSettings: AppSettings?
    
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
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return speakers?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "speakersCollectionCell2", for: indexPath) as! ImageTextCollectionViewCell
        
        if let speaker = speakers?[indexPath.row] {
            cell.configure(name: speaker.name, imageName: speaker.recordName, twitterId: speaker.twitterId, withBorderRadius: 4.0)
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let speakerController = segue.destination as? SpeakerTableViewController {
            
            if let indexPaths = collectionView?.indexPathsForSelectedItems,
               let indexPath = indexPaths.first,
               let speaker = speakers?[indexPath.row] {
               
                speakerController.appSettings = appSettings
                speakerController.speaker = speaker
            }
            else {
                fatalError()
            }
        }
    }

}
