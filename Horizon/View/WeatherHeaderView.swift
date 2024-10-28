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
    
    // Computed Properties
    private var icon: String {
        switch id {
        case 200...232: return "cloud.bolt.rain.fill"
        case 300...321: return "cloud.drizzle.fill"
        case 500...531: return "cloud.rain.fill"
        case 600...622: return "cloud.snow.fill"
        case 701...781: return "cloud.fog.fill"
        case 800: return "sun.max.fill"
        case 801...804: return "cloud.fill"
        default: return "cloud.fill"
        }
    }
    
    private var iconColor: Color {
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
    
    private var currentDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: Date())
    }
    
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
                Text("\(currentDate)")
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
                        Image(systemName: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(iconColor)
                        
                        Text("\(description)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        
    }
}

#Preview {
    WeatherHeaderView(name: "Jakarta",temp: "30°", id: 500, description: "Thunderstorm with Light Drizzle")
}
