//
//  WeatherViewModel.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import Foundation
import CoreLocation

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let weatherService = WeatherService()
    private let locationManager = CLLocationManager()
    private let userPreferences = UserPreferences()
    private let cacheDuration: TimeInterval = 3600
    private var isForceRefresh = false
    
    var aqiViewModel: AQIViewModel
    
    @Published var weatherData: WeatherData?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationDenied: Bool = false
    @Published var isOffline: Bool = false
    
    init(aqiViewModel: AQIViewModel) {
        self.aqiViewModel = aqiViewModel
        super.init()
        configureLocationManager()
    }
    
    // Configures the location manager with necessary settings
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    
    // Method for user to manually request their current location
    func requestLocation(ignoreCache: Bool = false) {
        self.isForceRefresh = ignoreCache
        locationManager.requestLocation()
    }
    
    // Will and should be called ONLY if the user wants to setup daily notifications
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    // Fetches current weather data using latitude and longitude.
    func fetchWeather(for location: CLLocationCoordinate2D) {
        if let cachedData = shouldUseCachedData() {
            print("Using cached data")
            updateWeatherData(with: cachedData, isOffline: false)
            return
        }
        
        resetWeatherState()
        fetchWeatherData(latitude: location.latitude, longitude: location.longitude)
    }
    
    func forceFetchCurrentLocation(location: CLLocationCoordinate2D) {
        resetWeatherState()
        fetchWeatherData(latitude: location.latitude, longitude: location.longitude)
    }
    
    
    
    // Fetches current weather data using a city name
    func fetchWeather(for city: String, completion: ((Result<WeatherData, WeatherServiceError>) -> Void)? = nil) {
        if let cachedData = shouldUseCachedData() {
            print("Using cached weather - city data")
            updateWeatherData(with: cachedData, isOffline: false)
            completion?(.success(cachedData))
            return
        }
        
        resetWeatherState()
        fetchWeatherData(cityName: city, completion: completion)
    }
    
    // Fetches fresh weather data for a city, bypassing cache
    func fetchFreshWeather(for city: String, completion: ((Result<WeatherData, WeatherServiceError>) -> Void)? = nil) {
        print("Fetching fresh weather data - city data")
        resetWeatherState()  // Reset loading state to indicate fresh fetch
        fetchWeatherData(cityName: city, completion: completion)
    }
    
    func fetchFreshAQIData(for city: String) {
        getCoordinateFromAddress(city) { coordinate in
            if let coordinate = coordinate {
                self.aqiViewModel.forceFetchAQIData(for: coordinate)
            }
        }
        
    }
    
    // Performs the network request for weather data based on coordinates
    private func fetchWeatherData(latitude: Double, longitude: Double) {
        let units = UserPreferences.loadUnits()
        weatherService.fetchWeatherData(lat: latitude, lon: longitude, units: units) { [weak self] result in
            self?.handleWeatherResult(result)
        }
    }
    
    // Performs the network request for weather data based on city name
    private func fetchWeatherData(cityName: String, completion: ((Result<WeatherData, WeatherServiceError>) -> Void)? = nil) {
        let units = UserPreferences.loadUnits()
        weatherService.fetchWeatherData(cityName: cityName, units: units) { [weak self] result in
            self?.handleWeatherResult(result)
            completion?(result)
        }
    }
    
    // Handles the result of a weather data fetch request
    private func handleWeatherResult(_ result: Result<WeatherData, WeatherServiceError>) {
        DispatchQueue.main.async {
            self.isLoading = false
            switch result {
            case .success(let weather):
                self.updateWeatherData(with: weather, isOffline: false)
                self.userPreferences.saveLastWeatherFetchTime()
                self.userPreferences.saveCachedWeatherData(weather)
            case .failure(let error):
                self.handleWeatherServiceError(error)
                self.isOffline = true
                if let cachedData = self.userPreferences.getCachedWeatherData() {
                    self.weatherData = cachedData
                }
            }
        }
    }
    
    // Updates the weather data and connectivity status
    private func updateWeatherData(with data: WeatherData, isOffline: Bool) {
        weatherData = data
        self.isOffline = isOffline
    }
    
    // Clears previous weather data and resets the loading state
    private func resetWeatherState() {
        weatherData = nil
        errorMessage = nil
        isLoading = true
    }
    
    // Checks whether cached data is valid and returns it if available
    private func shouldUseCachedData() -> WeatherData? {
        guard let lastFetchTime = userPreferences.getLastWeatherFetchTime(),
              let cachedData = userPreferences.getCachedWeatherData(),
              Date().timeIntervalSince1970 - lastFetchTime < cacheDuration else {
            return nil
        }
        return cachedData
    }
    
    // Handles any errors returned by the WeatherService and sets the error message
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
    
    // MARK: - CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            let currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            if self.isForceRefresh {
                self.forceFetchCurrentLocation(location: location.coordinate)
                self.aqiViewModel.forceFetchAQIData(for: currentLocation)
                print("Force Fetching")
            } else {
                print("Not force fetching")
                self.fetchWeather(for: location.coordinate)
                self.aqiViewModel.fetchAQIData(for: currentLocation)
            }
            
            self.isForceRefresh = false
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.locationDenied = true
                self.errorMessage = "Location access is denied. Please enable it in Settings."
            }
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to get user location: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.errorMessage = "Unable to get your location. Please try again later."
        }
    }
    
    private func getCoordinateFromAddress(_ address: String, completion: @escaping (CLLocation?) -> Void) {
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            if error != nil {
                print("error: \(error as Optional)")
            } else {
                if let placemark = placemarks?.first,
                   let coord = placemark.location?.coordinate {
                    return completion(CLLocation(latitude: coord.latitude, longitude: coord.longitude))
                }
            }
            return completion(nil)
        }
    }
}
