//
//  WeatherMapViewController.swift
//  WeatherApp
//
//  Created by Мелкозеров Данила on 21.05.2022.
//

import UIKit
import MapKit

final class WeatherMapViewController: UIViewController {
    
    private let mapView = MKMapView()
    
    var place: WeatherModel?
    
    weak var delegate: WeatherMapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureMapView()
        setupPlacemark()
    }
    
    private func configureView() {
        view.backgroundColor = .secondarySystemBackground
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        setMapViewConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    private func setMapViewConstraints() {
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupPlacemark() {
        guard let cityName = place?.cityName,
              let temp = self.place?.current?.temp else {
            return Alert.shared.inform(
                title: "Connection problem",
                message: WeatherErrors.connectionLost.description,
                viewController: self
            )
        }
        
        LocationManager.shared.getCoordinate(name: cityName) { [weak self] coordinate, city, error in
            guard let strongSelf = self,
                  let coordinate = coordinate,
                  let city = city,
                  error == nil else {
                guard let self = self else { return }
                return Alert.shared.inform(
                    title: "Connection problem",
                    message: error?.description ?? "",
                    viewController: self
                )
            }
            
            let annotation = MKPointAnnotation()
            annotation.title = city
            annotation.subtitle = String(Int(temp)) + "°"
            annotation.coordinate = coordinate
            
            strongSelf.place?.cityName = city
            strongSelf.mapView.addAnnotation(annotation)
            strongSelf.mapView.setRegion(
                MKCoordinateRegion(
                    center: annotation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
                ),
                animated: true
            )
        }
    }
    
    private func addAnnotation(location: CLLocationCoordinate2D, temp: Double) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = place?.cityName
        annotation.subtitle = String(Int(temp))
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
        }
    }
    
    @objc func tap(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            mapView.removeAnnotations(mapView.annotations)
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            LocationManager.shared.getCityName(longitude: locationOnMap.longitude, latitude: locationOnMap.latitude) { cityName, error in
                guard let cityName = cityName, error == nil else {
                    return
                }
                self.place?.cityName = cityName
            }
            
            NetworkManager.shared.fetchWeather(longitude: locationOnMap.longitude, latitude: locationOnMap.latitude) { [weak self] weather, error in
                guard let strongSelf = self else { return }
                strongSelf.addAnnotation(
                    location: locationOnMap,
                    temp: weather?.current?.temp ?? 0
                )
            }
        }
    }
}

extension WeatherMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.isEnabled = true
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach({$0.isSelected = true})
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .contactAdd)
        }
        else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            guard let coordinate = mapView.annotations.first?.coordinate else {
                return
            }
            if CoreDataManager.shared.isInsertedBefore(name: place?.cityName ?? "") {
                Alert.shared.inform(
                    title: place?.cityName ?? "",
                    message: WeatherErrors.isInsertedBefore.description,
                    viewController: self
                )
            } else {
                delegate?.didAddPlace(with: coordinate, with: place?.cityName ?? "")
                CoreDataManager.shared.insertCityToRepository(name: place?.cityName ?? "")
                Alert.shared.inform(
                    title: place?.cityName ?? "",
                    message: WeatherErrors.addInformation.description,
                    viewController: self
                )
            }
        }
    }
}
