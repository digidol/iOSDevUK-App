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
    
    var sessionItem: SessionItem? {
        didSet {
            if let sessionItem = sessionItem {
                title.text = sessionItem.title!
                
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(identifier: "Europe/London")
                formatter.dateFormat = "EEE"
                
                if let startTime = sessionItem.session?.startTime {
                    formatter.dateFormat = "EEE"
                    day.text = formatter.string(from: startTime as Date)
                    
                    formatter.dateFormat = "HH:mm"
                    timeStart.text = formatter.string(from: startTime as Date)
                }
                
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
