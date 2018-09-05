//
//  IDUTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 28/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class IDUTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func initialiseAutomaticTableCellHeight(_ estimatedHeight: CGFloat) {
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
}
