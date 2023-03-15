//
//  WeatherTableViewSection.swift
//  WeatherApp
//
//  Created by Мелкозеров Данила on 10.05.2022.
//

import UIKit

enum WeatherDetailTableViewSection: Int {
    static let numberOfSection = 2
    
    case hourly = 0
    case daily = 1
    
    init?(sectionIndex: Int) {
        guard let section = WeatherDetailTableViewSection(rawValue: sectionIndex) else { return nil }
        self = section
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .hourly:
            return CGFloat(120)
        case .daily:
            return CGFloat(70)
        }
    }
}

enum WeatherListTableViewSection: Int {
    static let numberOfSection = 2
    
    case currentLocation = 0
    case favorite = 1
    
    init?(sectionIndex: Int) {
        guard let section = WeatherListTableViewSection(rawValue: sectionIndex) else { return nil }
        self = section
    }
    
    var sectionHeaderText: String {
        switch self {
        case .currentLocation:
            return "current location"
        case .favorite:
            return "favorite"
        }
    }
}
