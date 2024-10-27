//
//  WeatherViewModel.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import Foundation
import CoreLocation

class WeatherViewModel : NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weatherData: WeatherData?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationDenied: Bool = false
    
    private let weatherService = WeatherService()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.startUpdatingLocation()
    }
    
    // Fetch current weather data using Latitude and Longitude
    func fetchWeather(for location: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil
        
        let units = UserPreferences.loadUnits()
        
        weatherService.fetchWeatherData(lat: location.latitude, lon: location.longitude, units: units) { [weak self] result in
            self?.handleWeatherResult(result)
        }
    }
    
    // Fetch current weather data using City name
    func fetchWeather(for city: String) {
        // Start loading state and clear any previous error message
        isLoading = true
        errorMessage = nil
        
        let units = UserPreferences.loadUnits()
        
        weatherService.fetchWeatherData(cityName: city, units: units) { [weak self] result in
            self?.handleWeatherResult(result)
        }
    }
    
    // Fetch current weather data using city name with completion callback
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherData, WeatherServiceError>) -> Void) {
        let units = UserPreferences.loadUnits()
        
        weatherService.fetchWeatherData(cityName: city, units: units) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    private func handleWeatherResult(_ result: Result<WeatherData, WeatherServiceError>) {
        
        DispatchQueue.main.async {
            self.isLoading = false
            
            switch result {
            case .success(let weather):
                self.weatherData = weather
                self.errorMessage = nil
            case .failure(let error):
                self.handleWeatherServiceError(error)
            }
        }
    }
    
    // Method for handling Weather Service errors
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
    
    // Called when the location manager updates the user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
    
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.fetchWeather(for: location.coordinate)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    // Called when location authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied by user")
            DispatchQueue.main.async {
                self.locationDenied = true
                self.errorMessage = "Location access is denied. Please enable it in Settings."
            }
        default:
            break
        }
    }
    
    // Called when fails to get user location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to get user location: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.errorMessage = "Unable to get your location. Please try again later."
        }
    }
    
    // Method for user to manually request their current location
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    // Will and should be called ONLY if the user wants to setup daily notifications
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
}
