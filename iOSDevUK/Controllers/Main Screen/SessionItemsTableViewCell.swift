//
//  SessionItemsTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 04/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class SessionItemsTableViewCell: UITableViewCell {
    
    var sessionItems: [IDUSessionItem]?
    
    var selectedItem: ((Any) -> Void)?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(sessionItems items: [IDUSessionItem]) {
        sessionItems = items.filter({ $0.listOnFrontScreen }).sorted(by: {$0.title < $1.title})
    }
}

extension SessionItemsTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let sessionItem = sessionItems?[indexPath.row],
            let selectedItem = selectedItem {
            
            selectedItem(sessionItem)
        }
    }
}

extension SessionItemsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessionItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sessionItemCellAlternative", for: indexPath) as! SessionItemCollectionViewCell
        
        if let sessionItem = sessionItems?[indexPath.row] {
            cell.title.text = sessionItem.title
            cell.speakerOneImage.image = UIImage(named: "DefaultImage")
            
            if sessionItem.speakers.count == 2 {
                cell.speakerTwoImage.image = UIImage(named: "DefaultImage")
                cell.speakerTwoImage.isHidden = false
            }
            else {
                cell.speakerTwoImage.isHidden = true
            }
            
            cell.speaker.text = sessionItem.speakerNames()
                
            if sessionItem.speakers.count > 0 {
                cell.speakerOneImage.displayImage(named: sessionItem.speakers[0].recordName)
                if sessionItem.speakers.count == 2 {
                    cell.speakerTwoImage.displayImage(named: sessionItem.speakers[1].recordName)
                }
            }
            
            var room = "To be confirmed"
            if let location = sessionItem.location {
                room = location.shortName
            }
            
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "Europe/London")
            formatter.dateFormat = "EEE HH:mm"
            cell.room.text = room + " (\(formatter.string(from: sessionItem.session.startTime)))"
            
            cell.addBorderWithCorner(withRadius: 4.0)
        }
        else {
            cell.title.text = "Unknown"
            cell.speakerOneImage.backgroundColor = .white
            cell.speakerTwoImage.backgroundColor = .white
        }
        
        return cell
    }
    
    
}
