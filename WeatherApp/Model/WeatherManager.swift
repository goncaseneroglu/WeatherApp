//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Gonca Seneroğlu on 21.07.2024.
//

import UIKit

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL =  "https://api.openweathermap.org/data/2.5/weather?appid=21ca60f63ee75d2d32c4a358257d780f&units=metric"
    func getWeather(cityName:String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    var delegate: WeatherManagerDelegate?
    
    func performRequest(urlString:String) {
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, url, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    
                    return
                } else {
                    if let safeData = data {
                        if let weather = self.parseJSON(weatherData: safeData) {
                            self.delegate?.didUpdateWeather(weather: weather)
                        }
                    }
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}



