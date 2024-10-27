//
//  AQIData.swift
//  Horizon
//
//  Created by Jonathan Vieri on 25/10/24.
//

import Foundation

// Main model for AQI data response
struct AQIData: Codable {
    let list: [AQIItem]
}

//MARK: - AQI item details
struct AQIItem: Codable {
    let main: AQIMain
    let dt: Int
}

//MARK: - Main AQI index value
struct AQIMain: Codable {
    let aqi: Int
}

