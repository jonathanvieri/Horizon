//
//  SettingsView.swift
//  Horizon
//
//  Created by Jonathan Vieri on 25/10/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var units: String = UserPreferences.loadUnits()
    @State private var notificationsEnabled: Bool = UserPreferences.loadNotificationPreference()
    @State private var notificationDailyTime = UserPreferences.loadNotificationDailyTime()
    
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    
    
    // Customize Segmented Control Appearance
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .gray
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }
    
    var body: some View {
        ZStack {
            K.DarkColors.background
                .ignoresSafeArea(.all)
            
            Form {
                
                // Units of Measurement
                Section {
                    Picker(selection: $units) {
                        Text("Metric").tag("metric")
                        Text("Imperial").tag("imperial")
                    } label: {
                        Text("Units")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: units) { oldValue, newValue in
                        UserPreferences.saveUnits(newValue)
                    }
                } header: {
                    Text("Units of Measurement")
                }
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .bold))
                .listRowBackground(K.DarkColors.background)
                
                
                // Push Notifications
                Section {
                    Picker(selection: $notificationsEnabled) {
                        Text("Off").tag(false)
                        Text("On").tag(true)
                    } label: {
                        Text("Push Notifications")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: notificationsEnabled) { oldValue, newValue in
                        UserPreferences.saveNotificationPreference(newValue)
                        
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            // Remove scheduled notification when user disables it
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["horizonDailyWeatherNotification"])
                            print("Daily notification removed.")
                        }
                    }
                } header: {
                    Text("Push Notifications")
                }
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .bold))
                .listRowBackground(K.DarkColors.background)
                
                
                // Conditionally show notification setup
                if notificationsEnabled {
                    
                    Section {
                        DatePicker("Notify me at", selection: $notificationDailyTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                            .colorScheme(.dark)
                            .onChange(of: notificationDailyTime) { oldValue, newValue in
                                UserPreferences.saveNotificationDailyTime(newValue)
                                scheduleDailyNotification(at: newValue)
                            }
                    } header: {
                        Text("Daily Notification Settings")
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .bold))
                    .listRowBackground(K.DarkColors.background)
                    
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    // Method for requesting user permission to Push Notifications and Always use location authorization
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let error = error {
                print("Error occured when requesting permission: \(error.localizedDescription)")
                return
            }
            
            // If user grants notification permission
            if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    weatherViewModel.requestAlwaysAuthorization()
                }
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    // Method for scheduling daily notification
    private func scheduleDailyNotification(at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Weather Update"
        content.body = "Check your daily weather now!"
        
        // Construct the content body using user's data
        if let defaultCity = UserPreferences.loadDefaultCity() {
            fetchWeatherDataForNotification(city: defaultCity) { weatherText in
                content.body = weatherText
                content.sound = .default
                
                // Create trigger for the notification
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: time)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                // Create unique identifier for the notification
                let request = UNNotificationRequest(identifier: "horizonDailyWeatherNotification", content: content, trigger: trigger)
                
                // Add the notification request
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    } else {
                        print("Daily notification successfully scheduled for: \(time)")
                    }
                }
            }
        }
    }
    
    // Helper method for fetching weather data for notification
    private func fetchWeatherDataForNotification(city: String, completion: @escaping (String) -> Void) {
        weatherViewModel.fetchWeather(for: city) { result in
            
            switch result {
            case .success(let weather):
                let weatherDescription = weather.weather[0].description.capitalized
                let temperature = Int(weather.main.temp)
                let formattedText = "Today's weather for \(city) will be \(weatherDescription) with a temperature of \(temperature)°C."
                completion(formattedText)
            case .failure(let error):
                print("Failed to fetch weather data: \(error)")
                let fallbackText = "Check today's weather in the Horizon app1"
                completion(fallbackText)
            }
        }
    }
    
}



#Preview {
    SettingsView()
}
