//
//  SessionsTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 10/08/2018.
//  Copyright © 2018-2019 Aberystwyth University. All rights reserved.
//

import UIKit

class ProgrammeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /** Segmented control to select the different days */
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    /** Table view that displays the programme outline */
    @IBOutlet weak var tableView: UITableView!
    
    var shouldScrollToCurrent = true
    
    var appSettings: AppSettings?
    
    /** List of days for the programme. These will be in date order when they are passed to this controller. */
    var days = [IDUDay]()
    
    /** The item that has been selected. Used to allow selection and then passing to the next screen via the segue. */
    var selectedSessionItem: IDUSessionItem?
    
    var sectionsToDisplay: [IDUSection]?
    
    var appDataManager: AppDataManager?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegmentedControlWithDays(days)
        initialiseSections(forDay: nil)
        
        tableView.estimatedRowHeight = 400.0
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldScrollToCurrent {
            if let manager = appDataManager,
               let session = manager.nowSession(forDate: manager.currentTime()) {
                
                if let path = indexPath(forSession: session) {
                    tableView.scrollToRow(at: path, at: .top, animated: true)
                }
                
                shouldScrollToCurrent = false
                
            }
        }
    }
    
    func indexPath(forSession session: IDUSession) -> IndexPath? {
        
        if let sections = sectionsToDisplay {
            
            var sectionIndex = -1
            var rowIndex = -1
            
            var currentSectionPosition = 0
            
            sections.forEach { section -> Void in
                if let sessionIndex = section.sessions.firstIndex(where: { $0.recordName == session.recordName }) {
                    rowIndex = sessionIndex
                    sectionIndex = currentSectionPosition
                }
                else {
                    currentSectionPosition += 1
                }
            }
            
            if sectionIndex >= 0 && rowIndex >= 0 {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
            else {
                return nil
            }
        }
        
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Data Initialisation
    
    func initialiseSections(forDay day: IDUDay?) {
        
        if let selectedDay = day {
            self.sectionsToDisplay = selectedDay.sections
        }
        else {
            self.sectionsToDisplay = days.flatMap { $0.sections }
        }
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
            initialiseSections(forDay: days[sender.selectedSegmentIndex - 1])
            
        default:
            initialiseSections(forDay: nil)
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsToDisplay?[section].name ?? "Missing"
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsToDisplay?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionsToDisplay?[section].sessions.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let session = sectionsToDisplay?[indexPath.section].sessions[indexPath.row] {
           let count = session.sessionItems.count
            
            if count == 1 {
                let sessionItem = session.sessionItems[0]
                if [IDUSessionItemType.talk, IDUSessionItemType.workshop, IDUSessionItemType.social, IDUSessionItemType.dinner].contains(sessionItem.type) {
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
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath) as! ProgrammeOtherSessionItemTableViewCell
        cell.sessionTitle.text = "Whoops"
        cell.location.text = "Sorry, error accessing data"
        cell.emojiLabel.text = "😱"
        return cell
    }

    func notify(withSelectedItem position: Int, atPoint point: CGPoint, inCell cell: UITableViewCell) {
        if let indexPath = tableView.indexPathForRow(at: tableView.convert(point, from: cell)),
           let session = sectionsToDisplay?[indexPath.section].sessions[indexPath.row] {
            selectedSessionItem = session.sessionItems[position] //(atPosition: position)
            performSegue(withIdentifier: "programmeSessionItemDetailSegue", sender: self)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let sessionItemController = segue.destination as? SessionItemTableViewController {
            sessionItemController.appSettings = appSettings
            sessionItemController.sessionItem = selectedSessionItem
        }
    }

    
}
