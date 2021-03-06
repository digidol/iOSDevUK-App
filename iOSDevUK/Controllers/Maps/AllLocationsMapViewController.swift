//
//  AllLocationsMapViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 08/08/2017.
//  Copyright © 2017 Aberystwyth University. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AllLocationsMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var dataManager: DataManager? {
        didSet {
            initialiseData()
        }
    }
    
    /// Types of location that are shown in the table
    //var locationTypes = [Any]()
    
    /// The map on display
    @IBOutlet var mapView: MKMapView!
    
    /// The segmented control that determine if satellite view is shown
    @IBOutlet var mapTypes: UISegmentedControl!
    
    /// Table of categories that can be shown on the map
    @IBOutlet var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController<LocationType>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initialiseData() {
        
        if let dataManager = dataManager {
            let fetchRequest: NSFetchRequest<LocationType> = LocationType.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
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
                print("Unable to fetch list of location types.")
            }
        }
        else {
            print("Unable to access data manager in AllLocationsMapViewController")
            fatalError()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let path = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: path, animated: true, scrollPosition: .none)
        showMapLocations(forIndexPath: path)
    }
    
    
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? LocationViewController,
           let location = ((sender as? MKAnnotationView)?.annotation as? Annotation)?.location {
            controller.location = location
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController?.sections?[section] else {
            return 0
        }
        
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationItem", for: indexPath)
        
        if let type = fetchedResultsController?.object(at: indexPath) {
            cell.textLabel?.text = type.name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showMapLocations(forIndexPath: indexPath)
    }
    
    /**
     
     */
    func showMapLocations(forIndexPath indexPath: IndexPath) {
        mapView.removeAnnotations(mapView.annotations)
        
        guard let locations = fetchedResultsController?.object(at: indexPath).locations?.allObjects as? [Location] else {
            print("unable to access location list")
            return
        }
        
        showMapAnnotations(locations: locations)
        
        let region = regionForLocations(locations: locations)
        mapView.setRegion(region, animated: true)
        mapView.regionThatFits(region)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "iosdevukLocation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        }
        
        if let annotation = annotation as? Annotation {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            imageView.displayImage(named: annotation.identifier, withDefault: "LocationPin")
            imageView.addBorderWithCorner()
            annotationView!.leftCalloutAccessoryView = imageView
        }
            
        annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        annotationView!.annotation = annotation
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "mapToLocationDetailSegue", sender: view)
    }
    
    /**
     
     - Parameters:
     - locations: a list of locations that need to be displayed on the map
     */
    func regionForLocations(locations: [Location]) -> MKCoordinateRegion {
        
        let box = createBoundingCoordinatesAroundLocations(locations: locations)
        
        let averageLatitude = (box.minimum.latitude + box.maximum.latitude) / 2
        let averageLongitude = (box.minimum.longitude + box.maximum.longitude) / 2
        
        let center = CLLocation(latitude: averageLatitude, longitude: averageLongitude)
        
        let southCentrePoint = CLLocation(latitude: box.minimum.latitude, longitude: center.coordinate.longitude)
        let eastCentrePoint = CLLocation(latitude: center.coordinate.latitude, longitude: box.maximum.longitude)
        
        return MKCoordinateRegionMakeWithDistance(center.coordinate, center.distance(from: southCentrePoint) + 1000, center.distance(from: eastCentrePoint) + 1000)
    }
    
    /**
     
     */
    func showMapAnnotations(locations: [Location]) {
        for location in locations {
            let annotation = Annotation(location: location)
            mapView.addAnnotation(annotation)
        }
    }
    
    /**
     Creates a pair of coordinates that refer to the minimum and maximum points for a bounding box.
     
     - Parameters:
     - locations: List of locations that should be shown in this box
     */
    func createBoundingCoordinatesAroundLocations(locations: [Location]) -> (minimum: CLLocationCoordinate2D, maximum: CLLocationCoordinate2D) {
        
        var minimum = CLLocationCoordinate2D()
        var maximum = CLLocationCoordinate2D()
        
        for location in locations {
            
            //print("Location \(String(describing: location.name)) \(location.latitude) \(location.longitude)")
            
            let latitude = location.latitude
            let longitude = location.longitude
            
            if minimum.latitude == 0 || minimum.latitude > latitude {
                minimum.latitude = latitude
            }
            
            if maximum.latitude == 0 || maximum.latitude < latitude {
                maximum.latitude = latitude
            }
            
            if minimum.longitude == 0 || minimum.longitude > longitude {
                minimum.longitude = longitude
            }
            
            if maximum.longitude == 0 || maximum.longitude < longitude {
                maximum.longitude = longitude
            }
        }
        
        return (minimum, maximum)
    }
    
    /**
     Responds to changes in the segmented control and updates the map display.
     
     - Parameters:
     - sender: The object that called this action
     */
    @IBAction func mapTypeSelectionChanged(sender: Any) {
        mapView.mapType = (mapTypes.selectedSegmentIndex == 0) ? .hybrid : .standard
    }
    
}
