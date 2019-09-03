//
//  MyScheduleTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 11/08/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit

class ScheduleSection {
    var recordName: String
    var date: Date
    var sessions = [ScheduleSession]()
    
    init(recordName: String, date: Date) {
        self.recordName = recordName
        self.date = date
    }
    
    func session(forName name: String) -> ScheduleSession? {
        if let index = sessions.firstIndex(where: { $0.recordName == name }) {
            return sessions[index]
        }
        
        return nil
    }
    
    func add(session: ScheduleSession) {
        sessions.append(session)
    }
    
    func orderedSessions() -> [ScheduleSession] {
        return sessions.sorted(by: { $0.startTime < $1.startTime })
    }
    
}

class ScheduleSession {
    var recordName: String
    var startTime: Date
    var endTime: Date
    var sessionItems = [IDUSessionItem]()
    
    init(recordName: String, startTime: Date, endTime: Date) {
        self.recordName = recordName
        self.startTime = startTime
        self.endTime = endTime
    }
    
    func add(sessionItem: IDUSessionItem) {
        sessionItems.append(sessionItem)
    }
    
    func orderedSessionItems() -> [IDUSessionItem] {
        return sessionItems.filter( { $0.location != nil } )
                           .sorted(by: { $0.location!.recordName > $1.location!.recordName })
    }

}


class MyScheduleTableViewController: IDUTableViewController {

    @IBOutlet weak var headerImage: UIImageView!
    
    private var appSettings: AppSettings?
    
    private var scheduleItems: [IDUSessionItem]?
    
    private var scheduleSections: [ScheduleSection]?
    
    /** The item that has been selected. Used to allow selection and then passing to the next screen via the segue. */
    var selectedSessionItem: IDUSessionItem?
    
    
    var sessionItems: [String:IDUSessionItem]?
    
    
    func setup(sessionItems items: [String:IDUSessionItem], withSettings appSettings: AppSettings) {
        
        self.appSettings = appSettings
        self.sessionItems = items
        buildScheduleSections()
    }
    
    func buildScheduleSections() {
        if let settings = appSettings,
           let recordNames = settings.scheduleItems() {
            
            var sections = [String:ScheduleSection]()
            
            recordNames.forEach( { name in
                if let sessionItem = sessionItems?[name] {
                    
                    let parentSession = sessionItem.session
                    let parentSection = parentSession.section
                    
                    var section = sections[parentSection.recordName]
                    if section == nil {
                        section = ScheduleSection(recordName: parentSection.recordName, date: parentSession.startTime)
                        sections[section!.recordName] = section!
                    }
                    
                    if let session = section!.session(forName: parentSession.recordName) {
                        session.add(sessionItem: sessionItem)
                    }
                    else {
                        let session  = ScheduleSession(recordName: parentSession.recordName, startTime: parentSession.startTime, endTime: parentSession.endTime)
                        section!.add(session: session)
                        session.add(sessionItem: sessionItem)
                    }
                    
                }
            })
            
            scheduleSections = sections.values.sorted(by: { $0.date < $1.date })
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        initialiseAutomaticTableCellHeight(50.0)
        
        if let image = UIImage(named: "TalkImages-Tiled") {
            headerImage.backgroundColor = UIColor(patternImage: image)
        }
        else {
            headerImage.backgroundColor = UIColor.iOSDevUKDarkBlue()
        }
        
        configureRefreshControl()
    }
    
    /**
     Rebuild the schedule sections in case the user has removed something
     from their schedule when they looked at the schedule details.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildScheduleSections()
        tableView.reloadData()
    }
    
    func configureRefreshControl () {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(synchronizeKeystore), for: .valueChanged)
    }
    
    @objc func synchronizeKeystore() {
        
        // FIXME - this line is probably not needed.
        appSettings?.synchronize()
        
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
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
        
        if let sections = scheduleSections {
            return sections[section - 1].recordName
        }
        
        return "Missing"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (scheduleSections?.count ?? 0)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        return scheduleSections?[section - 1].sessions.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
            return cell
        }
        else {
            
            if let session = scheduleSections?[indexPath.section - 1].orderedSessions()[indexPath.row] {
               let count = session.orderedSessionItems().count
                
                let labels = ["singleCell", "doubleCell", "tripleCell"]
                if count - 1 > labels.count {
                    print("inconsistency - count is greater than the number of cells possible")
                    fatalError()
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: labels[count - 1], for: indexPath) as! ProgrammeBaseSessionItemTableViewCell
                
                cell.configure(startTime: session.startTime, endTime: session.endTime, sessionItems: session.orderedSessionItems())
                cell.notifySessionItemSelected = notify(withSelectedItem:atPoint:inCell:)
                return cell
            }
        }
        
        print("Unexpectedly reached end of tableView cell without a valid cell")
        fatalError()
    }
    
    /**
     Called when a cell is tapped on the screen. This function will resolve which sessionItem was
     selected in the row and then activate a segue to show the details for that session.
     
     - Parameters:
         - position: The selection index for the cell, indexed from 0.
         - point: The touch point, which is used to determine which row was selected.
         - cell: The cell which received the touch event.
     */
    func notify(withSelectedItem position: Int, atPoint point: CGPoint, inCell cell: UITableViewCell) {
        if let indexPath = tableView.indexPathForRow(at: tableView.convert(point, from: cell)),
            let session = scheduleSections?[indexPath.section - 1].orderedSessions()[indexPath.row] {
            selectedSessionItem = session.orderedSessionItems()[position]
            performSegue(withIdentifier: "myScheduleSessionItemDetailSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let sessionItemController = segue.destination as? SessionItemTableViewController {
            sessionItemController.appSettings = appSettings
            sessionItemController.sessionItem = selectedSessionItem
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false // indexPath.section > 0
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("just been asked to delete \(indexPath)")
            
            /*if let session = fetchedResultsController?.object(at: IndexPath(row: indexPath.row, section: indexPath.section - 1)) {
                
                
                
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
            }*/
        }
    }
    

}
