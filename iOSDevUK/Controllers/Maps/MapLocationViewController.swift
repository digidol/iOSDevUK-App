//
//  MapLocationViewController.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 16/08/2016.
//  Copyright © 2016 Aberystwyth University. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

/**
 Shows one of the iOSDevUK locations on the a map view. 
 */
class MapLocationViewController: UIViewController, MKMapViewDelegate, SFSafariViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var showWebsiteButton: UIButton!
    
    var location: IDULocation? {
        didSet {
            initialiseView()
        }
    }
    
    func initialiseView() {
        if let location = self.location {
            if self.mapView != nil {
                self.mapView.showsCompass = true
                self.mapView.showsBuildings = true
                self.mapView.pointOfInterestFilter = MKPointOfInterestFilter.includingAll
                self.mapView.delegate = self
                
                showLocation(location)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // In case this is the first time showing a map screen
        // request permission to use the user's location
        CLLocationManager().requestWhenInUseAuthorization()
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
        performSegue(withIdentifier: "singleLocationDetailSegue", sender: view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? LocationViewController,
            let location = ((sender as? MKAnnotationView)?.annotation as? Annotation)?.location {
            controller.location = location
        }
    }
    
    /**
    Shows the specified location on the map.
     */
    func showLocation(_ location: IDULocation) {
        mapView.mapType = .hybrid
        
        let annotation = Annotation(location: location)
        
        
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude,
                                                longitude: location.longitude)
        
        // Add the relevant annotations to the map
        self.mapView.addAnnotation(annotation)
        self.mapView.selectAnnotation(annotation, animated: true)
        
        let boundingRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 300)
        self.mapView.setRegion(boundingRegion, animated: false)
        self.mapView.regionThatFits(boundingRegion)
    }

    /**
     Called when the map type segmented control is changed. 
     */
    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .hybrid
        }
        else {
            mapView.mapType = .standard
        }
    }
    
    func mapTypeValue() -> UInt {
        if mapTypeSegmentedControl.selectedSegmentIndex == 0 {
            return MKMapType.hybrid.rawValue
        }
        else {
            return MKMapType.standard.rawValue
        }
    }
    
    /**
     Show this location in Apple's Map application.
     */
    @IBAction func showInMaps(_ sender: AnyObject) {
        
        let coordinate = CLLocationCoordinate2D(latitude: location!.latitude,
                                                longitude: location!.longitude)
        
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location!.name
        
        
        let boundingRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 300)
        let launchOptions: [String:AnyObject] = [
            MKLaunchOptionsMapTypeKey: mapTypeValue() as AnyObject,
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: boundingRegion.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: boundingRegion.span)
            ]
        
        MKMapItem.openMaps(with: [mapItem], launchOptions: launchOptions)
        
    }
    
    @IBAction func showWebsite(_ sender: AnyObject) {
        if let url = location?.webLink?.url {
            let webViewController = SFSafariViewController(url: url)
            webViewController.delegate = self
            self.present(webViewController, animated: true, completion: nil)
        }
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
