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
    
    // Fetch AQI data based on latitude and longitude
    func fetchAQIData(lat: Double, lon: Double, completion: @escaping (Result<AQIData, AQIServiceError>) -> Void) {
        guard let url = createAQIURL(lat: lat, lon: lon) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Perform network request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            // Ensure we have no errors and response code is successful
            if let error = error as? URLError {
                completion(.failure(.networkError(error)))
                return
            }
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            
            // Ensure we received data and it is present
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // If there are no errors, decode the JSON response into AQIData
            do {
                let decoder = JSONDecoder()
                let aqiData = try decoder.decode(AQIData.self, from: data)
                completion(.success(aqiData))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }
    
    // Constructs the URL for fetching AQI data
    private func createAQIURL(lat: Double, lon: Double) -> URL? {
        var components = URLComponents(string: baseUrl)
        components?.path.append("/air_pollution")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        return components?.url
    }
}
