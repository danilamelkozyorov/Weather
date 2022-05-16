//
//  NetworkManager.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 05.05.2022.
//

import Foundation
import CoreLocation

struct NetworkManager {
    
    func fetchWeather(longitude: CLLocationDegrees, latitude: CLLocationDegrees, completion: @escaping (WeatherModel) -> Void) {
        
        let urlString = APIManager.shared.getLocationCurrentWeatherURL(latitude: latitude, longitude: longitude)

        guard let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            do {
                let weather = try JSONDecoder().decode(WeatherModel.self, from: data)
                DispatchQueue.main.async {
                    completion(weather)
                }
            }
            catch let jsonError {
                print("Failed to decode frome JSON", jsonError)
            }
        }.resume()
    }
    
    func getCitiesName(text: String, completion: @escaping ([Place]) -> Void) {
        let urlString = APIManager.shared.autoCompleteAPIString + text
        
        guard let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data,_,_ in
            guard let data = data else { return }
            do {
                let places = try JSONDecoder().decode([Place].self, from: data)
                DispatchQueue.main.async {
                    completion(places)
                }
            }
            catch let jsonError {
                print("Failed to decode frome JSON", jsonError)
            }
        }.resume()
    }
}
