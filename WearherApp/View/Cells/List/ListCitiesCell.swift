//
//  ListCitiesCell.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 05.05.2022.
//

import UIKit

final class ListCitiesCell: UITableViewCell {
    
    @IBOutlet private weak var tempLabel: UILabel!
    @IBOutlet private weak var overcastLabel: UILabel!
    @IBOutlet private weak var currentPlaceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .systemGray5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static let identifier = "ListCitiesCell"
    
    static func nib() -> UINib {
        UINib(nibName: "ListCitiesCell", bundle: nil)
    }
    
    func configure(with model: WeatherModel) {
        guard let overcast = model.current?.weather else { return }
        self.tempLabel.text = String(Int(model.current?.temp ?? 0))
        self.overcastLabel.text = overcast[0].main?.rawValue
        self.currentPlaceLabel.text = model.timezone.deletingPrefixFromTimezone().deletingDashFromText()
    }
}
