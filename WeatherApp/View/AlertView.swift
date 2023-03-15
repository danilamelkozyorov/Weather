//
//  AlertController.swift
//  WeatherApp
//
//  Created by Мелкозеров Данила on 18.05.2022.
//

import Foundation
import UIKit

class Alert {
    static let shared = Alert()
    
    func inform(title: String, message: String, viewController: UIViewController) {
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true)
    }
}
