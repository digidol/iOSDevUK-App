//
//  ProgrammeDoubleSessionItemTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 10/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class ProgrammeDoubleSessionItemTableViewCell: ProgrammeSingleSessionItemTableViewCell {

    @IBOutlet weak var timeBarView: UIView!
    @IBOutlet weak var separatorOneView: UIView!
    
    @IBOutlet weak var sessionTwoTitle: UILabel!
    @IBOutlet weak var sessionTwoLocation: UILabel!
    @IBOutlet weak var sessionTwoNames: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure(withSession session: IDUSession) {
        super.configure(withSession: session)
        configure(sessionItems: session.sessionItems)
    }
    
    override func configure(sessionItems: [IDUSessionItem]) {
        super.configure(sessionItems: sessionItems)
        
        let item = sessionItems[1]
        sessionTwoTitle.text = item.title
        sessionTwoNames.text = item.speakerNames()
        sessionTwoLocation.text = item.location?.shortName
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let notify = notifySessionItemSelected,
           let touch = touches.first {
            
            let point = touch.location(in: self)
            
            if (point.x - lineView.frame.minX) < separatorOneView.frame.minX {
                notify(0, point, self)
            }
            else if (point.x - lineView.frame.minX) >= separatorOneView.frame.maxX {
                notify(1, point, self)
            }
        }
    }
}
