//
//  ProgrammeSingleItemTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 10/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class ProgrammeSingleSessionItemTableViewCell: ProgrammeBaseSessionItemTableViewCell {

    @IBOutlet weak var sessionOneTitle: UILabel!
    @IBOutlet weak var sessionOneLocation: UILabel!
    @IBOutlet weak var sessionOneNames: UILabel!
    
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
        
        let item = session.sessionItems[0]
        sessionOneTitle.text = item.title
        sessionOneNames.text = item.speakerNames()
        sessionOneLocation.text = item.location?.shortName
        
    }
    
    override func configure(withSession session: IDUSession, whereUserSelected isUserSelected: Bool) {
        super.configure(withSession: session)
        
        // FIXME - look at whereUserSelected...
        let item = session.sessionItems[0] //{ //, whereUserSelected: isUserSelected) {
        sessionOneTitle.text = item.title
        sessionOneNames.text = item.speakerNames()
        sessionOneLocation.text = item.location?.shortName
    }

}
