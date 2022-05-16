//
//  WeatherModel.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 05.05.2022.
//

import Foundation

// MARK: - Weather
struct WeatherModel: Decodable {
    let lat, lon: Double
    let timezone: String
    let current: Current?
    let hourly: [Current]?
    let daily: [Daily]?
    lazy var cityName: String = {
        timezone.deletingPrefixFromTimezone()
    }()

    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone
        case current, hourly, daily
    }
}

// MARK: - Current
struct Current: Decodable {
    let dt, sunrise, sunset: Int?
    let temp, feelsLike: Double
    let humidity: Int
    let weather: [WeatherElement]?

    enum CodingKeys: String, CodingKey {
        case temp, dt, sunrise, sunset
        case feelsLike = "feels_like"
        case humidity
        case weather
    }
}

// MARK: - WeatherElement
struct WeatherElement: Decodable {
    let main: Main?
    let weatherDescription: Description?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case main
        case weatherDescription = "description"
        case icon
    }
}
 
enum Main: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
    case snow = "Snow"
    case mist = "Mist"
    case fog = "Fog"
    case haze = "Haze"

}

enum Description: String, Codable {
    case brokenClouds = "broken clouds"
    case fog = "fog"
    case haze = "haze"
    case clearSky = "clear sky"
    case fewClouds = "few clouds"
    case lightRain = "light rain"
    case moderateRain = "moderate rain"
    case overcastClouds = "overcast clouds"
    case scatteredClouds = "scattered clouds"
    case heavyIntensityRain = "heavy intensity rain"
    case rainAndSnow = "rain and snow"
}

// MARK: - Daily
struct Daily: Decodable {
    let dt: Int
    let temp: Temp?
    let feelsLike: FeelsLike?
    let humidity: Int
    let weather: [WeatherElement]?

    enum CodingKeys: String, CodingKey {
        case dt
        case temp
        case feelsLike = "feels_like"
        case humidity
        case weather
    }
}

// MARK: - FeelsLike
struct FeelsLike: Decodable {
    let day, night: Double?
}

// MARK: - Temp
struct Temp: Decodable {
    let day, night: Double?
}

