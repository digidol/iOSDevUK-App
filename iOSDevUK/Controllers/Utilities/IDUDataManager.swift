//
//  IDUDataManager.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 05/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import UIKit

protocol IDUDataManager {
    
    //var dataManager: DataManager? { get set }
    
    var selectedItem: ((_ item: Any) -> Void)? { get set }

}
