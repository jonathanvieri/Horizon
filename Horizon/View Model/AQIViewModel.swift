//
//  AQIViewModel.swift
//  Horizon
//
//  Created by Jonathan Vieri on 26/10/24.
//

import SwiftUI
import CoreLocation

class AQIViewModel: ObservableObject {
    @Published var aqiValue: Int = 0
    @Published var aqiDescription: String = "Loading..."
    @Published var aqiColor: Color = .red
    @Published var errorMessage: String?
    @Published var hasError: Bool = false
    @Published var isLoading: Bool = false
    
    private let aqiService = AQIService()
    
    func fetchAQIData(for location: CLLocation) {
        aqiValue = 0
        aqiDescription = "Loading..."
        errorMessage = nil
        hasError = false
        isLoading = true
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        aqiService.fetchAQIData(lat: lat, lon: lon) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let aqiData):
                    if let aqi = aqiData.list.first?.main.aqi {
                        self?.aqiValue = aqi
                        self?.aqiDescription = self?.aqiToDescription(for: aqi) ?? "Data not found"
                        self?.aqiColor = self?.aqiToColor(for: aqi) ?? .gray
                    }
                case .failure(let error):
                    self?.handleAQIServiceError(error)
                    self?.hasError = true
                }
            }
        }
    }
    
    // Method for getting description from AQI value
    private func aqiToDescription(for aqi: Int) -> String {
        switch aqi {
        case 1:
            return "Good"
        case 2:
            return "Fair"
        case 3:
            return "Moderate"
        case 4:
            return "Poor"
        case 5:
            return "Very Poor"
        default:
            return "Unknown"
        }
    }

    // Method for getting color from AQI value
    private func aqiToColor(for aqi: Int) -> Color {
        switch aqi {
        case 1:
            return K.AQIColors.green
        case 2:
            return K.AQIColors.yellow
        case 3:
            return K.AQIColors.orange
        case 4:
            return K.AQIColors.red
        case 5:
            return K.AQIColors.purple
        default:
            return .red
        }
    }
    
    // Method for handling errors returned by AQIService
    private func handleAQIServiceError(_ error: AQIServiceError) {
        switch error {
        case .invalidURL:
            errorMessage = "Invalid URL. Please try again."
        case .networkError(let networkError):
            errorMessage = "Network error: \(networkError.localizedDescription)"
        case .serverError(let statusCode):
            errorMessage = "Server error with status code: \(statusCode)"
        case .noData:
            errorMessage = "No data received. Please try again."
        case .decodingError(let decodingError):
            errorMessage = "Failed to parse data: \(decodingError.localizedDescription)"
        }
    }
}
