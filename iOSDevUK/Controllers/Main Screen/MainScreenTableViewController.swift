//
//  MainScreenTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 28/07/2018.
//  Copyright © 2018-2019 Aberystwyth University. All rights reserved.
//

import UIKit
import SafariServices

/**
 Manages the opening screen in the app, which provides access to all other screens.
 */
class MainScreenTableViewController: IDUTableViewController, SFSafariViewControllerDelegate {

    var appDataManager: AppDataManager?
    
    /**
     Holds a reference to an object that was selected in a collection view in one of the
     table rows on this screen. This value is set in the callback closure and then used
     within the prepare(for:sender:) function to pass a value to the relevant view.
     */
    var selectedCollectionViewItem: Any?
    
    /**
     Prepares the operations that will setup the data. It will also setup the table for
     auto-resizing of the table height and prepare to use ForceTouch on the items shown
     on this screen.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialiseAutomaticTableCellHeight(50.0)
        
        //loadLocalData()
        checkForServerData()
        
        configureRefreshControl()
        
        //setAlternativeTime(time: "2022-07-15T15:10:00+01:00")
    }
    
    /**
     Configure the table to have a refresh control. This will call the updateData
     function when activated.
     */
    func configureRefreshControl () {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(checkForServerData),
                                            for: .valueChanged)
    }
    
    func endRefreshControlDisplay() {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /*func loadLocalData() {
        if let manager = appDataManager {
            manager.loadLocalData { () -> Void in
                print("handle image load for local data")
                self.reloadData()
            }
        }
    }*/
    
    /**
     If the data manager is set for this screen, start the process to check if
     updated data is on the server and, if so, download it.
     */
    @objc func checkForServerData() {
        if let manager = appDataManager {
            
            let dataCallback = { (success: Bool) -> Void in
                if success {
                    self.reloadData()
                }
                
                self.endRefreshControlDisplay()
            }
            
            let imageCallback = { () -> Void in
                self.reloadData()
            }
            
            manager.initialiseData(onCompletion: dataCallback, afterImageDownload: imageCallback)
            
        }
    }
    
    /**
     Show the screen, making sure that the table data is re-displayed. This will
     check if a period of time has passed since the most recent update. If it has,
     start the process to check if there is more recent data on the server.
     
     Calls `super` implementation before checking if an update is required.
     
     - Parameters:
      - animated: If true, the view is being added to the window using an animation.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let manager = appDataManager {
            if manager.shouldTryRemoteUpdate() {
                checkForServerData()
            }
        }
        
        tableView.reloadData()
    }
    
    func setAlternativeTime(time: String) {
        if let manager = appDataManager {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: "Europe/London")
            manager.setAlternativeDate(dateFormatter.date(from: time)!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    /**
     Initialises the conference date, which is used to determine if the time is before, during or after the conference.
     */
    func conferenceDate() -> ConferenceDate? {
        
        if let manager = appDataManager,
           let startDate = manager.startDate(),
           let endDate = manager.endDate() {
            
            return ConferenceDate(currentDate: manager.currentTime(),
                                  startDate: startDate,
                                  endDate: endDate)
        }
        
        return nil
    }
    
    fileprivate func processMessageAndNowNextCell(forTableView tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        if let date = conferenceDate() {
            if date.conferenceDateStatus() == .beforeConference {
                let cell = tableView.dequeueReusableCell(withIdentifier: "outOfConferenceMessage", for: indexPath) as! MainScreenMessageTableViewCell
                cell.messageLabel.text = "We start in \(date.timeToStartAsString())"
                cell.logoView.image = UIImage(named: "DefaultImage")
                return cell
            }
            else if date.conferenceDateStatus() == .afterConference {
                let cell = tableView.dequeueReusableCell(withIdentifier: "outOfConferenceMessage", for: indexPath) as! MainScreenMessageTableViewCell
                cell.messageLabel.text = "iOSDevUK 9 has finished. Follow @iOSDevUK for details about next year"
                cell.logoView.image = UIImage(named: "DefaultImage")
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowNextItems", for: indexPath) as! NowAndNextTableViewCell
                
                if let dataManager = appDataManager {
                   cell.nowSession = dataManager.nowSession(forDate: dataManager.currentTime())
                   cell.nextSession = dataManager.nextSession(forDate: dataManager.currentTime())
                   cell.selectedItem = { item in
                        self.selectedCollectionViewItem = item
                        self.performSegue(withIdentifier: "sessionItemSegue", sender: self)
                   }
                }
                
                cell.collectionView.reloadData()
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "outOfConferenceMessage", for: indexPath) as! MainScreenMessageTableViewCell
            cell.messageLabel.numberOfLines = 0
            cell.messageLabel.text = "Loading conference data"
            cell.logoView.image = UIImage(named: "DefaultImage")
            return cell
        }
    }
    
    fileprivate func processSessionItemsCell(forTableView tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let sessionItemCell = tableView.dequeueReusableCell(withIdentifier: "sessionItems", for: indexPath) as! SessionItemsTableViewCell
        
        if let manager = appDataManager {
            sessionItemCell.setup(sessionItems: manager.sessionItems())
            sessionItemCell.selectedItem = {
                item in
                self.selectedCollectionViewItem = item
                self.performSegue(withIdentifier: "sessionItemSegue", sender: self)
            }
            sessionItemCell.collectionView?.reloadData()
        }
        return sessionItemCell
    }
    
    fileprivate func processSpeakersCell(forTableView tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let speakerCell = tableView.dequeueReusableCell(withIdentifier: "speakers", for: indexPath) as! SpeakersTableViewCell
        
        if let manager = appDataManager {
            speakerCell.speakers = manager.speakers()
            speakerCell.selectedItem = { item in
                self.selectedCollectionViewItem = item
                self.performSegue(withIdentifier: "mainSpeakerSegue", sender: self)
            }
            speakerCell.collectionView?.reloadData()
        }
        
        return speakerCell
    }
    
    /**
     Prepares a cell that will show a list of locations in a collection view. There will be
     options to view maps and lists of locations, too. The list of locations to display
     will be determined by the NSPredicate that is passed to the cell. Further, a closure
     is created to allow the collection view to pass back an item that the user has selected. That
     closure will trigger a segue to the relevant connected view. 
     
     - Parameters:
        - tableView: The table view that contains the cell to dequeue.
        - indexPath: The indexPath for the cell to dequeue.
     
     - Returns: A cell that contains the list of locations that should appear on the front screen.
     */
    fileprivate func processLocationsCell(forTableView tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let locationCell = tableView.dequeueReusableCell(withIdentifier: "locations", for: indexPath) as! LocationsTableViewCell
        
        if let manager = appDataManager {
            locationCell.setup(locations: manager.locations())
            locationCell.selectedItem = {
                item in
                self.selectedCollectionViewItem = item
                self.performSegue(withIdentifier: "mainLocationSegue", sender: self)
            }
            locationCell.collectionView?.reloadData()
        }
        return locationCell
    }
    
    /**
     Prepares the cells for the different rows that contain collection views or information rows on the screen.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "information", for: indexPath)
        }
        else if indexPath.row == 1 {
            return processMessageAndNowNextCell(forTableView: tableView, atIndexPath: indexPath)
        }
        else if indexPath.row == 2 {
            return processSessionItemsCell(forTableView: tableView, atIndexPath: indexPath)
        }
        else if indexPath.row == 3 {
            return processSpeakersCell(forTableView: tableView, atIndexPath: indexPath)
        }
        else if indexPath.row == 4 {
            return processLocationsCell(forTableView: tableView, atIndexPath: indexPath)
        }
        else {
            // FIXME - assess if this should return an empty default table view cell.
            // should not reach this section in production.
            fatalError()
        }
    }
    
    
    // MARK: - Navigation

    /**
     Handles the segue operation to one of the connected views. Some of these
     segues are directly linked to controls in the Main Screen view. However, some are
     triggered programmatically.
     
     - Parameters:
        - segue: The storyboard segue that has started.
        - sender: The object that started this segue. The value isn't ussed within the method and can be nil.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let aboutController = segue.destination as? AboutTableViewController {
            aboutController.sponsors = appDataManager?.sponsors() ?? []
        }
        else if let speakerController = segue.destination as? SpeakerTableViewController {
            speakerController.appSettings = appDataManager?.settings()
            speakerController.speaker = selectedCollectionViewItem as? IDUSpeaker
        }
        else if let sessionItemController = segue.destination as? SessionItemTableViewController {
            sessionItemController.appSettings = appDataManager?.settings()
            sessionItemController.sessionItem = selectedCollectionViewItem as? IDUSessionItem
        }
        else if let speakersController = segue.destination as? SpeakersCollectionViewController {
            speakersController.appSettings = appDataManager?.settings()
            speakersController.speakers = appDataManager?.speakers()
        }
        else if let locationsController = segue.destination as? LocationsCollectionViewController {
            locationsController.locations = appDataManager?.locations() ?? []
        }
        else if let singleLocationController = segue.destination as? MapLocationViewController {
            singleLocationController.location = selectedCollectionViewItem as? IDULocation
        }
        else if let mapLocationsController = segue.destination as? AllLocationsMapViewController {
            mapLocationsController.locationTypes = appDataManager?.locationTypes() ?? []
        }
        else if let programmeController = segue.destination as? ProgrammeTableViewController {
            programmeController.appSettings = appDataManager?.settings()
            programmeController.appDataManager = appDataManager
            programmeController.days = appDataManager?.days() ?? []
        }
        else if let myScheduleController = segue.destination as? MyScheduleTableViewController {
            
            if let settings = appDataManager?.settings(),
                let sessionItems = appDataManager?.sessionItemDictionary() {
                myScheduleController.setup(sessionItems: sessionItems, withSettings: settings)
            }
            
        }
        else if let sponsorController = segue.destination as? SponsorTableViewController {
            sponsorController.sponsors = self.appDataManager?.sponsors() ?? []
        }
    }
    
    /**
     Starts process to show the iOSDevUK twitter details.
     
     - Parameters:
        - sender: object that caused the IBAction to be activated. This isn't used by the function.
     */
    @IBAction func showiOSDevUKTwitter(_ sender: AnyObject) {
        showTwitterAccount("iOSDevUK")
    }
    
    /**
     Starts process to show the AberCompSci twitter details.
     
     - Parameters:
        - sender: object that caused the IBAction to be activated. This isn't used by the function.
     */
    @IBAction func showAberCompSciTwitter(_ sender: AnyObject) {
        showTwitterAccount("AberCompSci")
    }
    
    /**
     Displays the specified URL in a Safari View Controller.
     
     - Parameters:
         - twitterId: the twitter account that will be shown.
     */
    func showTwitterAccount(_ twitterId: String) {
        if let url = URL(string: "https://twitter.com/\(twitterId)") {
            let webViewController = SFSafariViewController(url: url)
            webViewController.delegate = self
            self.present(webViewController, animated: true, completion: nil)
        }
    }
    
    /**
     Dismiss the Safari View that is shown for the Twitter Account.
     Method definition is from the SFSafariViewControllerDelegate.
     
     - Parameters:
         - controller: The controller that has been dismissed.
     */
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    /**
     Administration function that can start the process to send data to CloudKit.
     This is never intended for deployment, only during development.
     
     The function will create a background task and then create an instance
     of CloudDataManager. That is reponsible for sending data to the iCloud.
     
     - Note: Not currently used. Only linked to interface during some experimentation.
     
     - Parameter sender: The object that initiated this action.
     */
    @IBAction func uploadData(_ sender: AnyObject) {
        
        /*dataManager?.persistentContainer.performBackgroundTask {
            context in
            let manager = CloudDataManager(context: context)
            manager.upload()
        }*/
        
    }
}
