//
//  AllLocationsMapViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 08/08/2017.
//  Copyright © 2017-2022s Aberystwyth University. All rights reserved.
//

import UIKit
import MapKit

class AllLocationsMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    /// Types of location that are shown in the table
    var locationTypes: [IDULocationType]?
    
    /** The map on display. */
    @IBOutlet var mapView: MKMapView!
    
    /// The segmented control that determine if satellite view is shown
    @IBOutlet var mapTypes: UISegmentedControl!
    
    /// Table of categories that can be shown on the map
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: path, animated: true, scrollPosition: .none)
        showMapLocations(forIndexPath: path)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // In case this is the first time showing a map screen
        // request permission to use the user's location
        CLLocationManager().requestWhenInUseAuthorization()
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
        return locationTypes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationItem", for: indexPath)
        
        if let locationType = locationTypes?[indexPath.row] {
            cell.textLabel?.text = locationType.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showMapLocations(forIndexPath: indexPath)
    }
    
    func showMapLocations(forIndexPath indexPath: IndexPath) {
        mapView.removeAnnotations(mapView.annotations)
        
        guard let locations = locationTypes?[indexPath.row].locations else {
            print("Unable to access list of locations")
            return
        }
        
        showMapAnnotations(locations: locations)
        
        let region = regionForLocations(locations: locations)
        mapView.setRegion(region, animated: true)
        mapView.regionThatFits(region)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Avoid overriding the user's location annotation view, use the default
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let identifier = "iosdevukLocation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        }
        
        if let annotation = annotation as? Annotation {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            imageView.displayImage(named: annotation.identifier, inCategory: .locations, withDefault: "LocationPin")
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
    func regionForLocations(locations: [IDULocation]) -> MKCoordinateRegion {
        
        let box = createBoundingCoordinatesAroundLocations(locations: locations)
        
        let averageLatitude = (box.minimum.latitude + box.maximum.latitude) / 2
        let averageLongitude = (box.minimum.longitude + box.maximum.longitude) / 2
        
        let center = CLLocation(latitude: averageLatitude, longitude: averageLongitude)
        
        let southCentrePoint = CLLocation(latitude: box.minimum.latitude, longitude: center.coordinate.longitude)
        let eastCentrePoint = CLLocation(latitude: center.coordinate.latitude, longitude: box.maximum.longitude)
        
        return MKCoordinateRegion.init(center: center.coordinate, latitudinalMeters: center.distance(from: southCentrePoint) + 1000, longitudinalMeters: center.distance(from: eastCentrePoint) + 1000)
    }
    
    /**
     
     */
    func showMapAnnotations(locations: [IDULocation]) {
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
    func createBoundingCoordinatesAroundLocations(locations: [IDULocation]) -> (minimum: CLLocationCoordinate2D, maximum: CLLocationCoordinate2D) {
        
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
