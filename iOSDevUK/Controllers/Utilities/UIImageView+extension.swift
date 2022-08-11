//
//  UIImageView+extension.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 06/08/2018.
//  Copyright © 2018-2022 Aberystwyth University. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func addBorderWithCorner() {
        addBorderWithCorner(radius: frame.width / 2)
    }
    
    func addBorderWithCorner(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.borderColor = UIColor.iOSDevUKDarkBlue().cgColor
        layer.borderWidth = 2
        layer.masksToBounds = true
        layoutIfNeeded()
    }
    
    func displayImage(named imageName: String?, inCategory category: AppImageCategory) {
        displayImage(named: imageName, inCategory: category, withDefault: nil)
    }
    
    func displayImage(named imageName: String?, inCategory category: AppImageCategory, withDefault defaultName: String?) {
        
        // clear any previous image
        self.image = nil
        
        // try to load the requested image
        let imageManager = AppDataClient.shared.imageManager()
        print("imageManager speakers: \(imageManager.speakerImages)")
        print("imageManager speakers: \(imageManager.locationImages)")
        print("imageManager speakers: \(imageManager.sponsorImages)")
        if let name = imageName,
           let displayImage = imageManager.loadImage(withName: name, inCategory: category) {
            self.image = displayImage
        }
        
        // set a fallback image
        if self.image == nil {
            self.image = UIImage(named: defaultName ?? "DefaultImage")
        }
    }
}
