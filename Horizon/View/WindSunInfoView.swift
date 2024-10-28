//
//  WindSunInfoView.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import SwiftUI

struct WindSunInfoView: View {
    let speed: Double
    let degree: Int
    let sunrise: Double
    let sunset: Double
    let timezone: Int
    
    private var units: String {
        UserPreferences.loadUnits()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .foregroundStyle(K.DarkColors.gray)
                .frame(height: 250)
                .shadow(radius: 4)
                .padding(.horizontal, 16)
                .opacity(0.9)
            
            VStack (spacing: 30) {
                HStack {
                    WindSunInfoItem(
                        symbol: "wind.circle.fill",
                        value: formattedWindSpeed(),
                        label: "Wind Speed"
                    )
                    Spacer()
                    WindSunInfoItem(
                        symbol: "safari.fill",
                        value: "\(windDirection(for: degree))",
                        label: "Wind Direction")
                }
                .padding(.horizontal, 64)
                
                HStack {
                    WindSunInfoItem(
                        symbol: "sunrise.circle.fill",
                        value: "\(formatEpochIntoHour(for: sunrise, timezoneOffset: timezone))",
                        label: "Sunrise"
                    )
                    Spacer()
                    WindSunInfoItem(
                        symbol: "sunset.circle.fill",
                        value: "\(formatEpochIntoHour(for: sunset, timezoneOffset: timezone))",
                        label: "Sunset"
                    )
                }
                .padding(.horizontal, 64)
                
            }
        }
    }
    
    // Helper to format wind speed
    private func formattedWindSpeed() -> String {
        let speedInUnits = (units == "metric") ? speed * 3.6 : speed * 2.2369
        let unitLabel = (units == "metric") ? "km/h" : "mph"
        return String(format: "%.1f \(unitLabel)", speedInUnits)
    }
}

//MARK: - Item for displaying the Wind and Sun info
struct WindSunInfoItem: View {
    var symbol: String
    var value: String
    var label: String
    
    var body: some View {
        VStack {
            Image(systemName: symbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundStyle(K.DarkColors.blue)
                .padding(.bottom, 8)
            
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 120, alignment: .center)
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white)
                .opacity(0.80)
        }
    }
}

//MARK: - Helper Function
extension WindSunInfoView {
    
    func windDirection(for degree: Int) -> String {
        switch degree {
        case 0..<23:
            return "\(degree)° N"
        case 23..<45:
            return "\(degree)° NNE"
        case 45..<68:
            return "\(degree)° NE"
        case 68..<90:
            return "\(degree)° ENE"
        case 90..<113:
            return "\(degree)° E"
        case 113..<135:
            return "\(degree)° ESE"
        case 135..<158:
            return "\(degree)° SE"
        case 158..<180:
            return "\(degree)° SSE"
        case 180..<203:
            return "\(degree)° S"
        case 203..<225:
            return "\(degree)° SSW"
        case 225..<248:
            return "\(degree)° SW"
        case 248..<270:
            return "\(degree)° WSW"
        case 270..<293:
            return "\(degree)° W"
        case 293..<315:
            return "\(degree)° WNW"
        case 315..<338:
            return "\(degree)° NW"
        case 338..<360:
            return "\(degree)° NNW"
        default:
            return "N/A"
        }
    }
    
    // Method for formatting epoch double into "HH:mm" String format
    func formatEpochIntoHour(for epochTime: Double, timezoneOffset: Int) -> String {
        let date = Date(timeIntervalSince1970: epochTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        // Apply the timezone using offset from JSON
        let timezone = TimeZone(secondsFromGMT: timezoneOffset)
        formatter.timeZone = timezone
        
        return formatter.string(from: date)
    }
}

#Preview {
    WindSunInfoView(speed: 20, degree: 313, sunrise: 1729722512, sunset: 1729766744, timezone: 25200)
}
