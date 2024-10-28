//
//  ContentView.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    // ViewModel Instances
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var aqiViewModel = AQIViewModel()
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                K.DarkColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    connectionStatusView
                    
                    if weatherViewModel.isLoading {
                        ProgressView("Loading Weather Data...")
                            .foregroundStyle(.white)
                        
                    } else if let weather = weatherViewModel.weatherData {
                        weatherDataView(weather: weather)
                    } else if let errorMessage = weatherViewModel.errorMessage {
                        errorMessageView(errorMessage: errorMessage)
                    } else {
                        Text("Retrieving weather data...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
            }
            .toolbar {
                ToolbarItem (placement: .topBarLeading) {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.white)
                        .onTapGesture {
                            weatherViewModel.requestLocation()
                        }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack (spacing: 12) {
                        toolbarRefreshButton
                        toolbarSearchButton
                        toolbarSettingsButton
                    }
                }
                
            }
        }
       
        .onAppear {
            refreshData()
        }
    }
    
    //MARK: - Components
    
    // Shows a cached data message if user is offline
    private var connectionStatusView: some View {
        Group {
            if weatherViewModel.isOffline {
                Text("You are viewing cached data due to connectivity issues")
                    .foregroundStyle(.red)
                    .padding()
            }
        }
    }
    
    // Weather Data View
    private func weatherDataView(weather: WeatherData) -> some View {
        VStack (spacing: 20) {
            WeatherHeaderView(
                name: weather.name,
                temp: "\(Int(weather.main.temp))°",
                id: weather.weather[0].id,
                description: "\(weather.weather[0].description)".capitalized)
            
            TemperatureInfoView(
                maxTemp: "\(Int(weather.main.tempMax))",
                minTemp: "\(Int(weather.main.tempMin))",
                feelsLike: "\(Int(weather.main.feelsLike))"
            )
            
            WindSunInfoView(
                speed: weather.wind.speed,
                degree: weather.wind.deg,
                sunrise: weather.sys.sunrise,
                sunset: weather.sys.sunset,
                timezone: weather.timezone
            )
            
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
            if let location = weatherViewModel.userLocation {
                aqiViewModel.fetchAQIData(for: CLLocation(latitude: location.latitude, longitude: location.longitude))
            }
        }
    }
    
    // Error Message View
    private func errorMessageView(errorMessage: String) -> some View {
        VStack {
            Text(errorMessage)
                .font(.headline)
                .foregroundStyle(.red)
            
            Button {
                weatherViewModel.requestLocation()
            } label: {
                Text("Retry")
            }
        }
    }
    
    //MARK: - Toolbar
    private var toolbarRefreshButton: some View {
        Image(systemName: "arrow.clockwise")
            .foregroundStyle(.white)
            .onTapGesture {
                refreshData()
            }
    }
    
    private var toolbarSearchButton: some View {
        NavigationLink {
            SearchView()
                .onDisappear {
                    refreshData()
                }
        } label: {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white)
        }
    }
    
    private var toolbarSettingsButton: some View {
        NavigationLink {
            SettingsView()
                .environmentObject(weatherViewModel)
                .onDisappear {
                    refreshData()
                }
        } label: {
            Image(systemName: "gearshape.fill")
                .foregroundStyle(.white)
        }
    }
    
    //MARK: - Refresh Data
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

