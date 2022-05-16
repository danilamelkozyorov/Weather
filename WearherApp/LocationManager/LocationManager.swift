//
//  LocationManager.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 14.05.2022.
//

import Foundation
import CoreLocation

class LocationManager {
    static let shared = LocationManager()
    
    private init() {}

    func getCoordinate(
        name : String,
        completion: @escaping (CLLocationCoordinate2D, NSError?) -> Void
    ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    guard let location = placemark.location else { return }
                    completion(location.coordinate, nil)
                    return
                }
            }
            completion(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
}
