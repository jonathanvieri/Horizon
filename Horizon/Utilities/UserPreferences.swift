//
//  UserPreferences.swift
//  Horizon
//
//  Created by Jonathan Vieri on 24/10/24.
//

import Foundation

class UserPreferences {
    
    //MARK: - Keys
    private static let lastWeatherFetchTimeKey = "lastWeatherFetchTime"
    private static let cachedWeatherDataKey = "cachedWeatherData"
    private static let lastAQIFetchTimeKey = "lastAQIFetchTime"
    private static let cachedAQIDataKey = "cachedAQIData"
    
    private static let defaultCityKey = "defaultCity"
    private static let unitsKey = "units"
    private static let notificationsEnabledKey = "notificationsEnabled"
    private static let notificationTimeKey = "notificationTime"
    
    //MARK: - Fetch Times
    func saveLastWeatherFetchTime() {
        saveCurrentTime(for: UserPreferences.lastWeatherFetchTimeKey)
    }
    
    func getLastWeatherFetchTime() -> Double? {
        return UserDefaults.standard.double(forKey: UserPreferences.lastWeatherFetchTimeKey)
    }
    
    func saveLastAQIFetchTime() {
        saveCurrentTime(for: UserPreferences.lastAQIFetchTimeKey)
    }
    
    func getLastAQIFetchTime() -> Double? {
        return UserDefaults.standard.double(forKey: UserPreferences.lastAQIFetchTimeKey)
    }
    
    //MARK: - Cached Data
    func saveCachedWeatherData(_ data: WeatherData) {
        saveData(data, forKey: UserPreferences.cachedWeatherDataKey)
    }
    
    func getCachedWeatherData() -> WeatherData? {
        return getData(forKey: UserPreferences.cachedWeatherDataKey)
    }
    
    func saveCachedAQIData(_ data: AQIData) {
        saveData(data, forKey: UserPreferences.cachedAQIDataKey)
    }
    
    func getCachedAQIData() -> AQIData? {
        return getData(forKey: UserPreferences.cachedAQIDataKey)
    }
    
    //MARK: - City Preferences
    static func saveDefaultCity(cityName: String) {
        UserDefaults.standard.set(cityName, forKey: defaultCityKey)
    }
    
    static func loadDefaultCity() -> String? {
        return UserDefaults.standard.string(forKey: defaultCityKey)
    }
    
    static func clearDefaultCity() {
        UserDefaults.standard.removeObject(forKey: defaultCityKey)
    }
    
    //MARK: - Units of Measurement Preferences
    static func saveUnits(_ units: String) {
        UserDefaults.standard.set(units, forKey: unitsKey)
    }
    
    static func loadUnits() -> String {
        return UserDefaults.standard.string(forKey: unitsKey) ?? "metric"
    }
    
    //MARK: - Push Notifications Preferences
    static func saveNotificationPreference(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: notificationsEnabledKey)
    }
    
    static func loadNotificationPreference() -> Bool {
        UserDefaults.standard.bool(forKey: notificationsEnabledKey)
    }
    
    static func saveNotificationDailyTime(_ date: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: date)
        UserDefaults.standard.set(timeString, forKey: notificationTimeKey)
    }
    
    static func loadNotificationDailyTime() -> Date {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if let timeString = UserDefaults.standard.string(forKey: notificationTimeKey),
           let date = formatter.date(from: timeString) {
            return date
        }
        return Date()
    }
    
    //MARK: - Helper Methods
    private func saveCurrentTime(for key: String) {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: key)
    }
    
    private func saveData<T: Encodable>(_ data: T, forKey key: String) {
        if let encodedData = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedData, forKey: key)
        }
    }
    
    private func getData<T: Decodable>(forKey key: String) -> T? {
        if let savedData = UserDefaults.standard.data(forKey: key) {
            return try? JSONDecoder().decode(T.self, from: savedData)
        }
        return nil
    }
}
