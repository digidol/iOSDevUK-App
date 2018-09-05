//
//  SponsorTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 08/08/2017.
//  Copyright © 2017 Aberystwyth University. All rights reserved.
//

import UIKit
import SafariServices
import CoreData

class SponsorTableViewController: IDUTableViewController, SFSafariViewControllerDelegate {

    /// link to the header view in the table
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerImage: UIImageView!
    
    var dataManager: DataManager? {
        didSet {
            initialiseFetchedResultsController()
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<Sponsor>?
        
    func initialiseFetchedResultsController() {
        if let dataManager = dataManager {
           
            let fetchRequest: NSFetchRequest<Sponsor> = Sponsor.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "sponsorOrder", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: dataManager.persistentContainer.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil)
            
            do {
                try fetchedResultsController?.performFetch()
            }
            catch {
                print("Unable to fetch list of sponsors.")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialiseAutomaticTableCellHeight(100.0)
        
        self.headerView.backgroundColor = UIColor.iOSDevUKRedBackground()
        self.headerImage.displayImage(named: "DefaultImage")
        self.headerImage.addBorderWithCorner(radius: 8.0)
     
        initialiseFetchedResultsController()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        
        return sections.count
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    func configure(cell: UITableViewCell, withSponsor sponsor: Sponsor) {
        guard let cell = cell as? SponsorTableViewCell else {
            return
        }
        
        cell.sponsorName.text = sponsor.name
        cell.sponsorCategory.text = "\(sponsor.sponsorCategory ?? "Unknown") Sponsor"
        cell.sponsorCategory.textColor = self.view.tintColor
        
        if let _ = sponsor.url {
            cell.sponsorUrl.text = "Click for careers info"
        }
        
        cell.sponsorLogo.displayImage(named: "Sponsor\(sponsor.name?.replacingOccurrences(of: " ", with: "") ?? "error")")
        cell.tagline.text = sponsor.tagline
        
        if let category = sponsor.sponsorCategory {
            cell.sponsorCategoryImage.image = UIImage(named: category)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let sponsor = fetchedResultsController?.object(at: indexPath) else {
            print("Unable to retrieve sponsor information for indexPath \(indexPath)")
            fatalError()
        }
        
        guard let cellType = sponsor.cellType else {
            print("The cell type hasn't been set for \(sponsor.recordName ?? "missing name")")
            fatalError()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType, for: indexPath) as! SponsorTableViewCell
        
        configure(cell: cell, withSponsor: sponsor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sponsor = fetchedResultsController?.object(at: indexPath) {
            if let url = sponsor.url {
                let webViewController = SFSafariViewController(url: url)
                webViewController.delegate = self
                self.present(webViewController, animated: true, completion: nil)
            }
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
