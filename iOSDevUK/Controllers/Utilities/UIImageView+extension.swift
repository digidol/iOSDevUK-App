//
//  UIImageView+extension.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 06/08/2018.
//  Copyright © 2018-2019 Aberystwyth University. All rights reserved.
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
        
        if let name = displayName {
            let cachesUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let imageUrl = cachesUrl.appendingPathComponent("\(name).png", isDirectory: false)
            if let data = try? Data(contentsOf: imageUrl),
               let image = UIImage(data: data) {
                
                self.image = image
            }
            else if let assetImage = UIImage(named: name) {
               self.image = assetImage
            }
            else {
                self.image = nil
            }
        }
        
        // fallback - show a default image
        if self.image == nil {
            self.image = UIImage(named: defaultName ?? "DefaultImage")
        }
    }
    
}
