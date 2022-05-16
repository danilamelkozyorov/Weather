//
//  HourlyTableViewCell.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 12.05.2022.
//

//
//  HourlyWeatherCell.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 06.05.2022.
//

import UIKit

final class HourlyTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet private weak var hourlyCollectionView: UICollectionView!
    
    static let identifier = "HourlyTableViewCell"
    
    private var weatherModel: WeatherModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
    static func nib() -> UINib {
        UINib(nibName: "HourlyTableViewCell", bundle: nil)
    }
    
    func configure(model: WeatherModel) {
        self.weatherModel = model
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.hourlyCollectionView.reloadData()
        }
    }
    
    private func setupCollectionView() {
        hourlyCollectionView.register(HourlyCollectionViewCell.nib(), forCellWithReuseIdentifier: HourlyCollectionViewCell.identifier)
        hourlyCollectionView.backgroundColor = .secondarySystemBackground
        hourlyCollectionView.delegate = self
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.showsHorizontalScrollIndicator = false
    }
    
    private func configureCollectionCellViewModelFor(_ index: Int) -> HourlyCollectionViewCellViewModel  {
        var tempLabelString: String?
        var timeLabelString: String?
        var humidityLabelString: String?
        var urlStringForImage: String?
        
        if let weatherModel = weatherModel {
            let hourlyModel = weatherModel.hourly?[index]
            let hourForDate = Date(timeIntervalSince1970: Double(hourlyModel?.dt ?? 0)).getHourForDate()
            urlStringForImage = "https://openweathermap.org/img/wn/\(hourlyModel?.weather?[0].icon ?? "")@2x.png"
            if index == 0 {
                timeLabelString = "Now"
                tempLabelString = String(format: "%.f", weatherModel.hourly?[index].temp ?? 0) + "°"
            } else {
                tempLabelString = String(format: "%.f", weatherModel.hourly?[index].temp ?? 0) + "°"
                timeLabelString = hourForDate
            }
            
            if hourlyModel?.humidity ?? 0 >= 20 {
                humidityLabelString = String(hourlyModel?.humidity ?? 0) + " %"
            } else {
                humidityLabelString = ""
            }
        }
        return HourlyCollectionViewCellViewModel(tempLabelString: tempLabelString,
                                                 timeLabelString: timeLabelString,
                                                 humidityLabelString: humidityLabelString,
                                                 urlString: urlStringForImage)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 120)
    }
}

extension HourlyTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let hours = weatherModel?.hourly?.count else { return 0 }
        return hours
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCollectionViewCell.identifier, for: indexPath) as! HourlyCollectionViewCell
        let viewModel = configureCollectionCellViewModelFor(indexPath.row)
        cell.setupCell(viewModel)
        return cell
    }
}
