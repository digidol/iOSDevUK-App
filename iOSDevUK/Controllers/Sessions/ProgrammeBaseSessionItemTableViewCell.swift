//
//  ProgrammeBaseSessionItemTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 10/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class ProgrammeBaseSessionItemTableViewCell: UITableViewCell {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var timeStart: UILabel!
    @IBOutlet weak var timeEnd: UILabel!
    
    var notifySessionItemSelected: ((Int, CGPoint, UITableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(withSession session: IDUSession) {
        configure(startTime: session.startTime, endTime: session.endTime)
    }
    
    func configure(startTime: Date?, endTime: Date?) {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/London")
        formatter.dateFormat = "HH:mm"
            
        if let start = startTime {
            timeStart.text = String(formatter.string(from: start).prefix(5).trimmingCharacters(in: .whitespaces))
        }
        else {
            timeStart.text = "--:--"
        }
        
        if let end = endTime {
            timeEnd.text = String(formatter.string(from: end).prefix(5).trimmingCharacters(in: .whitespaces))
        }
        else {
            timeEnd.text = "--:--"
        }
    }
    
    /*func configure(withSession session: IDUSession, whereUserSelected isUserSelected: Bool) {
        configure(withSession: session)
    }*/
    
    func configure(sessionItems: [IDUSessionItem]) {
        
    }
    
    
    func configure(startTime: Date?, endTime: Date?, sessionItems: [IDUSessionItem]) {
        configure(startTime: startTime, endTime: endTime)
        configure(sessionItems: sessionItems)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let notify = notifySessionItemSelected,
            let touch = touches.first {
            notify(0, touch.location(in: self), self)
        }
    }

}
