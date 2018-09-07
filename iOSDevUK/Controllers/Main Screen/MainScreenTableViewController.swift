//
//  MainScreenTableViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 28/07/2018.
//  Copyright © 2018 Aberystwyth University. All rights reserved.
//

import UIKit
import SafariServices
import CoreData

/**
 Manages the opening screen in the app, which provides access to all other screens.
 */
class MainScreenTableViewController: IDUTableViewController, SFSafariViewControllerDelegate {

    /**
     Data Manager that provides access to the CoreData stack.
     */
    var dataManager: DataManager?
    
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

        setupData()
        
        initialiseAutomaticTableCellHeight(50.0)
        
        setAlternativeTime(time: "2018-09-07T15:14:00+01:00")
    }
    
    func setAlternativeTime(time: String) {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/London")
        dataManager!.alternativeTime = dateFormatter.date(from: time)
    }
    
    /**
     Runs a process to setup the data. This will start a background task
     that checks for existing data and then, if necessary, performs updates
     to the database.
     
     This is done on a background task with a new child context
     to avoid thread errors with manipulating the data store for update and display
     at the same time.
     
     The final task of this function is to reload the data in the table.
     */
    func setupData() {
        if let manager = dataManager {
            manager.persistentContainer.performBackgroundTask { context in
                
                ////////////////////////////////////////////////////////////
                // FIXME - remember to not ship with this statement enabled
                //manager.clearAllData(inContext: context)
                ////////////////////////////////////////////////////////////
                
                var dataModelVersion = AppSetting.dataModelVersion(inContext: context)
                if dataModelVersion == 0 {
                    print("DataSetup --> initialising the data")
                    manager.initialiseData(inContext: context)
                }
                
                dataModelVersion = AppSetting.dataModelVersion(inContext: context)
                if dataModelVersion == 20180815 {
                    print("DataSetup --> will update to 20180823")
                    manager.updateData(withIdentifier: 20180823, inContext: context)
                }
                
                dataModelVersion = AppSetting.dataModelVersion(inContext: context)
                if dataModelVersion == 20180823 {
                    print("DataSetup --> ** will update to 20180831")
                    manager.updateData(withIdentifier: 20180831, inContext: context)
                }
                
                dataModelVersion = AppSetting.dataModelVersion(inContext: context)
                if dataModelVersion == 20180831 {
                    print("DataSetup -> no further update")
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    /**
     Show the screen, making sure that the table data is re-displayed.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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

    func conferenceDate() -> ConferenceDate? {
        if let viewContext = dataManager?.persistentContainer.viewContext,
           let startTime = AppSetting.conferenceStartTime(inContext: viewContext) as Date?,
           let endTime = AppSetting.conferenceEndTime(inContext: viewContext) as Date? {
            
            return ConferenceDate(currentDate: dataManager!.currentTime(), startDate: startTime, endDate: endTime)
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
                cell.messageLabel.text = "iOSDevUK 8 has finished. Follow @iOSDevUK for details about next year"
                cell.logoView.image = UIImage(named: "DefaultImage")
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nowNextItems", for: indexPath) as! NowAndNextTableViewCell
                cell.nowSession = Session.nowSession(forDate: dataManager!.currentTime(), inContext: dataManager!.persistentContainer.viewContext)
                cell.nextSession = Session.nextSession(forDate: dataManager!.currentTime(), inContext: dataManager!.persistentContainer.viewContext)
                cell.collectionView.reloadData()
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "outOfConfernceMessage", for: indexPath) as! MainScreenMessageTableViewCell
            cell.messageLabel.numberOfLines = 0
            cell.messageLabel.text = "Setting up database"
            cell.logoView.image = UIImage(named: "DefaultImage")
            return cell
        }
    }
    
    fileprivate func processSessionItemsCell(forTableView tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let sessionItemCell = tableView.dequeueReusableCell(withIdentifier: "sessionItems", for: indexPath) as! SessionItemsTableViewCell
        sessionItemCell.dataManager = dataManager
        sessionItemCell.selectedItem = {
            item in
            self.selectedCollectionViewItem = item
            self.performSegue(withIdentifier: "sessionItemSegue", sender: self)
        }
        sessionItemCell.collectionView?.reloadData()
        return sessionItemCell
    }
    
    fileprivate func processSpeakersCell(forTableView tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        let speakerCell = tableView.dequeueReusableCell(withIdentifier: "speakers", for: indexPath) as! SpeakersTableViewCell
        speakerCell.collectionDataManager = SpeakerImageTextCollectionViewCellDataManager(dataManager: dataManager!)
        speakerCell.selectedItem = {
            item in
            self.selectedCollectionViewItem = item
            self.performSegue(withIdentifier: "mainSpeakerSegue", sender: self)
        }
        speakerCell.collectionView?.reloadData()
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
        locationCell.collectionDataManager = LocationImageTextCollectionViewCellDataManager(dataManager: dataManager!, withSortKey: "frontListPosition", withPredicate: NSPredicate(format: "frontListPosition > 0"))
        locationCell.selectedItem = {
            item in
            self.selectedCollectionViewItem = item
            self.performSegue(withIdentifier: "mainLocationSegue", sender: self)
        }
        locationCell.collectionView?.reloadData()
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
            aboutController.dataManager = dataManager
        }
        else if let speakerController = segue.destination as? SpeakerTableViewController {
            speakerController.dataManager = dataManager
            speakerController.speaker = selectedCollectionViewItem as? Speaker
        }
        else if let sessionItemController = segue.destination as? SessionItemTableViewController {
            sessionItemController.dataManager = dataManager
            sessionItemController.sessionItem = selectedCollectionViewItem as? SessionItem
        }
        else if let speakersController = segue.destination as? SpeakersCollectionViewController {
            speakersController.collectionDataManager = SpeakerImageTextCollectionViewCellDataManager(dataManager: dataManager!)
        }
        else if let locationsController = segue.destination as? LocationsCollectionViewController {
            locationsController.collectionDataManager = LocationImageTextCollectionViewCellDataManager(dataManager: dataManager!, withSortKey: "name", withPredicate: nil)
        }
        else if let singleLocationController = segue.destination as? MapLocationViewController {
            singleLocationController.location = selectedCollectionViewItem as? Location
        }
        else if let mapLocationsController = segue.destination as? AllLocationsMapViewController {
            mapLocationsController.dataManager = dataManager
        }
        else if let programmeController = segue.destination as? ProgrammeTableViewController {
            programmeController.dataManager = dataManager
        }
        else if let myScheduleController = segue.destination as? MyScheduleTableViewController {
            myScheduleController.dataManager = dataManager
        }
        else if let sponsorController = segue.destination as? SponsorTableViewController {
            sponsorController.dataManager = dataManager
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
        
        dataManager?.persistentContainer.performBackgroundTask {
            context in
            let manager = CloudDataManager(context: context)
            manager.upload()
        }
        
    }
}
