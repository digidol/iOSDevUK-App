//
//  NowAndNextTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 05/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class NowAndNextTableViewCell: UITableViewCell {

    var nowSession: IDUSession?
    
    var nextSession: IDUSession?
    
    var selectedItem: ((Any) -> Void)?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension NowAndNextTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        var selectedSession: IDUSession?
        
        switch indexPath.section {
        case 0:
            selectedSession = nowSession
            break
        case 1:
            selectedSession = nextSession
            break
        default:
            selectedSession = nil
            break
        }
        
        if let sessionItem = selectedSession?.sessionItems[indexPath.row],
           let selectedItem = selectedItem {
            
            selectedItem(sessionItem)
        }
    }
}

extension NowAndNextTableViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return nowSession?.sessionItems.count ?? 1
        }
        
        if section == 1 {
            return nextSession?.sessionItems.count ?? 1
        }
        
        return 0
    }
    
    func configureNowCell(_ cell: NowAndNextCollectionViewCell, forIndexPath indexPath: IndexPath) {
        
        cell.nowNextLabel.text = "Now"
        
        let count = nowSession?.sessionItems.count ?? 0
        
        if count == 0 {
            cell.title.text = "No session on at the moment."
            cell.room.text = ""
        }
        else {
            let sessionItem = nowSession?.sessionItems[indexPath.row]
            cell.title.text = sessionItem?.title
            cell.room.text = sessionItem?.location?.name
        }
        cell.backgroundColor = UIColor.iOSDevUKDarkBlue()
        
    }
    
    func configureNextCell(_ cell: NowAndNextCollectionViewCell, forIndexPath indexPath: IndexPath) {
        
        cell.nowNextLabel.text = "Next"
        
        let count = nextSession?.sessionItems.count ?? 0
        
        if count == 0 {
            cell.title.text = "No more sessions follow."
            cell.room.text = ""
        }
        else {
            let sessionItem = nextSession?.sessionItems[indexPath.row]
            cell.title.text = sessionItem?.title
            cell.room.text = sessionItem?.location?.name
        }
        
        cell.backgroundColor = UIColor.darkGray
        
        cell.addBorderWithCorner(withRadius: 4.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nowAndNextCell", for: indexPath) as! NowAndNextCollectionViewCell
        
        if indexPath.section == 0 {
            configureNowCell(cell, forIndexPath: indexPath)
        }
        else if indexPath.section == 1 {
            configureNextCell(cell, forIndexPath: indexPath)
        }
        
        return cell
    }
    
    
}
