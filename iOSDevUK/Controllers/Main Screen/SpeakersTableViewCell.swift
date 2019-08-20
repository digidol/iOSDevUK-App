//
//  SpeakersTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 04/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class SpeakersTableViewCell: UITableViewCell, IDUDataManager {
    
    var speakers: [IDUSpeaker]?
    
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
        if let speaker = speakers?[indexPath.row], let selectedItem = selectedItem {
            selectedItem(speaker)
        }
    }
}

extension SpeakersTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return speakers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "speakerCell", for: indexPath) as! ImageTextCollectionViewCell
        
        if let speaker = speakers?[indexPath.row] {
            cell.configure(name: speaker.name, imageName: speaker.recordName, twitterId: speaker.twitterId, withBorderRadius: nil)
        }
        
        return cell
    }
}
