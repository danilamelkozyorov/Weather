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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
        if model.humidity >= 30 {
            humidityLabel.text = String(model.humidity) + " %"
        } else {
            humidityLabel.text = ""
        }
        let urlString = "https://openweathermap.org/img/wn/\(model.weather?[0].icon ?? "")@2x.png"
        humidityImageView.downloaded(from: urlString)
    }
}
