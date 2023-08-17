//
//  PlacesTableViewController.swift
//  NearMeMap
//
//  Created by Edgar Cisneros on 21/07/23.
//

import UIKit
import MapKit

class PlacesTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    var userLocation: CLLocation
    var places: [PlaceAnnotation]
    
    private var indexForSelectedRow: Int? {
        self.places.firstIndex(where: {$0.isSelected == true})
    }
    
    //MARK: - Init
    
    init(userLocation: CLLocation, places: [PlaceAnnotation]) {
        self.userLocation = userLocation
        self.places = places

        super.init(nibName: nil, bundle: nil)
        
        DispatchQueue.main.async {
            self.places.swapAt(self.indexForSelectedRow ?? 0, 0)
            self.tableView.reloadData()
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Methods
    
    private func calculateDistance (from: CLLocation, to: CLLocation) -> CLLocationDistance {
        from.distance(from: to) / 1000
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let placeCell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        
        let place = places[indexPath.row]
        
        var content = placeCell.defaultContentConfiguration()
        
        content.text = place.name
        content.secondaryText = String(format: "%.2f" ,calculateDistance(from: userLocation, to: place.location)) + "km"
        
        placeCell.contentConfiguration = content
        placeCell.backgroundColor = place.isSelected ? UIColor.lightGray : UIColor.clear
        
        return placeCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let place = places[indexPath.row]
        
        
        self.show(PlaceDetailViewController(placeDetails: place), sender: self)
        
        
    }
    
    
    
    
}
