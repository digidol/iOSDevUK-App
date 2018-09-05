//
//  InformationTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 04/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class InformationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension InformationTableViewCell: UICollectionViewDelegate {
    
}

extension InformationTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "informationCell", for: indexPath) as! InformationCollectionViewCell
            return cell
        }
        else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inclusivityCell", for: indexPath) as! InformationCollectionViewCell
            return cell
        }
        else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "attendeeCell", for: indexPath) as! InformationCollectionViewCell
            return cell
        }
        else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sponsorsCell", for: indexPath) as! InformationCollectionViewCell
            cell.label.text = "Sponsors"
            return cell
        }
        else if indexPath.row == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "aboutConferenceCell", for: indexPath) as! InformationCollectionViewCell
            return cell
        }
        else if indexPath.row == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "aboutAppCell", for: indexPath) as! InformationCollectionViewCell
            return cell
        }
        else {
            fatalError()
        }
        
    }
    
    
}
