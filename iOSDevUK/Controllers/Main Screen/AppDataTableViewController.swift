//
//  AppDataTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 11/08/2022.
//  Copyright © 2022 Aberystwyth University. All rights reserved.
//

import UIKit

class AppDataTableViewController: UITableViewController {

    var appDataClient: AppDataClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Speakers", "Locations", "Sponsors"][section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0: return appDataClient?.imageManager().speakerImages.count ?? 0
        case 1: return appDataClient?.imageManager().locationImages.count ?? 0
        case 2: return appDataClient?.imageManager().sponsorImages.count ?? 0
        default: return 0
        }
    }
    
    private func keyList(_ dictionary: [String:Int]) -> [String] {
        return [String](dictionary.keys)
    }

    private func configureCell(_ cell: UITableViewCell, withDictionary dictionary: [String:Int], atRow row: Int) {
        let keys = keyList(dictionary).sorted()
        let key = keys[row]
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = "\(String(describing: dictionary[key]!))"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)

        if let imageManager = appDataClient?.imageManager() {
            
            switch indexPath.section {
            case 0:
                configureCell(cell, withDictionary: imageManager.speakerImages, atRow: indexPath.row)
                break
                
            case 1:
                configureCell(cell, withDictionary: imageManager.locationImages, atRow: indexPath.row)
                break
                
            case 2:
                configureCell(cell, withDictionary: imageManager.sponsorImages, atRow: indexPath.row)
                break
                
            default:
                cell.textLabel?.text = "Unknown index"
                break
            }
        }
        
        return cell
    }
    
}
