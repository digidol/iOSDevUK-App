//
//  Annotation.swift
//  iOSDevUK
//
//  Created by Neil Taylor on 08/08/2017.
//  Copyright © 2017 Aberystwyth University. All rights reserved.
//

import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation {
    
    var identifier: String!
    
    var locationDescription: String!
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    var subtitle: String?
    
    var location: Location
    
    init(location: Location) {
        identifier = location.recordName!
        locationDescription = location.note!
        coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        title = location.name!
        self.location = location
    }
}
