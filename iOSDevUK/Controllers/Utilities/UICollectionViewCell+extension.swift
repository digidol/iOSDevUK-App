//
//  UICollectionViewCell+extension.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 09/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    
    func addBorderWithCorner(withRadius radius: CGFloat) {
        layer.cornerRadius = radius
        layer.borderColor = UIColor.iOSDevUKDarkBlue().cgColor
        layer.borderWidth = 1.2
        layer.masksToBounds = true
        layoutIfNeeded()
    }
    
}
