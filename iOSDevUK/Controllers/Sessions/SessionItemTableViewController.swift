//
//  SessionItemTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 06/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import CoreData

class SessionItemTableViewController: IDUTableViewController {
    
    @IBOutlet weak var addRemoveButton: UIBarButtonItem!
    
    let sections = [nil, "Description", "Speaker(s)", "Location"]
    
    var sessionItem: IDUSessionItem?
    
    fileprivate func setupButtonState() {
        /*if let userSettings = loadUserSettings(),
            let item = sessionItem,
            let inList = userSettings.sessionItems?.contains(item) {
            if inList {
                toggleAddRemoveButtonTitle()
            }
        }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseAutomaticTableCellHeight(150.0)
        
        setupButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 2 {
            return sessionItem?.speakers.count ?? 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sessionItemHeaderCell", for: indexPath) as! SessionHeaderTableViewCell
            cell.title.text = sessionItem?.title ?? "To be confirmed"
            
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "Europe/London")
            formatter.dateFormat = "EEE HH:mm"
            if let startTime = sessionItem?.session.startTime {
               cell.time.text = formatter.string(from: startTime as Date)
            }
            else {
                cell.time.text = "Unknown"
            }
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sessionItemContentCell", for: indexPath) as! ExpandingTextLabelTableViewCell
            cell.content.text = sessionItem?.content
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sessionItemSpeakerCell", for: indexPath) as! AlternativeBasicTableViewCell
            
            if let speakers = sessionItem?.sortedSpeakers() {
                cell.itemLabel.text = speakers[indexPath.row].name
                cell.itemImage?.displayImage(named: speakers[indexPath.row].name)
                            
            }
                //sessionItem?.speakers?.sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]) as! [Speaker]
            
            cell.itemImage?.addBorderWithCorner()
            return cell
        }
        else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sessionItemLocationCell", for: indexPath) as! AlternativeBasicTableViewCell
            cell.itemLabel.text = sessionItem?.location?.name ?? "To be confirmed"
            
            cell.itemImage?.displayImage(named: sessionItem?.location?.recordName, withDefault: "LocationPin")
            cell.itemImage?.addBorderWithCorner()
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            if let speakerController = segue.destination as? SpeakerTableViewController {
                if let speakers = sessionItem?.sortedSpeakers() {
                    //sessionItem?.speakers?.sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)]) as? [IDUSpeaker] {
                    
                    speakerController.speaker = speakers[indexPath.row]
                    speakerController.callingSessionItem = sessionItem
                }
            }
            else if let locationController = segue.destination as? LocationViewController {
                locationController.location = sessionItem?.location
            }
        }
    }
    
    func loadUserSettings() -> IDUUserSettings? {
        //FIXME
        /*if let viewContext = dataManager?.persistentContainer.viewContext {
            return UserSettings.retrieveInstance(inContext: viewContext)
        }*/
        
        return nil
    }
    
    @IBAction func addToMySchedule(_ sender: AnyObject) {
        
        // FIXME
        /*if let userSettings = loadUserSettings(),
           let item = sessionItem {
           
            if let inList = userSettings.sessionItems?.contains(item) {
                if !inList {
                    // FIXME userSettings.addToSessionItems(item)
                    dataManager?.save()
                    toggleAddRemoveButtonTitle()
                }
                else {
                    // FIXME userSettings.removeFromSessionItems(item)
                    dataManager?.save()
                    toggleAddRemoveButtonTitle()
                }
            }
        }*/
        
    }
    
    func toggleAddRemoveButtonTitle() {
        if let startsWithAdd = addRemoveButton.title?.starts(with: "Add") {
            addRemoveButton.title = startsWithAdd ? "Remove from my schedule" : "Add to my schedule"
        }
    }

}
