//
//  MainViewController.swift
//  WeatherApp
//
//  Created by Мелкозеров Данила on 04.05.2022.
//

import UIKit
import CoreLocation
import CoreData

final class MainViewController: UIViewController {

    private let locationManager = CLLocationManager()
    private let networkManager = NetworkManager.shared
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let searchController = UISearchController(searchResultsController: SearchResultsViewController())
    
    private var isConnected = true
    private var currentCoordinates: CLLocation?
    private var citiesFromCoreData: [String?] = []
    private var favoriteCitiesWeather = [WeatherModel]()
    private var currentLocationWeather = [WeatherModel]()
                
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureTableView()
        setTableViewConstraints()
        setupLocation()
        updateCitiesWeatherFromCoreData()
    }

    private func configureView() {
        // Configure view
        title = "Weather"
        view.backgroundColor = UIColor(cgColor: CGColor(red: 0.35, green: 0.35, blue: 1, alpha: 1))

        // Configure search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.backgroundColor = .secondarySystemBackground
        self.navigationItem.searchController = searchController
    }

    private func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    private func configureTableView() {
        view.addSubview(tableView)

        tableView.register(ListCitiesCell.nib(), forCellReuseIdentifier: ListCitiesCell.identifier)

        tableView.dataSource = self
        tableView.delegate = self
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
    
    private func updateCitiesWeatherFromCoreData() {
        CoreDataManager.shared.getAllCities { [weak self] cities in
            guard let strongSelf = self else { return }
            for city in cities {
                LocationManager.shared.getCoordinate(name: city.cityName ?? "") { coordinate, cityName, error in
                    guard let latitude = coordinate?.latitude,
                          let longitude = coordinate?.longitude else {
                        return Alert.shared.inform(
                            title: "GEO location fail",
                            message: error?.description ?? "",
                            viewController: strongSelf
                        )
                    }
                    strongSelf.networkManager.fetchWeather(longitude: longitude, latitude: latitude) {
                        weather, error in
                        guard let weather = weather else {
                            return
                        }
                        strongSelf.favoriteCitiesWeather.append(weather)
                        strongSelf.citiesFromCoreData.append(cityName)
                        DispatchQueue.main.async {
                            strongSelf.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
// MARK: - LocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentCoordinates == nil {
            currentCoordinates = locations.first
            locationManager.stopUpdatingLocation()
            guard let longitude = currentCoordinates?.coordinate.longitude,
                  let latitude = currentCoordinates?.coordinate.latitude else {
                return print("fail coord")
            }
            networkManager.fetchWeather(longitude: longitude, latitude: latitude) { [weak self] weather, error in
                guard let strongSelf = self,
                let weather = weather else {
                    guard let self = self else { return }
                    return DispatchQueue.main.async {
                        self.isConnected = false
                        self.tableView.tableFooterView = self.weatherLostConnectionFooter()
                    }
                }
                strongSelf.currentLocationWeather.append(weather)
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - TableView delegate and data source
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = WeatherListTableViewSection(sectionIndex: section) else { return "" }
        
        switch section {
        case .currentLocation:
            return section.sectionHeaderText
        case .favorite:
            return section.sectionHeaderText
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        WeatherListTableViewSection.numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = WeatherListTableViewSection(sectionIndex: section) else { return 0 }

        switch section {
        case .currentLocation:
            return currentLocationWeather.count
        case .favorite:
            return favoriteCitiesWeather.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = WeatherListTableViewSection(sectionIndex: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .currentLocation:
            let cell = tableView.dequeueReusableCell(withIdentifier: ListCitiesCell.identifier, for: indexPath) as! ListCitiesCell
            cell.configure(with: currentLocationWeather[indexPath.row])
            return cell
        case .favorite:
            let cell = tableView.dequeueReusableCell(withIdentifier: ListCitiesCell.identifier, for: indexPath) as! ListCitiesCell
            cell.configure(with: favoriteCitiesWeather[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let detailView = WeatherDetailView()
            detailView.delegate = self
            detailView.location = favoriteCitiesWeather[indexPath.row].cityName
            detailView.currentModel = favoriteCitiesWeather[indexPath.row].current
            detailView.dailyModel = favoriteCitiesWeather[indexPath.row].daily
            detailView.hourlyModel = favoriteCitiesWeather[indexPath.row]
            detailView.modalPresentationStyle = .fullScreen
            navigationItem.backButtonTitle = "Back"
            navigationController?.pushViewController(detailView, animated: true)
        } else {
            let detailView = WeatherDetailView()
            detailView.delegate = self
            detailView.location = currentLocationWeather[indexPath.row].cityName
            detailView.currentModel = currentLocationWeather[indexPath.row].current
            detailView.dailyModel = currentLocationWeather[indexPath.row].daily
            detailView.hourlyModel = currentLocationWeather[indexPath.row]
            detailView.modalPresentationStyle = .fullScreen
            navigationItem.backButtonTitle = "Back"
            navigationController?.pushViewController(detailView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,complete in
                CoreDataManager.shared.getAllCities { cities in
                    for city in cities {
                        if city.cityName == self.citiesFromCoreData[indexPath.row] {
                            CoreDataManager.shared.deleteCityFromRepository(name: city)
                        }
                    }
                }
                self.favoriteCitiesWeather.remove(at: indexPath.row)
                self.citiesFromCoreData.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                complete(true)
                tableView.reloadData()
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        return UISwipeActionsConfiguration()
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultViewController = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        resultViewController.delegate = self
        networkManager.getCitiesName(text: query) { places, error in
            if let places = places {
                resultViewController.update(with: places, with: error)
            } else {
                resultViewController.update(with: [], with: error)
            }
        }
    }
}

extension MainViewController: SearchResultsViewControllerDelegate {
    func didTapPlace(with coordinates: Coordinates) {
        searchController.searchBar.text = .none
        guard let latitude = coordinates.lat,
              let longitude = coordinates.lon else {
            return
        }
        networkManager.fetchWeather(
            longitude: longitude,
            latitude: latitude
        ) { [weak self] weather, error in
            guard let strongSelf = self,
                  let weather = weather else { return }
            strongSelf.tableView.tableFooterView = nil
            strongSelf.isConnected = true
            if !CoreDataManager.shared.isInserted {
                strongSelf.favoriteCitiesWeather.append(weather)
                CoreDataManager.shared.getAllCities { cities in
                    for city in cities {
                        strongSelf.citiesFromCoreData.append(city.cityName)
                    }
                }
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            } else {
                Alert.shared.inform(
                    title: "Alert information",
                    message: WeatherErrors.isInsertedBefore.description,
                    viewController: strongSelf
                )
            }
        }
    }
}

// MARK: - add city from map view coordinates
extension MainViewController: WeatherMapViewControllerDelegate {
    func didAddPlace(with coordinate: CLLocationCoordinate2D?, with cityName: String) {
        guard let longitude = coordinate?.longitude,
              let latitude = coordinate?.latitude else { return }
        NetworkManager.shared.fetchWeather(longitude: longitude, latitude: latitude) { [weak self] weather, error in
            guard let strongSelf = self,
                  let weather = weather,
                  error == nil else {
                guard let self = self else { return }
                return Alert.shared.inform(
                    title: cityName,
                    message: error?.description ?? "",
                    viewController: self
                )
            }
            strongSelf.favoriteCitiesWeather.append(weather)
            strongSelf.citiesFromCoreData.append(cityName)
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
        }
    }
}

// MARK: - configuring footerView
extension MainViewController {
    // Weather footer for empty search City
    private func weatherEmptyLocationFooter(message: String) -> UIView {
        let weatherEmptyLocationFooter = UIView()
        let weatherEmptyLocationLabel = UILabel()

        weatherEmptyLocationFooter.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        weatherEmptyLocationFooter.layer.cornerRadius = 10
        weatherEmptyLocationFooter.addSubview(weatherEmptyLocationLabel)

        weatherEmptyLocationLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        weatherEmptyLocationLabel.text = message
        weatherEmptyLocationLabel.textColor = .darkGray
        weatherEmptyLocationLabel.textAlignment = .center
        weatherEmptyLocationLabel.numberOfLines = 0

        return weatherEmptyLocationFooter
    }

    // Weather footer for lost connection
    private func weatherLostConnectionFooter() -> UIView {
        let weatherLostConnectFooterView = UIView()
        let weatherLostConnectFooterLabel = UILabel()
        let weatherLostConnectFooterButton = UIButton()

        weatherLostConnectFooterView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 75)
        weatherLostConnectFooterView.backgroundColor = .systemGray5
        weatherLostConnectFooterView.layer.cornerRadius = 20
        weatherLostConnectFooterView.addSubview(weatherLostConnectFooterLabel)
        weatherLostConnectFooterView.addSubview(weatherLostConnectFooterButton)

        weatherLostConnectFooterLabel.frame = CGRect(x: 0, y: 3, width: view.frame.size.width, height: 25)
        weatherLostConnectFooterLabel.text = "Connection lost..."
        weatherLostConnectFooterLabel.textAlignment = .center

        weatherLostConnectFooterButton.frame = CGRect()
        weatherLostConnectFooterButton.backgroundColor = .darkGray
        weatherLostConnectFooterButton.layer.cornerRadius = 10
        weatherLostConnectFooterButton.setTitle("Try again", for: .normal)
        weatherLostConnectFooterButton.addTarget(self, action: #selector(lostConnectionButtonAction), for: .touchUpInside)
        weatherLostConnectFooterButton.translatesAutoresizingMaskIntoConstraints = false
        weatherLostConnectFooterLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            weatherLostConnectFooterButton.leadingAnchor.constraint(equalTo: weatherLostConnectFooterView.leadingAnchor, constant: 20),
            weatherLostConnectFooterButton.trailingAnchor.constraint(equalTo: weatherLostConnectFooterView.trailingAnchor, constant: -20),
            weatherLostConnectFooterButton.topAnchor.constraint(equalTo: weatherLostConnectFooterLabel.bottomAnchor, constant: 5),
            weatherLostConnectFooterButton.bottomAnchor.constraint(equalTo: weatherLostConnectFooterView.bottomAnchor, constant: -5),
            weatherLostConnectFooterLabel.topAnchor.constraint(equalTo: weatherLostConnectFooterView.topAnchor, constant: 5),
            weatherLostConnectFooterLabel.centerXAnchor.constraint(equalTo: weatherLostConnectFooterView.centerXAnchor)
        ])
        return weatherLostConnectFooterView
    }

    @objc private func lostConnectionButtonAction() {
        self.tableView.tableFooterView = nil
        guard let currentLocation = currentCoordinates?.coordinate else { return }
        networkManager.fetchWeather(
            longitude: currentLocation.longitude,
            latitude: currentLocation.latitude) { [weak self] weather, error in
                guard let strongSelf = self,
                      let weather = weather else {
                    guard let self = self else { return }
                    return DispatchQueue.main.async {
                        self.isConnected = false
                        self.tableView.tableFooterView = self.weatherLostConnectionFooter()
                    }
                }
                strongSelf.isConnected = true
                strongSelf.currentLocationWeather.append(weather)
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            }
        
        CoreDataManager.shared.getAllCities { [weak self] cities in
            guard let strongSelf = self else { return }
            for city in cities {
                LocationManager.shared.getCoordinate(name: city.cityName ?? "") { coordinate, cityName, error in
                    guard let latitude = coordinate?.latitude,
                          let longitude = coordinate?.longitude else { return }
                    strongSelf.networkManager.fetchWeather(longitude: longitude, latitude: latitude) { weather, error in
                        guard let weather = weather else {
                            return
                        }
                        strongSelf.favoriteCitiesWeather.append(weather)
                        strongSelf.citiesFromCoreData.append(cityName)
                        DispatchQueue.main.async {
                            strongSelf.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

