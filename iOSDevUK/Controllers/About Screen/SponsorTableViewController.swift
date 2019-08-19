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
    
    var sponsors: [ServerSponsor]?
    
    /* FIXME
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
 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialiseAutomaticTableCellHeight(100.0)
        
        self.headerView.backgroundColor = UIColor.iOSDevUKRedBackground()
        self.headerImage.displayImage(named: "DefaultImage")
        self.headerImage.addBorderWithCorner(radius: 8.0)
     
        // FIXME initialiseFetchedResultsController()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sponsors?.count ?? 0
    }
    
    func configure(cell: UITableViewCell, withSponsor sponsor: ServerSponsor) {
        guard let cell = cell as? SponsorTableViewCell else {
            return
        }
        
        cell.sponsorName.text = sponsor.name
        cell.sponsorCategory.text = "\(sponsor.sponsorCategory) Sponsor"
        cell.sponsorCategory.textColor = self.view.tintColor
        
        if let _ = sponsor.url {
            cell.sponsorUrl.text = "Click for careers info"
        }
        
        cell.sponsorLogo.displayImage(named: sponsor.recordName)
        cell.tagline.text = sponsor.tagline
        
        cell.sponsorCategoryImage.image = UIImage(named: String(describing: sponsor.sponsorCategory))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let sponsor = sponsors?[indexPath.row] else {
            print("Unable to retrieve sponsor information for indexPath \(indexPath)")
            fatalError()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: sponsor.cellType), for: indexPath) as! SponsorTableViewCell
        
        configure(cell: cell, withSponsor: sponsor)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sponsor = sponsors?[indexPath.row] {
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
