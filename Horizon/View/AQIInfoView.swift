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
            // Rounded Rectangle which acts as the frame
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .foregroundStyle(K.DarkColors.gray)
                .frame(height: 125)
                .shadow(radius: 4)
                .padding(.horizontal, 16)
                .opacity(0.9)
            
            HStack(spacing: 8) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .foregroundStyle(aqiViewModel.aqiColor)
                        .frame(width: 80, height: 80)
                    
                    Text("\(aqiViewModel.aqiValue)")
                        .font(.system(size: 32, weight: .bold))
                }
                
                Text("Air Quality is ")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.white)
                +
                Text(aqiViewModel.aqiDescription)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(aqiViewModel.aqiColor)
                
                Spacer()
                
                // Arrow Icon
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

#Preview {
    let aqiViewModel = AQIViewModel()
    aqiViewModel.aqiValue = 3
    aqiViewModel.aqiDescription = "Moderate"
    aqiViewModel.aqiColor = K.AQIColors.green
    return AQIInfoView(aqiViewModel: aqiViewModel)
}
