//
//  SessionsTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 10/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import CoreData

class ProgrammeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    // FIXME
    var days = [IDUDay]()
    
    //FIXME var dataManager: DataManager?
    
    //var fetchedResultsController: NSFetchedResultsController<Session>?
    
    var selectedSessionItem: IDUSessionItem?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*guard let manager = dataManager else {
            print("DataManager has not been set for the list of sessions")
            return
        }
        
        let days = accessDayList(withContext: manager.persistentContainer.viewContext)
        */
        setupSegmentedControlWithDays(days)
        initialiseSections(forDay: nil)
        
        tableView.estimatedRowHeight = 400.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Data Initialisation
    
    /*func accessDayList(withContext context: NSManagedObjectContext) -> [Day] {
     
        let dayFetchRequest: NSFetchRequest<Day> = Day.fetchRequest()
        dayFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            if let days = try? context.fetch(dayFetchRequest) {
                return days
            }
        }
        
        return []
    }*/
    
    func initialiseSections(forDay day: IDUDay?) {
        /*if let dataManager = dataManager {
            
            let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
            
            if let selectedDay = day {
                fetchRequest.predicate = NSPredicate(format: "section.day = %@", selectedDay)
            }
            
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
                print("Unable to fetch list of sections.")
            }
        }*/
    }
    
    // MARK: - Segmented Control
    
    func setupSegmentedControlWithDays(_ days: [IDUDay]) {
        segmentedControl.removeSegment(at: 1, animated: false)
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/London")
        formatter.dateFormat = "EEE"
        
        days.forEach { day in
            guard let date = day.date as Date? else {
                print("Unable to access date")
                return
            }
            
            self.segmentedControl.insertSegment(
                withTitle: formatter.string(from: date),
                at: self.segmentedControl.numberOfSegments,
                animated: false)
        }
        
    }
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
    
        switch sender.selectedSegmentIndex {
        case 1, 2, 3, 4:
            //FIXME let days = accessDayList(withContext: (dataManager?.persistentContainer.viewContext)!)
            initialiseSections(forDay: days[sender.selectedSegmentIndex - 1])
            
        default:
            initialiseSections(forDay: nil)
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /*let sectionFetchRequest: NSFetchRequest<Section> = Section.fetchRequest()
        
        if let name = fetchedResultsController?.sections?[section].name {
            sectionFetchRequest.predicate = NSPredicate(format: "recordName = %@", name)
            
            if let sectionData = try? dataManager?.persistentContainer.viewContext.fetch(sectionFetchRequest) {
                return sectionData?[0].name ?? "??"
            }
        }*/
        
        return "Missing"
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // return fetchedResultsController?.sections?.count ?? 0
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        guard let section = fetchedResultsController?.sections?[section] else {
            return 0
        }
        
        return section.numberOfObjects
        */
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* FIXME
         if let session = fetchedResultsController?.object(at: indexPath),
           let count = session.sessionItems?.count {
            
            if count == 1 {
                if let sessionItem = session.sessionItem(atPosition: 0) {
                    if [SessionType.talk, SessionType.workshop, SessionType.social, SessionType.dinner].contains(sessionItem.type) {
                        let singleCell = tableView.dequeueReusableCell(withIdentifier: "singleCell2", for: indexPath) as! ProgrammeSingleSessionItemTableViewCell
                        singleCell.configure(withSession: session)
                        singleCell.notifySessionItemSelected = notify(withSelectedItem:atPoint:inCell:)
                        return singleCell
                    }
                    else {
                        let otherCell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath) as! ProgrammeOtherSessionItemTableViewCell
                        otherCell.configure(withSession: session)
                        otherCell.notifySessionItemSelected = notify(withSelectedItem:atPoint:inCell:)
                        return otherCell
                    }
                }
            }
            else if count == 2 {
                let doubleCell = tableView.dequeueReusableCell(withIdentifier: "doubleCell", for: indexPath) as! ProgrammeDoubleSessionItemTableViewCell
                doubleCell.configure(withSession: session)
                doubleCell.notifySessionItemSelected = notify(withSelectedItem:atPoint:inCell:)
                return doubleCell
            }
            else if count == 3 {
                let tripleCell = tableView.dequeueReusableCell(withIdentifier: "tripleCell", for: indexPath) as! ProgrammeTripleSessionItemTableViewCell
                tripleCell.configure(withSession: session)
                tripleCell.notifySessionItemSelected = notify(withSelectedItem:atPoint:inCell:)
                return tripleCell
            }
        }*/
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath) as! ProgrammeOtherSessionItemTableViewCell
        cell.sessionTitle.text = "Whoops"
        cell.location.text = "Sorry, error accessing data"
        cell.emojiLabel.text = "😱"
        return cell
    }

    func notify(withSelectedItem position: Int, atPoint point: CGPoint, inCell cell: UITableViewCell) {
        /*
        FIXME
        if let indexPath = tableView.indexPathForRow(at: tableView.convert(point, from: cell)),
           let session = fetchedResultsController?.object(at: indexPath) {
            
            // FIXME selectedSessionItem = session.sessionItem(atPosition: position)
            performSegue(withIdentifier: "programmeSessionItemDetailSegue", sender: self)
        }*/
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let sessionItemController = segue.destination as? SessionItemTableViewController {
            // FIXME sessionItemController.dataManager = dataManager
            sessionItemController.sessionItem = selectedSessionItem
        }
    }

    
}
