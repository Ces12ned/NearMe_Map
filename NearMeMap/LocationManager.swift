//
//  LocationManager.swift
//  NearMeMap
//
//  Created by Edgar Cisneros on 21/07/23.
//

import UIKit
import MapKit
import Combine

class LocationManager: NSObject{
    
    let locationManager = CLLocationManager()
    static let shared = LocationManager()
    @Published var region : MKCoordinateRegion?
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorazation()
    }
    
    
    
    private func checkLocationAuthorazation(){
        
        guard let location = locationManager.location else {return}
        
        switch locationManager.authorizationStatus{
            
        case .authorizedWhenInUse, .authorizedAlways:
            
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
            
        case .notDetermined, .restricted:
            print("Location cannot be determined or restricted.")
        case .denied:
            print ("Location services has been denied.")
        @unknown default:
            print ("Unknown error. Unable to get location.")
            
        }
        
    }
    
    func configurePolyline(in mapView: MKMapView, with destinationCoordinate: CLLocationCoordinate2D){
        
        
        guard let userLocationCoordinate = locationManager.location?.coordinate else {return}
        
        getDestinationRoute(from: userLocationCoordinate, to: destinationCoordinate) { route in
            
            mapView.addOverlay(route.polyline)
            let rect = mapView.mapRectThatFits(route.polyline.boundingMapRect, edgePadding: .init(top: 64, left: 64, bottom: 64, right: 64))
            
            mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
    }
    
    
    func getDestinationRoute(from userLocation: CLLocationCoordinate2D,
                             to destination: CLLocationCoordinate2D,
                             completion: @escaping (MKRoute)-> Void){
        
        
        let userPlaceMark = MKPlacemark(coordinate: userLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlaceMark)
        request.destination = MKMapItem(placemark: destinationPlaceMark)
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if let error = error{
                print("Failed to get directions \(error.localizedDescription)")
                return
            }
            
            guard let route = response?.routes.first else {return}
            completion(route)
        }
    }
    
}


