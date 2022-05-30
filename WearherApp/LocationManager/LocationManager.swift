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
        name: String,
        completion: @escaping (CLLocationCoordinate2D?, String?, WeatherErrors?) -> Void
    ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?.first {
                    guard let location = placemark.location else { return }
                    geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "en_EN")) { placemark, error in
                        guard let placemark = placemark, error == nil else { return }
                        let cityName = placemark.first?.locality
                        completion(location.coordinate, cityName, nil)
                    }
                    return
                }
            } else {
                completion(nil, nil, WeatherErrors.getCoordinateFail)
            }
        }
    }
    
    func getCityName(
        longitude: Double,
        latitude: Double,
        completion: @escaping (String?, WeatherErrors?) -> Void
    ) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "en_EN")) { placemarks, error in
            if error == nil {
                guard let placemark = placemarks?.first else { return }
                completion(placemark.locality, nil)
                return
            } else {
                completion(nil, WeatherErrors.getCityNameFail)
            }
        }
    }
}
