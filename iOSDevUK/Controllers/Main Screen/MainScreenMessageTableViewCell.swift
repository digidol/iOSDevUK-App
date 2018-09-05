//
//  MainScreenMessageTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 12/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class MainScreenMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var logoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
