//
//  ExpandingTextLabelTableViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 17/08/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import UIKit

class ExpandingTextLabelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var content: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var contentText: String? {
        didSet {
            if let content = self.content {
                content.text = contentText
            }
            else {
                print("Error")
            }
        }
    }

}
