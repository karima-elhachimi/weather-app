//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, CityHasChanged {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "23461228eefdf7698a4fa0215610fe8e"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    
    var weather = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, params: [String : String]) {
        Alamofire.request(url, method: .get, parameters: params).responseJSON { (response) in
            if response.result.isSuccess {
                print("get request was successfull")
                //print(response.result.value!)
                self.updateWeatherData(json: JSON(response.result.value!))
            } else {
                print("get request failed: \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection issues"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        if let tempResult = json["main"]["temp"].double {
        weather.temperature = Int(tempResult - 273.14 )
        weather.city = json["name"].stringValue
        weather.condition = json["weather"][0]["id"].intValue
        weather.weatherIconName = weather.updateWeatherIcon(condition: weather.condition)
            self.updateUIWithWeatherData()
            
        } else {
            cityLabel.text = "Weather unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        cityLabel.text = weather.city
        temperatureLabel.text = "\(weather.temperature)"
        weatherIcon.image = UIImage(named: weather.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let params : [String : String ] = ["lat": String(location.coordinate.latitude), "lon": String(location.coordinate.longitude), "appid": APP_ID]
            getWeatherData(url: WEATHER_URL, params: params)
            
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location was not found"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params: [ String: String ] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, params: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destination = segue.destination  as! ChangeCityViewController
            destination.delegate = self
        }
    }
    
    
    
}


