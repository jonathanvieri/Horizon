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
        
        // Construct URL String and ensure the URL is valid
        var components = URLComponents(string: baseUrl)
        components?.path.append("/weather")
        components?.queryItems = [
            URLQueryItem(name: "units", value: units),
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        performNetworkRequest(with: url, completion: completion)
    }
    
    // Fetch weather data using City name
    func fetchWeatherData(cityName: String, units: String, completion: @escaping (Result<WeatherData, WeatherServiceError>) -> Void) {
        // Construct URL String and ensure the URL is valid
        var components = URLComponents(string: baseUrl)
        components?.path.append("/weather")
        components?.queryItems = [
            URLQueryItem(name: "units", value: units),
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        performNetworkRequest(with: url, completion: completion)
    }
    
    private func performNetworkRequest(with url: URL, completion: @escaping (Result<WeatherData, WeatherServiceError>) -> Void) {
        print("URL: \(url)")
        
        
        // Perform network request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // Ensure we have no errors and response code is successful
            if let error = error as? URLError {
                completion(.failure(.networkError(error)))
                return
            } else if let response = response as? HTTPURLResponse {
                if response.statusCode == 404 {
                    completion(.failure(.cityNotFound))
                    return
                } else if response.statusCode != 200 {
                    completion(.failure(.serverError(statusCode: response.statusCode)))
                    return
                }
            }
            
            // Ensure we received data
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
                    
            // If there are no errors, decode the JSON response into WeatherData
            do {
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherData.self, from: data)
                
                // Return the decoded data as weather data to the completion handler
                completion(.success(weatherData))
                
                
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        
        // Start the task
        task.resume()
    }
}
