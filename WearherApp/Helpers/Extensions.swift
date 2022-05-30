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
        let cacheImage = NSCache<NSString, UIImage>()
        if let cachedImage = cacheImage.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
        } else {
            contentMode = mode
            URLSession.shared.dataTask(with: url ) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                else { return }
                cacheImage.setObject(image, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    self.image = image
                }
            }.resume()
        }
    }
}

