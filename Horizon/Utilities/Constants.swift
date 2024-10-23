//
//  Constants.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import SwiftUI

struct K {
    
    // OpenWeatherMap's API Related
    static let apiKey = "YOUR_API_KEY_HERE"
    static let baseUrl = "https://api.openweathermap.org/data/2.5"
    
    // Temperature Units
    static let celsiusUnit = "metric"
    static let fahrenheitUnit = "imperial"
    
    // Default Location
    static let defaultCity = "Jakarta"
    
    
    // Color Palette
    struct DarkColors {
        static let background = Color(red: 0.10, green: 0.11, blue: 0.12)
        static let white = Color(red: 0.98, green: 0.99, blue: 1)
        static let gray = Color(red: 0.17, green: 0.18, blue: 0.18)
        static let blue = Color(red: 0.52, green: 0.80, blue: 0.92)
    }
    
}
