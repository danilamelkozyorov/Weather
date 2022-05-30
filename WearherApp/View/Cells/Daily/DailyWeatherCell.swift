//
//  DailyWeatherCell.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 09.05.2022.
//

import UIKit

final class DailyWeatherCell: UITableViewCell {

    @IBOutlet private weak var dayLabel: UILabel!
    @IBOutlet private weak var humidityImageView: UIImageView!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var tempDayLabel: UILabel!
    @IBOutlet private weak var tempNightLabel: UILabel!
    
    static let identifier = "DailyWeatherCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        humidityImageView.image = nil
    }
    
    static func nib() -> UINib {
        UINib(nibName: "DailyWeatherCell", bundle: nil)
    }
    
    func configure(model: Daily) {
        dayLabel.text = Date(timeIntervalSince1970: Double(model.dt)).getDayForDate()
        tempNightLabel.text = String(format: "%.f", model.temp?.night ?? 0) + "°"
        tempDayLabel.text = String(format: "%.f", model.temp?.day ?? 0) + "°"
        // if humidity is less than 20% set value empty text
        if model.humidity >= 20 {
            humidityLabel.text = String(model.humidity) + " %"
        } else {
            humidityLabel.text = ""
        }
        humidityImageView.downloaded(from: APIManager.shared.getWeatherImageURL(icon: model.weather?[0].icon ?? ""))
    }
}
