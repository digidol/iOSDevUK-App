//
//  InclusivityTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 12/07/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import UIKit

class InclusivityTableViewController: ExpandedTextCellTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Policy", for: indexPath)

        // Configure the cell...

        return cell
    }
}
