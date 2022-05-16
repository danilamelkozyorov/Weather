//
//  HourlyCollectionViewCell.swift
//  Weather
//
//  Created by Мелкозеров Данила on 05.05.2022.
//

import UIKit

struct HourlyCollectionViewCellViewModel {
    let tempLabelString: String?
    let timeLabelString: String?
    let humidityLabelString: String?
    let urlString: String?
}

final class HourlyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var tempLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    static let identifier = "HourlyCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "HourlyCollectionViewCell",
                     bundle: nil)
    }
    
    override func prepareForReuse() {
        timeLabel.font = nil
        tempLabel.font = nil
        humidityLabel.text = nil
        iconImageView.image = nil
    }
    
    func setupCell(_ model: HourlyCollectionViewCellViewModel) {
        if model.timeLabelString == "Now" {
            timeLabel.text = "Now"
            timeLabel.font = UIFont.boldSystemFont(ofSize: 17)
            tempLabel.text = model.tempLabelString
            tempLabel.font = UIFont.boldSystemFont(ofSize: 17)
        } else {
            timeLabel.text = model.timeLabelString
            tempLabel.text = model.tempLabelString
        }
        iconImageView.downloaded(from: model.urlString ?? "")
        humidityLabel.text = model.humidityLabelString
    }
    
}
