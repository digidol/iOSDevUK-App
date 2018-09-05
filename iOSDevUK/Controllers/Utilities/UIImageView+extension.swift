//
//  UIImageView+extension.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 06/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
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
    
    func displayImage(named imageName: String?) {
        displayImage(named: imageName, withDefault: nil)
    }
    
    func displayImage(named imageName: String?, withDefault defaultName: String?) {
        
        var displayName = imageName?.replacingOccurrences(of: " ", with: "")
        displayName = displayName?.replacingOccurrences(of: "(", with: "")
        displayName = displayName?.replacingOccurrences(of: ")", with: "")
        
        if let name = displayName,
            let speakerImage = UIImage(named: name) {
            self.image = speakerImage
        }
        else {
            self.image = UIImage(named: defaultName ?? "DefaultImage")
        }
    }
    
}
