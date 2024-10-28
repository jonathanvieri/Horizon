//
//  AQIInfoView.swift
//  Horizon
//
//  Created by Jonathan Vieri on 25/10/24.
//

import SwiftUI

struct AQIInfoView: View {
    @ObservedObject var aqiViewModel: AQIViewModel
    
    var body: some View {
        ZStack {
            // Frame background
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .foregroundStyle(K.DarkColors.gray)
                .frame(height: 125)
                .shadow(radius: 4)
                .padding(.horizontal, 16)
                .opacity(0.9)
            
            HStack(spacing: 8) {
                AQIValueBadge(value: aqiViewModel.aqiValue, color: aqiViewModel.aqiColor)
                
                // Air Quality Description
                Text("Air Quality is ")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white)
                +
                Text(aqiViewModel.aqiDescription)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(aqiViewModel.aqiColor)
                
                Spacer()
                
                // Navigation Link with Arrow Icon
                NavigationLink(destination: AQIDetailView(aqiViewModel: aqiViewModel)) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                        .padding(.trailing, 8)
                }
            }
            .padding(.horizontal, 32)
        }
        
    }
}

//MARK: - AQI Value Badge
struct AQIValueBadge : View {
    var value: Int
    var color: Color
    private let badgeSize: CGFloat = 80
    private let fontSize: CGFloat = 32
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .foregroundStyle(color)
                .frame(width: badgeSize, height: badgeSize)
            
            Text("\(value)")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    let aqiViewModel = AQIViewModel()
    aqiViewModel.aqiValue = 5
    aqiViewModel.aqiDescription = "Moderate"
    aqiViewModel.aqiColor = K.AQIColors.green
    return AQIInfoView(aqiViewModel: aqiViewModel)
}
