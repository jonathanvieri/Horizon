//
//  TemperatureInfoView.swift
//  Horizon
//
//  Created by Jonathan Vieri on 23/10/24.
//

import SwiftUI

struct TemperatureInfoView: View {
    let maxTemp: String
    let minTemp: String
    let feelsLike: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .foregroundStyle(K.DarkColors.gray)
                .frame(height: 125)
                .shadow(radius: 4)
                .padding(.horizontal, 16)
                .opacity(0.9)
            
            // Temperature Info Values
            HStack (spacing: 40) {
                TemperatureInfoItem(symbol: "thermometer.high", value: "\(maxTemp)°", label: "Max Temp")
                TemperatureInfoItem(symbol: "thermometer.low", value: "\(minTemp)°", label: "Min Temp")
                TemperatureInfoItem(symbol: "thermometer.variable.and.figure", value: "\(feelsLike)°", label: "Feels Like")
            }
        }
    }
}

//MARK: - Temperature Info Item
struct TemperatureInfoItem: View {
    var symbol: String
    var value: String
    var label: String
    
    private let iconSize: CGFloat = 40
    
    var body: some View {
        VStack {
            Image(systemName: symbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(K.DarkColors.blue)
            
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white)
                .opacity(0.80)
        }
    }
}

#Preview {
    TemperatureInfoView(maxTemp: "32", minTemp: "21", feelsLike: "24")
}
