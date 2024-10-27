//
//  ContentView.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    // Variables
    @StateObject var weatherViewModel = WeatherViewModel()
    @StateObject var aqiViewModel = AQIViewModel()
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                // Background Color
                K.DarkColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    if weatherViewModel.isOffline {
                        Text("You are viewing cached data due to connectivity issues")
                            .foregroundStyle(.red)
                            .padding()
                    }
                    
                    if weatherViewModel.isLoading {
                        ProgressView("Loading Weather Data...")
                            .foregroundStyle(.white)
                        
                    } else if let weather = weatherViewModel.weatherData {
                        
                        VStack (spacing: 20) {
                            // Weather Header View
                            WeatherHeaderView(
                                name: weather.name,
                                temp: "\(Int(weather.main.temp))°",
                                id: weather.weather[0].id,
                                description: "\(weather.weather[0].description)".capitalized)
                            
                            // Temp Info View
                            TemperatureInfoView(
                                maxTemp: "\(Int(weather.main.tempMax))",
                                minTemp: "\(Int(weather.main.tempMin))",
                                feelsLike: "\(Int(weather.main.feelsLike))"
                            )
                            
                            // Wind and Sun View
                            WindSunInfoView(
                                speed: weather.wind.speed,
                                degree: weather.wind.deg,
                                sunrise: weather.sys.sunrise,
                                sunset: weather.sys.sunset,
                                timezone: weather.timezone
                            )
                            
                            // AQI View
                            if aqiViewModel.isLoading {
                                ProgressView("Loading AQI Data...")
                                    .foregroundStyle(.white)
                            } else if aqiViewModel.hasError {
                                Text("Unable to retrieve AQI Data")
                                    .foregroundStyle(.red)
                            } else {
                                AQIInfoView(aqiViewModel: aqiViewModel)
                            }
                        }
                        .onAppear {
                            // Fetch AQI data after weather view appears and the location is set
                            if let location = weatherViewModel.userLocation {
                                aqiViewModel.fetchAQIData(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
                            }
                        }
                        
                        .toolbar {
                            // Location Icon
                            ToolbarItem (placement: .topBarLeading) {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(.white)
                                    .onTapGesture {
                                        weatherViewModel.requestLocation()
                                    }
                            }
                            
                            // Refresh Icon
                            ToolbarItem(placement: .topBarTrailing) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundStyle(.white)
                                    .onTapGesture {
                                        if let defaultCity = UserPreferences.loadDefaultCity() {
                                            weatherViewModel.fetchWeather(for: defaultCity)
                                        } else {
                                            weatherViewModel.requestLocation()
                                        }
                                    }
                            }
                            
                            // Search Icon
                            ToolbarItem(placement: .topBarTrailing) {
                                NavigationLink {
                                    SearchView()
                                        .onDisappear {
                                            if let defaultCity = UserPreferences.loadDefaultCity() {
                                                weatherViewModel.fetchWeather(for: defaultCity)
                                            } else {
                                                weatherViewModel.requestLocation()
                                            }
                                        }
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            // Settings Icon
                            ToolbarItem (placement: .topBarTrailing) {
                                NavigationLink {
                                    SettingsView()
                                        .environmentObject(weatherViewModel)
                                        .onDisappear {
                                            if let defaultCity = UserPreferences.loadDefaultCity() {
                                                weatherViewModel.fetchWeather(for: defaultCity)
                                            } else {
                                                weatherViewModel.requestLocation()
                                            }
                                        }
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    } else if let errorMessage = weatherViewModel.errorMessage {
                        // Show error message if there's an error
                        VStack {
                            Text(errorMessage)
                                .font(.headline)
                                .foregroundStyle(.red)
                            
                            Button("Retry") {
                                weatherViewModel.requestLocation()
                            }
                        }
                    } else {
                        // Default or Fallback state
                        Text("Retrieving weather data...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .onAppear {
            refreshData()
        }
    }
    
    private func refreshData() {
        if let defaultCity = UserPreferences.loadDefaultCity() {
            weatherViewModel.fetchWeather(for: defaultCity)
        } else {
            weatherViewModel.requestLocation()
        }
    }
}

#Preview {
    ContentView()
}

