//
//  SessionItemCollectionViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 04/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class SessionItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var speaker: UILabel!
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var speakerOneImage: UIImageView! {
        didSet {
            if let imageView = speakerOneImage {
                imageView.addBorderWithCorner()
            }
        }
    }
    
    @IBOutlet weak var speakerTwoImage: UIImageView! {
        didSet {
            if let imageView = speakerTwoImage {
                imageView.addBorderWithCorner()
            }
        }
    }
    
}
