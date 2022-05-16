//
//  APIManager.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 15.05.2022.
//

import Foundation
import CoreLocation

class APIManager {
    static let shared = APIManager()
        
    private init() {}
    
    let autoCompleteAPIString = "https://autocomplete.travelpayouts.com/places2?locale=en&types[]=city&term="

    func getLocationCurrentWeatherURL(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> String {
        var components = URLComponents()
        components.scheme = OpenWeatherAPI().scheme
        components.host = OpenWeatherAPI().host
        components.path = OpenWeatherAPI().path + "/onecall"
        components.queryItems = [URLQueryItem(name: "lat", value: String(latitude)),
                                 URLQueryItem(name: "lon", value: String(longitude)),
                                 URLQueryItem(name: "exclude", value: "minutely"),
                                 URLQueryItem(name: "units", value: "metric"),
                                 URLQueryItem(name: "appid", value: OpenWeatherAPI().key)]
        guard let componentsString = components.string else { return "" }
        return componentsString
    }
}
