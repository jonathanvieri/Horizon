//
//  UserPreferences.swift
//  Horizon
//
//  Created by Jonathan Vieri on 24/10/24.
//

import Foundation

class UserPreferences {
    
    // Default City location preferences
    static func saveDefaultCity(cityName: String) {
        UserDefaults.standard.set(cityName, forKey: "defaultCity")
    }
    
    static func loadDefaultCity() -> String? {
        return UserDefaults.standard.string(forKey: "defaultCity")
    }
    
    static func clearDefaultCity() {
        UserDefaults.standard.removeObject(forKey: "defaultCity")
    }
    
    // Units of Measurement preferences
    static func saveUnits(_ units: String) {
        UserDefaults.standard.set(units, forKey: "units")
    }
    
    static func loadUnits() -> String {
        return UserDefaults.standard.string(forKey: "units") ?? "metric"
    }
    
    // Push Notifications preferences
    static func saveNotificationPreference(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: "notificationsEnabled")
    }
    
    static func loadNotificationPreference() -> Bool {
        UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }
    
    // Daily notification time
    static func saveNotificationDailyTime(_ date: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: date)
        UserDefaults.standard.set(timeString, forKey: "notificationTime")
    }
    
    static func loadNotificationDailyTime() -> Date {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if let timeString = UserDefaults.standard.string(forKey: "notificationTime"),
           let date = formatter.date(from: timeString) {
            return date
        } else {
            return Date()
        }
    }
    
}
