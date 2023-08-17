//
//  HomeMapViewController.swift
//  NearMeMap
//
//  Created by Edgar Cisneros on 21/07/23.
//

import UIKit
import MapKit
import Combine

class HomeMapViewController: UIViewController {
    //MARK: - Properties
    
    private var locationManager: LocationManager?
    private var locationSearchViewModel: LocationSearchViewModel?
    private var cancellables: Set<AnyCancellable> = []

    private var mapView: MKMapView = {
        
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.userTrackingMode = .follow
        return mapView
    }()
    
    
    private lazy var searchTextField: UITextField = {
       
        let searchTextField = UITextField()
        searchTextField.layer.cornerRadius = 12
        searchTextField.clipsToBounds = true
        searchTextField.placeholder = "Search"
        searchTextField.backgroundColor = .systemBackground
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        searchTextField.leftViewMode = .always
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.returnKeyType = .go
        return searchTextField
    }()
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = LocationManager()
        locationSearchViewModel = LocationSearchViewModel()
        configureMapView()
        configureSearchTextField()
    }

    //MARK: - Methods

    private func configureMapView(){
        
        view.addSubview(mapView)
        mapView.delegate = self
        locationManager?.$region.sink{[weak self] region in
            guard let region = region else {return}
            self?.mapView.setRegion(region, animated: true)
        }.store(in: &cancellables)
        
        locationSearchViewModel?.$places.sink {[weak self] places in
            DispatchQueue.main.async {
                places.forEach { place in
                    place.title = place.name
                    self?.mapView.addAnnotation(place)
                }
            }
            self?.presentPlacesSheet(places: places)
        }.store(in: &cancellables)
        
        
        setMapViewConstraints()
    }
    
    
    private func setMapViewConstraints(){
        
        NSLayoutConstraint.activate([
            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mapView.widthAnchor.constraint(equalToConstant: view.frame.width),
            mapView.heightAnchor.constraint(equalToConstant: view.frame.height)
        ])
    }
    
    
    private func configureSearchTextField(){
        view.addSubview(searchTextField)
        searchTextField.delegate = locationSearchViewModel?.searchTextField.delegate
        
        
        setSearchTextFieldConstraints()
        
        locationSearchViewModel?.$searchText.sink{[weak self] searchText in
            if let _ = searchText {
                    self?.mapView.removeAnnotations((self?.mapView.annotations)!)
            }
        }.store(in: &cancellables)
    }
    
    
    private func setSearchTextFieldConstraints(){
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width/1.2),
            searchTextField.heightAnchor.constraint(equalToConstant: 45),
            searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    
    private func presentPlacesSheet(places: [PlaceAnnotation]){

        guard let userLocation = locationManager?.locationManager.location else {return}

        let placesTVC = PlacesTableViewController(userLocation: userLocation, places: places)
        placesTVC.modalPresentationStyle = .pageSheet
        if let sheet = placesTVC.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [ .medium() , .large()]
            present(placesTVC, animated: true)
        }
    }
 
    private func clearAllSelections(){
        
        locationSearchViewModel?.places = (locationSearchViewModel?.places.map({ place in
            place.isSelected = false
            return place
        }))!
    }
    
}

extension HomeMapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        
        clearAllSelections()
        
        guard let selectedAnnotation =  annotation as? PlaceAnnotation,
              let places = locationSearchViewModel?.places else {return}
        
        let placeAnnotation = places.first {
            $0.id == selectedAnnotation.id
        }
        placeAnnotation?.isSelected = true

        self.presentPlacesSheet(places: places)
        
        
    }
    
}

