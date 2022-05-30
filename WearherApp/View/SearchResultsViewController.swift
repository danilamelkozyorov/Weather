//
//  SearchResultsViewController.swift
//  WearherApp
//
//  Created by Мелкозеров Данила on 11.05.2022.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapPlace(with coordinates: Coordinates)
}

final class SearchResultsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var places: [Place] = []
    weak var delegate: SearchResultsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    public func update(with places: [Place], with error: WeatherErrors?) {
        self.places = places
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.places.count == 0, error == nil {
                strongSelf.tableView.tableFooterView = strongSelf.weatherFooter(message: "We can't find current City, try to change your request")
            } else {
                switch error {
                case .incorrectURL:
                    strongSelf.tableView.tableFooterView = strongSelf.weatherFooter(message: WeatherErrors.incorrectURL.description)
                case .connectionLost:
                    strongSelf.tableView.tableFooterView = strongSelf.weatherFooter(message: WeatherErrors.connectionLost.description)
                case .jsonDecodeFail:
                    strongSelf.tableView.tableFooterView = strongSelf.weatherFooter(message: WeatherErrors.jsonDecodeFail.description)
                default:
                    strongSelf.tableView.tableFooterView = nil
                }
            }
            
            strongSelf.tableView.reloadData()
        }
    }
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cityName = places[indexPath.row].name,
              let cityCoordinates = places[indexPath.row].coordinates else {
            return
        }
        CoreDataManager.shared.insertCityToRepository(name: cityName)
        delegate?.didTapPlace(with: cityCoordinates)
        dismiss(animated: true)
    }
}

extension SearchResultsViewController {
    private func weatherFooter(message: String) -> UIView {
        let weatherFooterView = UIView()
        let weatherFooterLabel = UILabel()
        
        weatherFooterView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        weatherFooterView.backgroundColor = .systemGray5
        weatherFooterView.layer.cornerRadius = 10
        weatherFooterView.addSubview(weatherFooterLabel)
        
        weatherFooterLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        weatherFooterLabel.text = message
        weatherFooterLabel.textColor = .darkGray
        weatherFooterLabel.textAlignment = .center
        weatherFooterLabel.numberOfLines = 0
        
        return weatherFooterView
    }
    
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
}
