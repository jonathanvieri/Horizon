//
//  AQIData.swift
//  Horizon
//
//  Created by Jonathan Vieri on 25/10/24.
//

import Foundation

struct AQIData: Decodable {
    let list: [AQIItem]
}

//MARK: - AQIItem
struct AQIItem: Decodable {
    let main: AQIMain
    let components: AQIComponents
    let dt: Int
}

//MARK: - AQIMain
struct AQIMain: Decodable {
    let aqi: Int
}

//MARK: - AQIComponents
struct AQIComponents: Decodable {
    let co: Double
    let no: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
    let nh3: Double
}
