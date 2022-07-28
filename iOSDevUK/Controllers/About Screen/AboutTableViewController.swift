//
//  AboutViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 12/07/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import UIKit
import SafariServices

class AboutTableViewController: ExpandedTextCellTableViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var headerView: UIView!
    
    var sponsors: [ServerSponsor]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self,
                                       action: #selector(AboutTableViewController.handleRefresh),
                                       for: .valueChanged)

        headerView.backgroundColor = UIColor.iOSDevUKDarkBlue()
    }
    
    /**
 
     */
    @objc func handleRefresh() {
        print("handle refresh")
        
        //let cloudDataAccess = CloudDataAccess()
        //cloudDataAccess.reloadAllUpdates(self.refreshEnded)
    }
    
    /**
  
     */
    func refreshEnded(_ success: Bool) {
        self.refreshControl?.endRefreshing()
        print("Ended with success: \(success)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeView(_ sender: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table View Delegate 
    
    
    
    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        if indexPath.row == 0 {
            
            let expandableCell = tableView.dequeueReusableCell(withIdentifier: "Block", for: indexPath) as! ExpandableSubtitleTableViewCell
            
            expandableCell.cellTitle.text = "iOSDevUK is the UK conference for iOS developers. It takes place in Aberystwyth, on the mid-Wales coast, from 5th to the 8th September 2022.\n\nGreat talks • Great get-togethers • optional workshops on the Monday and Thursday."
            
            cell = expandableCell
        }
        else if indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Sponsors", for: indexPath)
            
        }
        else if indexPath.row == 2 {
            let expandableCell = tableView.dequeueReusableCell(withIdentifier: "Inclusivity", for: indexPath) as! ExpandableSubtitleTableViewCell
            
            expandableCell.cellTitle.text = "Inclusivity Policy"
            expandableCell.cellSubtitle.text = "Read our policy to ensure inclusivity for all attendees"
            
            cell = expandableCell
            
        }
        else if indexPath.row == 3 {
            let expandableCell = tableView.dequeueReusableCell(withIdentifier: "Website", for: indexPath) as! ExpandableSubtitleTableViewCell
            
            expandableCell.cellTitle.text = "iOSDevUK Website"
            expandableCell.cellSubtitle.text = "Find out more at the conference website"
            
            cell = expandableCell
            
        }
        else if indexPath.row == 4 {
            let expandableCell = tableView.dequeueReusableCell(withIdentifier: "Website", for: indexPath) as! ExpandableSubtitleTableViewCell
            
            expandableCell.cellTitle.text = "Aberystwyth University"
            expandableCell.cellSubtitle.text = "Find out more about the conference organisers"
            
            cell = expandableCell
        }
        else {
            let expandableCell = tableView.dequeueReusableCell(withIdentifier: "Block", for: indexPath) as! ExpandableSubtitleTableViewCell
            
            expandableCell.cellTitle.text = "The conference is organised by Aberystwyth University and it is now in its ninth year. iOS, iPhone, iPad, Apple Watch, watchOS, Apple TV and tvOS are trademarks of Apple Inc. For the avoidance of doubt, Apple Inc. has no association with this conference."
            
            cell = expandableCell
        }
        
        
        return cell
    }
    
    /**
    Displays the specified URL in a Safari View Controller.
     
    - Parameters: 
       - url: the URL to display in Safari View Controller
    */
    private func displayWebViewController(url: URL) {
        let webViewController = SFSafariViewController(url: url)
        webViewController.delegate = self
        self.present(webViewController, animated: true, completion: nil)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 3 {
            displayWebViewController(url: URL(string: "http://www.iosdevuk.com/")!)
        }
        else if indexPath.row == 4 {
            displayWebViewController(url: URL(string: "http://www.aber.ac.uk/en/cs/")!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if let sponsorView = segue.destination as? SponsorTableViewController {
            sponsorView.sponsors = sponsors
        }
    }
}
