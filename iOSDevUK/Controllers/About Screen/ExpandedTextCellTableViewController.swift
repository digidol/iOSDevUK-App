//
//  ExpandedTextCellTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 01/08/2016.
//  Copyright © 2016-2019 Aberystwyth University. All rights reserved.
//

import UIKit

class ExpandedTextCellTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
