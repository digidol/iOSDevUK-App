//
//  SpeakersCollectionViewCell.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 04/08/2018.
//  Copyright © 2018-2022 Aberystwyth University. All rights reserved.
//

import UIKit

class ImageTextCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var twitterId: UILabel?
    
    func configure(name: String,
                   imageName: String,
                   twitterId: String?,
                   withBorderRadius radius: CGFloat?) {
        self.name.text = name
        self.image.displayImage(named: imageName, inCategory: .speakers)
        if radius != nil {
            image.addBorderWithCorner(radius: radius!)
        }
        else {
            image.addBorderWithCorner()
        }
            
        if let twitter = twitterId, !twitter.isEmpty {
            self.twitterId?.text = "@\(twitter)"
        }
        else {
            self.twitterId?.text = nil
        }
    }
}
