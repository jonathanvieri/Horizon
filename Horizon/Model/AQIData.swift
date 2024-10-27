//
//  AQIData.swift
//  Horizon
//
//  Created by Jonathan Vieri on 25/10/24.
//

import Foundation

struct AQIData: Codable {
    let list: [AQIItem]
}

//MARK: - AQIItem
struct AQIItem: Codable {
    let main: AQIMain
    let dt: Int
}

//MARK: - AQIMain
struct AQIMain: Codable {
    let aqi: Int
}

