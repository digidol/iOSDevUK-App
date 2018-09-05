//
//  MyScheduleTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 11/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import CoreData

class MyScheduleTableViewController: IDUTableViewController {

    @IBOutlet weak var headerImage: UIImageView!
    
    var dataManager: DataManager?
    
    /*
    Accesses the list of sessions that the user has added to 'my schedule'.
    */
    var fetchedResultsController: NSFetchedResultsController<Session>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        initialiseAutomaticTableCellHeight(50.0)
        initialiseResultsController()
        
        if let image = UIImage(named: "TalkImages-Tiled") {
            headerImage.backgroundColor = UIColor(patternImage: image)
        }
        else {
            headerImage.backgroundColor = UIColor.iOSDevUKDarkBlue()
        }
    }
    
    fileprivate func initialiseResultsController() {
        if let dataManager = dataManager {
            
            let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "ANY sessionItems.userSelected != nil")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
            
            
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: dataManager.persistentContainer.viewContext,
                sectionNameKeyPath: "section.recordName",
                cacheName: nil)
            
            do {
                try fetchedResultsController?.performFetch()
            }
            catch {
                print("************** Unable to fetch list of sections.")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        
        let sectionFetchRequest: NSFetchRequest<Section> = Section.fetchRequest()
        
        if let name = fetchedResultsController?.sections?[section - 1].name {
            sectionFetchRequest.predicate = NSPredicate(format: "recordName = %@", name)
            
            if let sectionData = try? dataManager?.persistentContainer.viewContext.fetch(sectionFetchRequest) {
                return sectionData?[0].name ?? "??"
            }
        }
        
        return "Missing"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1 + (fetchedResultsController?.sections?.count ?? 0)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        
        if sections.count < (section - 1) {
            print("error here with the count")
            return 0
        }
        
        return sections[section - 1].numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
            return cell
        }
        else {
            
            if let session = fetchedResultsController?.object(at: IndexPath(row: indexPath.row, section: indexPath.section - 1)),
               let count = session.sessionItems?.filtered(using: NSPredicate(format: "userSelected != nil")).count {
                
                let labels = ["singleCell", "doubleCell", "tripleCell"]
                if count - 1 > labels.count {
                    print("inconsistency - count is greater than the number of cells possible")
                    fatalError()
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: labels[count - 1], for: indexPath) as! ProgrammeBaseSessionItemTableViewCell
                
                cell.configure(withSession: session, whereUserSelected: true)
                
                return cell
            }
        }
        
        print("Unexpectedly reached end of tableView cell without a valid cell")
        fatalError()
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false // indexPath.section > 0
    }
    
    fileprivate func loadUserSettings() -> UserSettings? {
        if let viewContext = dataManager?.persistentContainer.viewContext {
            return UserSettings.retrieveInstance(inContext: viewContext)
        }
        
        return nil
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("just been asked to delete \(indexPath)")
            
            if let session = fetchedResultsController?.object(at: IndexPath(row: indexPath.row, section: indexPath.section - 1)) {
                
                
                
                if let selectedSessionItems = session.sessionItems(whereUserSelected: true) {
                    var commitDelete = false
                    
                    print("got a set of selected items: \(selectedSessionItems.count)")
                    
                    if selectedSessionItems.count == 1 {
                        let userSettings = loadUserSettings()
                        userSettings?.removeFromSessionItems(selectedSessionItems[0])
                        commitDelete = true
                    }
                
                    if commitDelete {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                
                }
                
                
            }
        }
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
