//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var locationManager = CLLocationManager()
    
    var weatherManager = WeatherManager(using: OpenWeatherAPIs())
    
    var temperatureFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        temperatureFormatter.maximumFractionDigits = 0
        
        weatherManager.delegate = self
        
        searchTextField.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    @IBAction func locateButtinPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

//MARK: - WeatherViewController extension conforming WeatherDelegate
extension WeatherViewController: WeatherDelegate {
    func didUpdateWeather(_ manager: WeatherManager, weather: WeatherModel) {
        temperatureLabel.text = temperatureFormatter.string(from: NSNumber(value: weather.temperature))
        conditionImageView.image = UIImage(systemName: weather.conditionResourceName)
        cityLabel.text = weather.cityName
        descriptionLabel.text = weather.description
    }
    
    func didFailWithError(_ manager: WeatherManager, error: Error) {
        print(error)
    }
}

//MARK: - WeatherViewController extension conforming UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text!.removeAll {(char) in char == " "}
        weatherManager.requestWeather(for: searchTextField.text!)
        
        //print("'\(searchTextField.text ?? "")'")

        searchTextField.text = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // return only if some text entered in search field
        return !(textField.text?.isEmpty ?? true)
    }
}

//MARK: - WeatherViewController extension conforming CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            print("got user location: (\(lat), \(lon)")
            
            weatherManager.requestWeather(latitude: Float(lat), longitude: Float(lon))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
