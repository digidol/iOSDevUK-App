//
//  IDUCollectionViewDataManager.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 09/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol ImageTextCollectionViewDataManager {
    
    // FIXME var dataManager: DataManager? { get set }
    
    func numberOfSections() -> Int
    
    func numberOfItemsInSection(_ section: Int) -> Int
    
    func configureCell(_ cell: ImageTextCollectionViewCell, atIndexPath indexPath: IndexPath, withBorderRadius radius: CGFloat?)
    
    func object(at indexPath: IndexPath) -> Any?
}
