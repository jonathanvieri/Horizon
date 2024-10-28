//
//  AQIViewModel.swift
//  Horizon
//
//  Created by Jonathan Vieri on 26/10/24.
//

import SwiftUI
import CoreLocation

class AQIViewModel: ObservableObject {
    private let userPreferences = UserPreferences()
    private let aqiService = AQIService()
    private let cacheDuration: TimeInterval = 3600
    
    @Published var aqiValue: Int = 0
    @Published var aqiDescription: String = "Loading..."
    @Published var aqiColor: Color = .red
    @Published var errorMessage: String?
    @Published var hasError: Bool = false
    @Published var isLoading: Bool = false
    
    // Fetches AQI Data based on the provided location
    func fetchAQIData(for location: CLLocation) {
        // Check if we can use cached data
        if let cachedData = shouldUseCachedAQIData() {
            print("Using cached AQI data")
            updateAQIValues(cachedData)
            return
        }

        print("Not using cached AQI data")
        fetchAQIDataFromAPI(for: location)
    }
    
    func forceFetchAQIData(for location: CLLocation) {
        print("Not using cached AQI data")
        fetchAQIDataFromAPI(for: location)
    }
    
    private func fetchAQIDataFromAPI(for location: CLLocation) {
        resetAQIValues()
        isLoading = true
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        aqiService.fetchAQIData(lat: lat, lon: lon) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let aqiData):
                    self?.updateAQIValues(aqiData)
                    self?.userPreferences.saveLastAQIFetchTime()
                    self?.userPreferences.saveCachedAQIData(aqiData)
                case .failure(let error):
                    self?.handleAQIServiceError(error)
                    self?.hasError = true
                }
            }
        }
    }
    
    // Converts AQI integer value to a descriptive string
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
    
    // Converts AQI integer value to a corresponding color
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
    
    // Method for checking whether we should use Cached AQIData or not
    private func shouldUseCachedAQIData() -> AQIData? {
        guard let lastFetchTime = userPreferences.getLastAQIFetchTime(),
              let cachedData = userPreferences.getCachedAQIData() else { return nil }
        
        let currentTime = Date().timeIntervalSince1970
        let isCacheValid = (currentTime - lastFetchTime) < cacheDuration
        return isCacheValid ? cachedData : nil
    }
    
    // Method for updating AQI values
    private func updateAQIValues(_ aqiData: AQIData) {
        if let aqi = aqiData.list.first?.main.aqi {
            aqiValue = aqi
            aqiDescription = aqiToDescription(for: aqi)
            aqiColor = aqiToColor(for: aqi)
        }
    }
    
    // Resets AQI Values to their default values
    private func resetAQIValues() {
        aqiValue = 0
        aqiDescription = "Loading..."
        errorMessage = nil
        hasError = false
    }
}
