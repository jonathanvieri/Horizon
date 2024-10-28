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
                AQIValueView(aqiValue: aqiViewModel.aqiValue, color: aqiViewModel.aqiColor, description: aqiViewModel.aqiDescription)
                
                AQILevelExplanationView()
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

//MARK: - AQI Value Display
struct AQIValueView: View {
    let aqiValue: Int
    let color: Color
    let description: String
    private let mainFontSize: CGFloat = 60
    private let descriptionFontSize: CGFloat = 24
    
    var body: some View {
        VStack {
            Text("\(aqiValue)")
                .font(.system(size: mainFontSize, weight: .bold))
                .foregroundStyle(color)
                .padding(.top, 8)
            
            Text(description)
                .font(.system(size: descriptionFontSize, weight: .medium))
                .foregroundStyle(color)
                .padding(.bottom, 32)
        }
    }
}

//MARK: - AQI Level Explanation Section
struct AQILevelExplanationView: View {
    var body: some View {
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
    }
}

// Provides an explanation based on AQI level
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

// Returns color based on AQI level
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

#Preview {
    let aqiViewModel = AQIViewModel()
    aqiViewModel.aqiValue = 2
    aqiViewModel.aqiDescription = "Fair"
    aqiViewModel.aqiColor = K.AQIColors.yellow
    return AQIDetailView(aqiViewModel: aqiViewModel)
}
