//
//  SearchViewModel.swift
//  Horizon
//
//  Created by Jonathan Vieri on 24/10/24.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var weatherData: WeatherData?
    @Published var errorMessage: String?
    @Published var hasError: Bool = false
    @Published var isLoading: Bool = false
    
    private let weatherService = WeatherService()
    
    // Search weather data based on the city
    func searchWeather(for city: String) {
        // Check for empty inputs
        guard !city.isEmpty else {return}
        
        // Clear previous data and errors
        weatherData = nil
        errorMessage = nil
        hasError = false
        isLoading = true
        
        let units = UserPreferences.loadUnits()
        
        weatherService.fetchWeatherData(cityName: city, units: units) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let weather):
                    self?.weatherData = weather
                case .failure(let error):
                    self?.handleWeatherServiceError(error)
                    self?.hasError = true
                }
            }
        }
    }
    
    // Method for handling any errors returned by Weather Service
    private func handleWeatherServiceError(_ error: WeatherServiceError) {
        switch error {
        case .invalidURL:
            errorMessage = "Invalid URL. Please try again."
        case .networkError(let networkError):
            errorMessage = "Network error: \(networkError.localizedDescription)"
        case .serverError(let statusCode):
            errorMessage = "Server error with status code: \(statusCode)"
        case .noData:
            errorMessage = "No data received. Please try again."
        case .cityNotFound:
            errorMessage = "City not found, please ensure you have entered a valid city."
        case .decodingError(let decodingError):
            errorMessage = "Failed to parse data: \(decodingError.localizedDescription)"
        }
    }
    
    
}
