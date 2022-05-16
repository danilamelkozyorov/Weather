//
//  Extensions.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 09.05.2022.
//

import UIKit

extension String {
    func deletingPrefixFromTimezone() -> String {
        let newString = self.components(separatedBy: "/")
        return newString[1]
    }
    
    func deletingDashFromText() -> String {
        self.replacingOccurrences(of: "_", with: " ")
    }
}

extension Date {
    func getTimeForDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    func getHourForDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter.string(from: self)
    }
    
    func getDayForDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
}

extension UIImageView {
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
    
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.image = image
            }
        }.resume()
    }
}

extension MainViewController {
    func alertAddCity(name: String, placeholder: String, completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: name, message: nil, preferredStyle: .alert)
        
        let alertOK = UIAlertAction(title: "OK", style: .default) { (action) in
            let textField = alertController.textFields?.first
            guard let text = textField?.text else { return }
            completion(text)
        }
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(alertOK)
        alertController.addAction(alertCancel)
        alertController.addTextField { textField in
            textField.placeholder = placeholder
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
