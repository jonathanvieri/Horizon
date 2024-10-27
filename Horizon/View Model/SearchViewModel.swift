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
    
    // Searches for weather data based on the city
    func searchWeather(for city: String) {
        guard !city.isEmpty else {
            errorMessage = "Please enter a city name."
            hasError = true
            return
        }
        
        resetSearchResults()
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
    
    // Handles any errors returned by WeatherService and updates the error message
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
            errorMessage = "City not found. Please ensure you have entered a valid city."
        case .decodingError(let decodingError):
            errorMessage = "Failed to parse data: \(decodingError.localizedDescription)"
        }
    }
    
    // Resets search results and error states before a new search
    private func resetSearchResults() {
        weatherData = nil
        errorMessage = nil
        hasError = false
    }
}
