//
//  WeatherData.swift
//  Horizon
//
//  Created by Jonathan Vieri on 21/10/24.
//

import Foundation

struct WeatherData : Decodable {
    let name: String
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let sys: Sys
}

//MARK: - Weather
struct Weather : Decodable {
    let id: Int
    let description: String
}

//MARK: - Main
struct Main : Decodable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    // Use CodingKeys to map the JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
    }
}

//MARK: - Wind
struct Wind : Decodable {
    let speed: Double
    let deg: Double
}

//MARK: - Sys
struct Sys : Decodable {
    let sunrise: Double
    let sunset: Double
}
