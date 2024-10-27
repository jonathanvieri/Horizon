//
//  AQIService.swift
//  Horizon
//
//  Created by Jonathan Vieri on 25/10/24.
//

import Foundation

enum AQIServiceError: Error {
    case invalidURL
    case networkError(URLError)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
}

class AQIService : ObservableObject {
    private let apiKey = K.apiKey
    private let baseUrl = K.baseUrl

    func fetchAQIData(lat: Double, lon: Double, completion: @escaping (Result<AQIData, AQIServiceError>) -> Void) {
        // Construct URL String and ensure the URL is valid
        var components = URLComponents(string: baseUrl)
        components?.path.append("/air_pollution")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("URL: \(url)")
        
        // Perform network request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // Ensure we have no errors and response code is successful
            if let error = error as? URLError {
                completion(.failure(.networkError(error)))
                return
            } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            
            // Ensure we received data
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
                    
            // If there are no errors, decode the JSON response into AQIData
            do {
                let decoder = JSONDecoder()
                let aqiData = try decoder.decode(AQIData.self, from: data)
                
                // Return the decoded data as weather data to the completion handler
                completion(.success(aqiData))
                
                
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        
        // Start the task
        task.resume()
    }
}
