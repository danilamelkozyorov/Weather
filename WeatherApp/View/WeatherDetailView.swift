//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Мелкозеров Данила on 09.05.2022.
//

import UIKit
import CoreLocation

final class WeatherDetailView: UIViewController {
            
    private let tableView = UITableView()
    
    var location: String?
    var currentModel: Current?
    var dailyModel: [Daily]?
    var hourlyModel: WeatherModel?
    
    weak var delegate: WeatherMapViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureTableView()
    }

    private func configureView() {
        view.backgroundColor = .secondarySystemBackground
        
        let openMapBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .bookmarks,
            target: self,
            action: #selector(openMapView)
            )
        self.navigationItem.rightBarButtonItem  = openMapBarButtonItem
        self.navigationItem.backButtonTitle = ""

    }
    
// MARK: - Setup tableView
    private func configureTableView() {
        view.addSubview(tableView)
        setTableViewConstraints()
        tableView.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableHeaderView = self.createTableHeader()
        tableView.register(DailyWeatherCell.nib(), forCellReuseIdentifier: DailyWeatherCell.identifier)
        tableView.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)

        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
// MARK: - Setup headerView
    private func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: view.frame.size.width,
            height: view.frame.size.height/3)
        )
        let cityLabel = UILabel()
        let descriptionLabel = UILabel()
        let tempLabel = UILabel()
        let feelsLikeLabel = UILabel()
        
        headerView.backgroundColor = UIColor(cgColor: CGColor(red: 0.35, green: 0.35, blue: 1, alpha: 1))
        headerView.addSubview(cityLabel)
        headerView.addSubview(descriptionLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(feelsLikeLabel)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        feelsLikeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tempLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: headerView.frame.size.height*0.45),
            descriptionLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            cityLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            feelsLikeLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: tempLabel.topAnchor, constant: -10),
            cityLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -10),
            feelsLikeLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 10)
            
        ])
        
        cityLabel.text = location
        cityLabel.textAlignment = .center
        cityLabel.font = UIFont(name: "Helvetica", size: 40)
        
        descriptionLabel.text = currentModel?.weather?[0].main?.rawValue ?? ""
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont(name: "Helvetica", size: 17)
        
        tempLabel.text = String(format: "%.f", currentModel?.temp ?? 0) + "°"
        tempLabel.textAlignment = .center
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 70)
        
        feelsLikeLabel.text = "feels like: " + String(format: "%.f", currentModel?.feelsLike ?? 0) + " °"
        feelsLikeLabel.textAlignment = .center
        feelsLikeLabel.font = UIFont(name: "Helvetica", size: 17)
        return headerView
    }
            
    @objc private func openMapView() {
        let mapView = WeatherMapViewController()
        mapView.delegate = self
        mapView.place = hourlyModel
        navigationController?.pushViewController(mapView, animated: true)
    }
}

// MARK: - TableViewDelegate and TableViewDataSource
extension WeatherDetailView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        WeatherDetailTableViewSection.numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = WeatherDetailTableViewSection(sectionIndex: section) else { return 0 }

        switch section {
        case .hourly:
            return 1
        case .daily:
            return 7
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = WeatherDetailTableViewSection(sectionIndex: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .hourly:
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            if let hourlyModel = hourlyModel {
                cell.configure(model: hourlyModel)
            }
            return cell
            
        case .daily:
            tableView.allowsSelection = false
            let cell = tableView.dequeueReusableCell(withIdentifier: DailyWeatherCell.identifier, for: indexPath) as! DailyWeatherCell
            if let dailyModel = dailyModel {
                cell.configure(model: dailyModel[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = WeatherDetailTableViewSection(sectionIndex: indexPath.section) else { return CGFloat() }
        switch section {
        case .hourly:
            return section.cellHeight
        case .daily:
            return section.cellHeight
        }
    }
}

extension WeatherDetailView: WeatherMapViewControllerDelegate {
    func didAddPlace(with coordinate: CLLocationCoordinate2D?, with cityName: String) {
        delegate?.didAddPlace(with: coordinate, with: cityName)
    }
}
