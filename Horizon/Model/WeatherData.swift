//
//  WeatherData.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let sys: Sys
    let timezone: Int
}

//MARK: - Weather
struct Weather: Codable {
    let id: Int
    let description: String
}

//MARK: - Main
struct Main: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let feelsLike: Double
    
    // Use CodingKeys to map the JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case feelsLike = "feels_like"
    }
}

//MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
}

//MARK: - Sys
struct Sys: Codable {
    let sunrise: Double
    let sunset: Double
}
