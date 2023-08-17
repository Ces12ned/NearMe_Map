//
//  LocationSearchViewModel.swift
//  NearMeMap
//
//  Created by Edgar Cisneros on 21/07/23.
//

import UIKit
import MapKit
import Combine


class LocationSearchViewModel: NSObject{
    
    let searchTextField = UITextField()
    private var cancellables: Set<AnyCancellable> = []
    @Published var searchText: String?
    @Published var places = [PlaceAnnotation]()
    
    override init() {
        super.init()
        searchTextField.delegate = self
    }
    
    private func findNearbyPlaces(by query: String){
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        LocationManager().$region.sink{ region in
            guard let region = region else {return}
            request.region = region
        }.store(in: &cancellables)
      
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response,
                  error == nil else {return}
            self.places = response.mapItems.map(PlaceAnnotation.init)
        }
        
    }
}

extension LocationSearchViewModel: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchText = textField.text ?? ""
        
        guard let searchText = searchText else {return false}
        if !searchText.isEmpty{
            textField.resignFirstResponder()
            findNearbyPlaces(by: searchText)
        }
        return true
    }
}
