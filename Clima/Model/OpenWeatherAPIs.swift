//
//  OpenWeatherAPIs.swift
//  Clima
//
//  Created by Eremej Sumcenko on 20.02.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

struct OpenWeatherAPIs {
    
    private static let apiKey = ""
    
    
    private static let baseURL = "https://api.openweathermap.org/data/2.5/"
    private static let appidParam = "appid"
    
    
    struct OpenWeatherResponse: Decodable {

        struct Weather: Decodable {
            /**
             Weather condition id
             */
            let id: Int
            
            /**
             Group of weather parameters (Rain, Snow, Extreme etc.)
             */
            let main: String
            
            /**
             Weather condition within the group. You can get the output in your language.
             */
            let description: String
            
            /**
             Weather icon id
             */
            let icon: String
        }
        
        struct Main: Decodable {
            /**
             Temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
             */
            let temp: Float
            
            /**
             Temperature. This temperature parameter accounts for the human perception of weather. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
             */
            let feels_like: Float
            
            /**
             Minimum temperature at the moment. This is minimal currently observed temperature (within large megalopolises and urban areas). Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
             */
            let temp_min: Float
            
            /**
             Maximum temperature at the moment. This is maximal currently observed temperature (within large megalopolises and urban areas). Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
             */
            let temp_max: Float
            
            /**
             Atmospheric pressure (on the sea level, if there is no sea_level or grnd_level data), hPa
             */
            let pressure: Int
            
            /**
             Humidity, %
             */
            let humidity: Int
            
        }
        
        struct Coord: Decodable {
            /**
             City geo location, longitude
             */
            let lon: Float
            
            /**
             City geo location, latitude
             */
            let lat: Float
        }
        
        
        let coord: Coord
        
        /**
         more info Weather condition codes
         */
        let weather: [Weather]
        
        let main: Main
        
        /**
         City name
         */
        let name: String
    }
    
    enum Mode: String {
        case XML = "xml"
    }
    
    enum Unit: String {
        case standard = "standard"
        case metric = "metric"
        case imperial = "imperial"
    }
    
    enum Lang: String {
        case English = "en"
        case Russian = "ru"
    }
    
    
    /**
     Build request URL that conform OpenWeather API with given parameters
     */
    static func currentWeatherData(cityName q: String, mode: Mode?, units: Unit?, lang: Lang?) -> String {
        let weatherPath = "weather"
        let cityParam = "q"
        let modeParam = "mode"
        let unitsParam = "units"
        let langParam = "lang"
        
        var urlString = baseURL + weatherPath + "?" + appidParam + "=" + apiKey + "&" + cityParam + "=" + q
        
        if let modeSpecified = mode {
            urlString += "&" + modeParam + "=" + modeSpecified.rawValue
        }
        if let unitsSpecified = units {
            urlString += "&" + unitsParam + "=" + unitsSpecified.rawValue
        }
        if let langSpecified = lang {
            urlString += "&" + langParam + "=" + langSpecified.rawValue
        }
                
        return urlString
    }
    
    static func currentWeatherData(lat: Float, lon: Float, mode: Mode?, units: Unit?, lang: Lang?) -> String {
        let weatherPath = "weather"
        let latParam = "lat"
        let lonParam = "lon"
        let modeParam = "mode"
        let unitsParam = "units"
        let langParam = "lang"
        
        var urlString = baseURL + weatherPath + "?" + appidParam + "=" + apiKey + "&" + latParam + "=" + String(lat) + "&" + lonParam + "=" + String(lon)
        
        if let modeSpecified = mode {
            urlString += "&" + modeParam + "=" + modeSpecified.rawValue
        }
        if let unitsSpecified = units {
            urlString += "&" + unitsParam + "=" + unitsSpecified.rawValue
        }
        if let langSpecified = lang {
            urlString += "&" + langParam + "=" + langSpecified.rawValue
        }
                
        return urlString
    }
}


// MARK: - WeatherAPIAdapter conformance
extension OpenWeatherAPIs: WeatherAPIAdapter {
    func currentWeatherURL(for city: String) throws -> URL {
        if let url = URL(string: OpenWeatherAPIs.currentWeatherData(
                            cityName: city,
                            mode: nil,
                            units: .metric,
                            lang: nil)) {
            return url
        } else {
            throw URLError(.badURL)
        }
    }
    
    func currentWeatherURL(_ latitude: Float, _ longitude: Float) throws -> URL {
        if let url = URL(string: OpenWeatherAPIs.currentWeatherData(
                            lat: latitude,
                            lon: longitude,
                            mode: nil,
                            units: .metric,
                            lang: nil)) {
            return url
        } else {
            throw URLError(.badURL)
        }
    }
    
    func getWeather(data: Data) throws -> WeatherModel {
        func getConditionResourceName(conditionId: Int) -> String {
            switch conditionId {
            case 200...232:
                return "cloud.bolt"
            case 300...321:
                return "cloud.drizzle"
            case 500...531:
                return "cloud.rain"
            case 600...622:
                return "cloud.snow"
            case 701...781:
                return "cloud.fog"
            case 800:
                return "sun.max"
            case 801...804:
                return "cloud.bolt"
            default:
                return "cloud"
            }
        }
        
        let response = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
        
        return WeatherModel(
            cityName: response.name,
            description: response.weather[0].description,
            temperature: response.main.temp,
            conditionResourceName: getConditionResourceName(
                conditionId: response.weather[0].id
            )
        )
    }
    
    
}
