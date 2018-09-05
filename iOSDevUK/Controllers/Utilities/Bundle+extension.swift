//
//  Bundle+extension.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 28/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation

/**
 * Based on example on Stack Overflow at:
 * https://stackoverflow.com/questions/25965239/how-do-i-get-the-app-version-and-build-number-using-swift
 */
extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}
