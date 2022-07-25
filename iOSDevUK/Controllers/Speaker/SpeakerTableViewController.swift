//
//  SpeakerTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 05/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import SafariServices

class SpeakerTableViewController: IDUTableViewController, IDUDataManager, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var speakerImage: UIImageView!

    @IBOutlet weak var headerImageView: UIImageView!
    
    var appSettings: AppSettings?
    
    var selectedItem: ((Any) -> Void)?
    
    var speaker: IDUSpeaker?
    
    /**
     Normally, it is sensible to navigate from a speaker to a session.
     However, if you have already come from the session, then no
     need to navigate to it again. This item is used to determine if
     we have navigated from a specific session item. It is used to
     prevent navigating from this screen to the session item.
     */
    var callingSessionItem: IDUSessionItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let speaker = speaker {
            self.title = speaker.name
            speakerImage.displayImage(named: speaker.recordName)
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
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 2
        case 1:
            return speaker?.sessionItems.count ?? 0
        case 2:
            return speaker?.webLinks.count ?? 0
        default:
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
                    cell.textLabel?.text = speaker.biography.replacingOccurrences(of: "\n", with: "\n\n")
                }
                
                return cell
            }
        }
        
        if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "speakerSessionCell", for: indexPath) as! SpeakerSessionItemTableViewCell
            
            if let sortedItems = speaker?.sessionItems.sorted(by: { $0.session.startTime < $1.session.startTime }) {
                cell.sessionItem = sortedItems[indexPath.row]
                /*if let callingItem = callingSessionItem {
                
                } callingItem == sortedItems[indexPath.row] {
                    cell.isUserInteractionEnabled = false
                    cell.accessoryType = .none
                }
                else {
                    cell.isUserInteractionEnabled = true
                    cell.accessoryType = .disclosureIndicator
                }*/
            }
            
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "linkCell", for: indexPath)
            
            if let links = speaker?.webLinks {
                cell.textLabel?.text = links[indexPath.row].name
                cell.detailTextLabel?.text = links[indexPath.row].url.absoluteString
            }
            
            return cell
        }
        
        // else situation...
        let cell = tableView.dequeueReusableCell(withIdentifier: "biography", for: indexPath)
        cell.textLabel?.text = "missing info"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 1:
            return "Session(s)"
        case 2:
            if let links = speaker?.webLinks {
                if links.count > 0 {
                    return "See also"
                }
            }
            
            return nil
            
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if let links = speaker?.webLinks {
                let webViewController = SFSafariViewController(url: links[indexPath.row].url)
                webViewController.delegate = self
                self.present(webViewController, animated: true, completion: nil)
            }
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let sessionItemController = segue.destination as? SessionItemTableViewController {
            
            if let indexPath = tableView.indexPathForSelectedRow,
               let sortedSessionItems = speaker?.sessionItems.sorted(by: { $0.session.startTime < $1.session.startTime}) {
                sessionItemController.appSettings = appSettings
                sessionItemController.sessionItem = sortedSessionItems[indexPath.row]
            }
        }
    }

}
