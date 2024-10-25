//
//  WeatherHeaderView.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import SwiftUI

struct WeatherHeaderView: View {
    let name: String
    let temp: String
    let id: Int
    let description: String
    
    var body: some View {
        ZStack {
            K.DarkColors.background.ignoresSafeArea(.all)
            
            VStack (spacing: 4) {
                
                // City Name
                Text("\(name)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 16)
                
                // Current date
                Text("\(getCurrentDate())")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .opacity(0.60)
                    .padding(.bottom, 8)
                
                HStack (alignment: .center, spacing: 24) {
                    // Temperature
                    Text("\(temp)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(.white)
                    
                    // Weather Icon with description
                    HStack {
                        Image(systemName: getWeatherIcon(for: id))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(getWeatherIconColor(for: id))
                        
                        Text("\(description)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        
    }
}

// Method for getting the formatted date for Today
private func getCurrentDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    
    let currentDate = Date()
    return dateFormatter.string(from: currentDate)
}

// Method for getting weather icon based on the id
private func getWeatherIcon(for id: Int) -> String {
    switch id {
    case 200...232: return "cloud.bolt.rain.fill"
    case 300...321: return "cloud.drizzle.fill"
    case 500...531: return "cloud.rain.fill"
    case 600...622: return "cloud.snow.fill"
    case 701...781: return "cloud.fog.fill"
    case 800: return "sun.max.fill"
    case 801...804: return "cloud.fill"
        
    default:
        return "cloud.fill"
    }
}

// Method for getting weather icon color based on the id
private func getWeatherIconColor(for id: Int) -> Color {
    switch id {
    case 200...232: return K.DarkColors.yellow
    case 300...321: return K.DarkColors.blue
    case 500...531: return K.DarkColors.blue.opacity(0.7)
    case 600...622: return K.DarkColors.white
    case 701...781: return .gray
    case 800: return K.DarkColors.yellow
    case 801...804: return .gray
    default: return .white
    }
}

#Preview {
    WeatherHeaderView(name: "Jakarta",temp: "30°", id: 500, description: "Thunderstorm with Light Drizzle")
}
