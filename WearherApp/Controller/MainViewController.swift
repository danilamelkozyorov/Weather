//
//  MainViewController.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 04.05.2022.
//

import UIKit
import CoreLocation
import CoreData

final class MainViewController: UIViewController {

    private let locationManager = CLLocationManager()
    private let networkManager = NetworkManager()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let searchController = UISearchController(searchResultsController: SearchResultsViewController())
    
    private var currentCoordinates: CLLocation?
    private var citiesFromCoreData = [WeatherApp]()
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

        // Configure 'add' item
        let addCityBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCity)
        )
        addCityBarButtonItem.tintColor = .systemGray5
        self.navigationItem.rightBarButtonItem  = addCityBarButtonItem

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
                LocationManager.shared.getCoordinate(name: city.cityName ?? "") { coordinate, error in
                    let latitude = coordinate.latitude
                    let longitude = coordinate.longitude
                    strongSelf.networkManager.fetchWeather(longitude: longitude, latitude: latitude) { weather in
                        strongSelf.favoriteCitiesWeather.append(weather)
                        strongSelf.citiesFromCoreData.append(city)
                        DispatchQueue.main.async {
                            strongSelf.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc private func addCity() {
        alertAddCity(
            name: "City",
            placeholder: "Enter City name"
        ) { [weak self] (city) in
            guard let strongSelf = self else { return }
            LocationManager.shared.getCoordinate(name: city) { coordinate, error in
                let latitude = coordinate.latitude
                let longitude = coordinate.longitude
                strongSelf.networkManager.fetchWeather(longitude: longitude, latitude: latitude) { weather in
                    strongSelf.favoriteCitiesWeather.append(weather)
                    DispatchQueue.main.async {
                        CoreDataManager.shared.insertCityToRepository(name: city)
                        CoreDataManager.shared.getAllCities { cities in
                            for city in cities {
                                strongSelf.citiesFromCoreData.append(city)
                            }
                        }
                        strongSelf.tableView.reloadData()
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
                return
            }
            networkManager.fetchWeather(longitude: longitude, latitude: latitude) { [weak self] weather in
                guard let strongSelf = self else { return }
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
            detailView.location = favoriteCitiesWeather[indexPath.row].timezone
            detailView.currentModel = favoriteCitiesWeather[indexPath.row].current
            detailView.dailyModel = favoriteCitiesWeather[indexPath.row].daily
            detailView.hourlyModel = favoriteCitiesWeather[indexPath.row]
            detailView.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(detailView, animated: true)
        } else {
            let detailView = WeatherDetailView()
            detailView.location = currentLocationWeather[indexPath.row].timezone
            detailView.currentModel = currentLocationWeather[indexPath.row].current
            detailView.dailyModel = currentLocationWeather[indexPath.row].daily
            detailView.hourlyModel = currentLocationWeather[indexPath.row]
            detailView.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(detailView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,complete in
                CoreDataManager.shared.deleteCityFromRepository(
                    name: self.citiesFromCoreData[indexPath.row]
                )
                self.favoriteCitiesWeather.remove(at: indexPath.row)
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
        networkManager.getCitiesName(text: query) { places in
            resultViewController.update(with: places)
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
        ) { [weak self] weather in
            guard let strongSelf = self else { return }
            strongSelf.favoriteCitiesWeather.append(weather)
            DispatchQueue.main.async {
                CoreDataManager.shared.getAllCities { cities in
                    for city in cities {
                        strongSelf.citiesFromCoreData.append(city)
                    }
                }
                strongSelf.tableView.reloadData()
            }
        }
    }
}
