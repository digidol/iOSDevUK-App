//
//  ProgrammeTripleSessionItemTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 11/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class ProgrammeTripleSessionItemTableViewCell: ProgrammeDoubleSessionItemTableViewCell {
    
    @IBOutlet weak var separatorTwoView: UIView!
    
    @IBOutlet weak var sessionThreeTitle: UILabel!
    @IBOutlet weak var sessionThreeLocation: UILabel!
    @IBOutlet weak var sessionThreeNames: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
    override func configure(withSession session: IDUSession) {
        super.configure(withSession: session)
        configure(sessionItems: session.sessionItems)
    }
    
    override func configure(sessionItems: [IDUSessionItem]) {
        super.configure(sessionItems: sessionItems)
        
        let item = sessionItems[2]
        sessionThreeTitle.text = item.title
        sessionThreeNames.text = item.speakerNames()
        sessionThreeLocation.text = item.location?.shortName
    }
    
    /*override func configure(withSession session: IDUSession, whereUserSelected isUserSelected: Bool) {
        super.configure(withSession: session)
        
        let item = session.sessionItems[2]
        sessionThreeTitle.text = item.title
        sessionThreeNames.text = item.speakerNames()
        sessionThreeLocation.text = item.location?.shortName
    }*/
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let notify = notifySessionItemSelected,
            let touch = touches.first {
            
            let point = touch.location(in: self)
            let pointX = point.x - lineView.frame.minX
            
            if pointX < separatorOneView.frame.minX {
                notify(0, point, self)
            }
            else if pointX >= separatorOneView.frame.maxX && pointX < separatorTwoView.frame.minX {
                notify(1, point, self)
            }
            else if pointX > separatorTwoView.frame.maxX {
                notify(2, point, self)
            }
        }
    }
}
