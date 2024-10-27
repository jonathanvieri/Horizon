//
//  WeatherData.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import Foundation

// Main model for weather data response
struct WeatherData: Codable {
    let name: String
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let sys: Sys
    let timezone: Int
}

//MARK: - General weather conditions
struct Weather: Codable {
    let id: Int
    let description: String
}

//MARK: - Main temperature data
struct Main: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let feelsLike: Double
    
    // Maps the JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case feelsLike = "feels_like"
    }
}

//MARK: - Wind details
struct Wind: Codable {
    let speed: Double
    let deg: Int
}

//MARK: - Sunrise and sunset items
struct Sys: Codable {
    let sunrise: Double
    let sunset: Double
}
