//
//  WeatherManager.swift
//  Clima
//
//  Created by Eremej Sumcenko on 20.02.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

struct WeatherManager {
    init(using weatherAPI: WeatherAPIAdapter) {
        self.weatherAPI = weatherAPI
        self.delegate = nil
    }
    
    let weatherAPI: WeatherAPIAdapter
    
    var delegate: WeatherDelegate?
    
    func requestWeather(for cityName: String) {
        performRequest { () throws -> URL in
            try weatherAPI.currentWeatherURL(for: cityName)
        }
    }
    
    func requestWeather(latitude: Float, longitude: Float) {
        performRequest { () throws -> URL in
            try weatherAPI.currentWeatherURL(latitude, longitude)
        }
    }
    
    private func performRequest(for requestUrl: () throws -> URL) {
        do {
            URLSession(configuration: .default).dataTask(with: try requestUrl()) { (data, response, error) in
                if let receivedData = data {
                    do {
                        let weatherInstance = try weatherAPI.getWeather(data: receivedData)
                        
                        DispatchQueue.main.async {
                            delegate?.didUpdateWeather(self, weather: weatherInstance)
                        }
                    } catch let errorHappened {
                        DispatchQueue.main.async {
                            delegate?.didFailWithError(self, error: errorHappened)
                        }
                    }
                }
                if let errorHappened = error {
                    DispatchQueue.main.async {
                        delegate?.didFailWithError(self, error: errorHappened)
                    }
                }
            }
            .resume()
        } catch let errorHappened {
            DispatchQueue.main.async {
                delegate?.didFailWithError(self, error: errorHappened)
            }
        }
    }
}

//MARK: - WeatherDelegate protocol declaration
protocol WeatherDelegate {
    func didUpdateWeather(_ manager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ manager: WeatherManager, error: Error)
}

protocol WeatherAPIAdapter {
    func currentWeatherURL(for city: String) throws -> URL
    func currentWeatherURL(_ latitude: Float, _ longitude: Float) throws -> URL
    
    func getWeather(data: Data) throws -> WeatherModel
}
