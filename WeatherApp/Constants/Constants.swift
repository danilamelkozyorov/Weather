//
//  Constants.swift
//  WeatherApp
//
//  Created by Мелкозеров Данила on 16.05.2022.
//

import Foundation
import UIKit

struct OpenWeatherAPI {
    let scheme = "https"
    let host = "api.openweathermap.org"
    let path = "/data/2.5"
    let key = "26899d76bc1ec6c2e91a75cdb92932fe"
}

enum WeatherErrors: Error {
    case connectionLost
    case jsonDecodeFail
    case incorrectURL
    case getCoordinateFail
    case getCityNameFail
    case isInsertedBefore
    case addInformation
    
    public var description: String {
        switch self {
        case .connectionLost:
            return "Oops... Internet problem, check your connection"
        case .jsonDecodeFail:
            return "Can't get weather information, please contact your developers"
        case .incorrectURL:
            return "Incorrect URL, change keyboard language to EN and try again"
        case .getCoordinateFail:
            return "Can't get coordinates, check your geoposition services"
        case .getCityNameFail:
            return "Can't get name of City, check your geoposition services"
        case .isInsertedBefore:
            return "Chosen City already added to list of your favourites"
        case .addInformation:
            return "You add City to list of your favourites"
        }
    }
}
