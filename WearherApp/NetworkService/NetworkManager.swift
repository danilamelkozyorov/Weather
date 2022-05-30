//
//  NetworkManager.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 05.05.2022.
//

import Foundation
import CoreLocation

class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchWeather(longitude: CLLocationDegrees, latitude: CLLocationDegrees, completion: @escaping (WeatherModel?, WeatherErrors?) -> Void) {
        
        let urlString = APIManager.shared.getLocationCurrentWeatherURL(latitude: latitude, longitude: longitude)
        guard let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else { return completion(nil, .connectionLost) }
            do {
                let weather = try JSONDecoder().decode(WeatherModel.self, from: data)
                DispatchQueue.main.async {
                    completion(weather, error as? WeatherErrors)
                }
            }
            catch {
                print(error)
                completion(nil, .jsonDecodeFail)
            }
        }.resume()
    }
    
    func getCitiesName(text: String, completion: @escaping ([Place]?, WeatherErrors?) -> Void) {
        let urlString = APIManager.shared.autoCompleteAPIString + text
        guard let url = URL(string: urlString) else {
            return completion(nil, WeatherErrors.incorrectURL)
        }
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else { return completion(nil, .connectionLost) }
            do {
                let places = try JSONDecoder().decode([Place].self, from: data)
                DispatchQueue.main.async {
                    completion(places, error as? WeatherErrors)
                }
            }
            catch {
                completion(nil, .jsonDecodeFail)
            }
        }.resume()
    }
}
