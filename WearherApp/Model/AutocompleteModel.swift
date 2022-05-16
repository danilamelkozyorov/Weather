//
//  AutocompleteModel.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 12.05.2022.
//

import Foundation

// MARK: - Place
struct Place: Decodable {
    let name: String?
    let coordinates: Coordinates?
}

// MARK: - Coordinates
struct Coordinates: Decodable {
    let lon, lat: Double?
}

