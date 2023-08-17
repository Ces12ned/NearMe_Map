//
//  PlaceDetailViewController.swift
//  NearMeMap
//
//  Created by Edgar Cisneros on 22/07/23.
//

import UIKit
import MapKit
import Combine

class PlaceDetailViewController: UIViewController {
    
    //MARK: - UI Objects
    
    let nameLabel : UILabel = {
        let name = UILabel()
        name.font = UIFont(name: "Futura", size: 38)
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textColor = .black
        name.textAlignment = .left
        name.numberOfLines = 0
        return name
    }()
    
    let phoneButton : UIButton = {
        let phone = UIButton()
        phone.titleLabel?.font = UIFont(name: "Futura", size: 20)
        phone.setTitleColor(.black, for: .normal)
        phone.titleLabel?.textAlignment = .center
        phone.translatesAutoresizingMaskIntoConstraints = false
        phone.clipsToBounds = true
        phone.layer.cornerRadius = 18
        phone.layer.borderColor = UIColor(red: 0, green: 128/255, blue: 0, alpha: 1).cgColor
        phone.layer.borderWidth = 2
        phone.setImage(UIImage(systemName: "phone"), for: .normal)
        phone.tintColor = UIColor(red: 0, green: 128/255, blue: 0, alpha: 1)
        return phone
    }()
    
    
    private var mapView: MKMapView = {
        
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 12
        return mapView
    }()
    
    
    
    //MARK: - Properties & Initializers
    
    let placeDetails: PlaceAnnotation
    
    private var locationManager: LocationManager?
    private var locationSearchViewModel: LocationSearchViewModel?
    private var cancellables: Set<AnyCancellable> = []
    
    init(placeDetails: PlaceAnnotation) {
        self.placeDetails = placeDetails
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        locationManager = LocationManager()
        configureNameLabel()
        configurePhoneButton()
        configureMapView()
    }
    
    
    //MARK: - Methods
    
    private func configureNameLabel(){
        
        view.addSubview(nameLabel)
        nameLabel.text = placeDetails.name
        setNameLabelConstraints()
    }
    
    private func setNameLabelConstraints(){
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor , constant: 60),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor , constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            nameLabel.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func configurePhoneButton(){
        
        view.addSubview(phoneButton)
        phoneButton.setTitle(placeDetails.phone.isEmpty ? "No phone available" : placeDetails.phone, for: .normal)
        setPhoneButtonConstraints()
        
    }
    
    private func setPhoneButtonConstraints(){
        
        NSLayoutConstraint.activate([
            phoneButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor , constant: 12),
            phoneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor , constant: 12),
            phoneButton.widthAnchor.constraint(equalToConstant: view.frame.width/1.5),
            phoneButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }


    private func configureMapView(){
        
        view.addSubview(mapView)
        mapView.delegate = self
        locationManager?.$region.sink{[weak self] region in
            guard let region = region else {return}
            self?.mapView.setRegion(region, animated: true)
            self?.mapView.addAnnotation(self!.placeDetails)
            self?.mapView.showAnnotations(self!.mapView.annotations, animated: true)
            self?.locationManager?.configurePolyline(in: self!.mapView, with: self!.placeDetails.coordinate )
        }.store(in: &cancellables)

        setMapViewConstraints()
    }
    
    
    private func setMapViewConstraints(){
        
        NSLayoutConstraint.activate([
            
            mapView.topAnchor.constraint(equalTo: phoneButton.bottomAnchor , constant: 42),
            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor , constant: 12),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            mapView.heightAnchor.constraint(equalToConstant: view.frame.height/2)
        ])
    }


}


extension PlaceDetailViewController: MKMapViewDelegate{
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polyline = MKPolylineRenderer(overlay: overlay)
        
        polyline.strokeColor = .systemBlue
        polyline.lineWidth = 6
        return polyline
    }
}


