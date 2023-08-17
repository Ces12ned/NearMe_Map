//
//  Annotations.swift
//  NearMeMap
//
//  Created by Edgar Cisneros on 21/07/23.
//

import UIKit
import MapKit
import Combine


class PlaceAnnotation: MKPointAnnotation{
    
    let mapItem: MKMapItem
    let id = UUID()
    var isSelected: Bool = false
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        super.init()
        self.coordinate = mapItem.placemark.coordinate
    }
    
    var name: String {
        mapItem.name ?? ""
    }
    var phone: String {
        mapItem.phoneNumber ?? ""
    }
    var location: CLLocation {
        mapItem.placemark.location ?? CLLocation.default
    }
    

    
}


