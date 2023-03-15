//
//  CoreDataManager.swift
//  WeatherApp
//
//  Created by Мелкозеров Данила on 13.05.2022.
//

import UIKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var isInserted = false
    
    func getAllCities(completion: @escaping ([WeatherApp]) -> Void) {
        do {
            let citiesFromCoreData = try context.fetch(WeatherApp.fetchRequest())
            completion(citiesFromCoreData)
        }
        catch {
        }
    }
    
    func insertCityToRepository(name: String) {
        if !isInsertedBefore(name: name) {
            let newCity = WeatherApp(context: context)
            newCity.cityName = name
            do {
                try context.save()
            }
            catch {
                print(Error.self)
            }
        }
    }
    
    func deleteCityFromRepository(name: WeatherApp) {
        context.delete(name)
        do {
            try context.save()
        }
        catch {
            print(Error.self)
        }
    }
    
    func isInsertedBefore(name: String) -> Bool {
        let fetch = WeatherApp.fetchRequest()
        let predicate = NSPredicate(format: "cityName == %@", name)
        
        isInserted = false

        fetch.predicate = predicate
        var result = [WeatherApp]()
        do {
            result = try context.fetch(fetch)
            if result.count > 0 {
                isInserted = true
            }
        } catch {
            print(error)
        }
        return isInserted
    }
}

