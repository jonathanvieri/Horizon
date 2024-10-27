//
//  WeatherService.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import Foundation

enum WeatherServiceError: Error {
    case invalidURL
    case networkError(URLError)
    case serverError(statusCode: Int)
    case noData
    case cityNotFound
    case decodingError(Error)
}

class WeatherService: ObservableObject {
    private let apiKey = K.apiKey
    private let baseUrl = K.baseUrl
    
    // Fetch weather data using Latitude and Longitude
    func fetchWeatherData(lat: Double, lon: Double, units: String, completion: @escaping (Result<WeatherData, WeatherServiceError>) -> Void) {
        guard let url = createWeatherURLWithCoordinates(lat: lat, lon: lon, units: units) else {
            completion(.failure(.invalidURL))
            return
        }
        performNetworkRequest(with: url, completion: completion)
    }
    
    // Fetch weather data using City name
    func fetchWeatherData(cityName: String, units: String, completion: @escaping (Result<WeatherData, WeatherServiceError>) -> Void) {
        guard let url = createWeatherURLWithCityName(city: cityName, units: units) else {
            completion(.failure(.invalidURL))
            return
        }
        performNetworkRequest(with: url, completion: completion)
    }
    
    // Performs a network request and decodes the response
    private func performNetworkRequest(with url: URL, completion: @escaping (Result<WeatherData, WeatherServiceError>) -> Void) {
        print("URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error as? URLError {
                completion(.failure(.networkError(error)))
                return
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 404 {
                    completion(.failure(.cityNotFound))
                    return
                } else if response.statusCode != 200 {
                    completion(.failure(.serverError(statusCode: response.statusCode)))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherData.self, from: data)
                completion(.success(weatherData))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }
    
    // Constructs the URL for fetching weather data with latitude and longitude
    private func createWeatherURLWithCoordinates(lat: Double, lon: Double, units: String) -> URL? {
        var components = URLComponents(string: baseUrl)
        components?.path.append("/weather")
        components?.queryItems = [
            URLQueryItem(name: "units", value: units),
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        return components?.url
    }
    
    // Constructs the URL for fetching weather data with city name
    private func createWeatherURLWithCityName(city: String, units: String) -> URL? {
        var components = URLComponents(string: baseUrl)
        components?.path.append("/weather")
        components?.queryItems = [
            URLQueryItem(name: "units", value: units),
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        return components?.url
    }
}
