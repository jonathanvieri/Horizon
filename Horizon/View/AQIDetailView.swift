//
//  AQIDetailView.swift
//  Horizon
//
//  Created by Jonathan Vieri on 25/10/24.
//

import SwiftUI

struct AQIDetailView: View {
    @ObservedObject var aqiViewModel: AQIViewModel
    
    var body: some View {
        
        ZStack {
            K.DarkColors.background
                .ignoresSafeArea(.all)
            
            VStack (spacing: 16) {
                
                // AQI Value
                Text("\(aqiViewModel.aqiValue)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(aqiViewModel.aqiColor)
                    .padding(.top, 8)
                
                Text(aqiViewModel.aqiDescription)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(aqiViewModel.aqiColor)
                    .padding(.bottom, 32)
                
                VStack (alignment: .leading, spacing: 12) {
                    Text("AQI Level Explanation")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.bottom, 8)
                    
                    ForEach(1...5, id: \.self) { level in
                        Text("\(level): \(aqiLevelExplanation(for: level))")
                            .font(.body)
                            .foregroundStyle(colorForAQILevel(for: level))
                            .lineSpacing(2)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(K.DarkColors.gray).opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
    
    // Method for providing explanation based on AQI level
    private func aqiLevelExplanation(for level: Int) -> String {
        switch level {
        case 1:
            return "Good - Minimal impact on health."
        case 2:
            return "Fair - Air quality is acceptable; some pollutants may affect very sensitive people."
        case 3:
            return "Moderate - Some individuals, especially those with respiratory issues, may experience discomfort."
        case 4:
            return "Poor - Increased likelihood of adverse effects, especially for sensitive groups."
        case 5:
            return "Very Poor - Health warnings for everyone; outdoor activities should be minimized."
        default:
            return "Unknown"
        }
    }
    
    // Function to return color based on AQI level
    private func colorForAQILevel(for level: Int) -> Color {
        switch level {
        case 1: return K.AQIColors.green
        case 2: return K.AQIColors.yellow
        case 3: return K.AQIColors.orange
        case 4: return K.AQIColors.red
        case 5: return K.AQIColors.purple
        default: return .gray
        }
    }
}

#Preview {
    let aqiViewModel = AQIViewModel()
    aqiViewModel.aqiValue = 2
    aqiViewModel.aqiDescription = "Fair"
    aqiViewModel.aqiColor = K.AQIColors.yellow
    return AQIDetailView(aqiViewModel: aqiViewModel)
}
