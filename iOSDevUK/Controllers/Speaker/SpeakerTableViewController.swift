//
//  SpeakerTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 05/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class SpeakerTableViewController: IDUTableViewController, IDUDataManager {
    
    @IBOutlet weak var speakerImage: UIImageView!

    @IBOutlet weak var headerImageView: UIImageView!
    
    var dataManager: DataManager?
    
    var selectedItem: ((Any) -> Void)?
    
    var speaker: Speaker?
    
    /**
     Normally, it is sensible to navigate from a speaker to a session.
     However, if you have already come from the session, then no
     need to navigate to it again. This item is used to determine if
     we have navigated from a specific session item. It is used to
     prevent navigating from this screen to the session item.
     */
    var callingSessionItem: SessionItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let speaker = speaker {
            self.title = speaker.name
            speakerImage.displayImage(named: speaker.name)
            speakerImage.addBorderWithCorner()
        }
        
        initialiseAutomaticTableCellHeight(50.0)
        
        if let image = UIImage(named: "TalkImages-Tiled") {
            headerImageView.backgroundColor = UIColor(patternImage: image)
        }
        else {
            headerImageView.backgroundColor = UIColor.iOSDevUKDarkBlue()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        else if section == 1 {
            return speaker?.sessionItems?.count ?? 0
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "speakerTitle", for: indexPath) as! SpeakerNameAndProfileDetailsTableViewCell
                cell.speaker = speaker
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "biography", for: indexPath)
                
                if let speaker = speaker {
                    cell.textLabel?.text = speaker.biography
                }
                
                return cell
            }
        }
        
        if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "speakerSessionCell", for: indexPath) as! SpeakerSessionItemTableViewCell
            let sortDescriptor = NSSortDescriptor(key: "session.startTime", ascending: true)
            if let sortedArray = speaker?.sessionItems?.sortedArray(using: [sortDescriptor]) as? [SessionItem] {
                cell.sessionItem = sortedArray[indexPath.row]
                if callingSessionItem == sortedArray[indexPath.row] {
                    cell.isUserInteractionEnabled = false
                    cell.accessoryType = .none
                }
                else {
                    cell.isUserInteractionEnabled = true
                    cell.accessoryType = .disclosureIndicator
                }
            }
            return cell
        }
        
        // else situation...
        let cell = tableView.dequeueReusableCell(withIdentifier: "biography", for: indexPath)
        cell.textLabel?.text = "missing info"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Session(s)"
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let sessionItemController = segue.destination as? SessionItemTableViewController {
            
            sessionItemController.dataManager = dataManager
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let sortDescriptor = NSSortDescriptor(key: "session.startTime", ascending: true)
                if let sortedArray = speaker?.sessionItems?.sortedArray(using: [sortDescriptor]) as? [SessionItem] {
                    sessionItemController.sessionItem = sortedArray[indexPath.row]
                }
            }
        }
    }

}
