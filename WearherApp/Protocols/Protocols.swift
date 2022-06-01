//
//  Protocols.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 01.06.2022.
//

import Foundation
import CoreLocation

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapPlace(with coordinates: Coordinates)
}

protocol WeatherMapViewControllerDelegate: AnyObject {
    func didAddPlace(with coordinate: CLLocationCoordinate2D?, with cityName: String)
}
