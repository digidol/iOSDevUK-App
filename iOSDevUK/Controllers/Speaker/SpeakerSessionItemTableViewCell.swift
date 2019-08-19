//
//  SpeakerSessionItemTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 05/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class SpeakerSessionItemTableViewCell: UITableViewCell {

    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var timeStart: UILabel!
    @IBOutlet weak var title: UILabel!
    
    var sessionItem: IDUSessionItem? {
        didSet {
            if let sessionItem = sessionItem {
                title.text = sessionItem.title
                
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(identifier: "Europe/London")
                
                let startTime = sessionItem.session.startTime
                
                formatter.dateFormat = "EEE"
                day.text = formatter.string(from: startTime)
                
                formatter.dateFormat = "HH:mm"
                timeStart.text = formatter.string(from: startTime)
                
                
                if let sessionLocation = sessionItem.location {
                    location.text = sessionLocation.name
                }
                else {
                    location.text = "TBC"
                }
            }
        }
    }
}
