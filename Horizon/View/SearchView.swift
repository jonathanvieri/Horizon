//
//  SearchView.swift
//  Horizon
//
//  Created by Jonathan Vieri on 24/10/24.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var searchViewModel = SearchViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            K.DarkColors.background
                .ignoresSafeArea(.all)
            
            VStack (spacing: 16) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white)
                    TextField("",text: $searchViewModel.searchText,
                              prompt: Text("Search for a City").foregroundStyle(.gray)
                    )
                    .foregroundStyle(.white)
                    .onSubmit {
                        searchViewModel.searchWeather(for: searchViewModel.searchText)
                    }
                    
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(K.DarkColors.gray)
                        .shadow(radius: 10)
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Weather Details
                if searchViewModel.isLoading {
                    ProgressView("Loading...")
                        .foregroundStyle(.white)
                } else if let weather = searchViewModel.weatherData {
                    VStack (spacing: 48) {
                        SearchResultView(
                            name: weather.name,
                            temp: "\(Int(weather.main.temp))°",
                            id: weather.weather[0].id,
                            description: "\(weather.weather[0].description)".capitalized
                        )
                        .transition(.opacity)
                        .padding(.top, 16)
                        
                        Button {
                            UserPreferences.saveDefaultCity(cityName: weather.name)
                            dismiss()
                        } label: {
                            Text("Set as Default Location")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    
                }
                
                Spacer()
            }
            .alert(isPresented: $searchViewModel.hasError) {
                Alert(
                    title: Text("Error"),
                    message: Text(searchViewModel.errorMessage ?? "An unknown error occured"),
                    dismissButton: .default(Text("OK"))
                )
                
            }
        }
    }
}

struct SearchResultView: View {
    let name: String
    let temp: String
    let id: Int
    let description: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(colors: [K.DarkColors.gray, .black], startPoint: .topTrailing, endPoint: .bottomTrailing)
                )
                .foregroundStyle(K.DarkColors.gray)
                .frame(height: 150)
                .shadow(radius: 4)
                .padding(.horizontal, 16)
                .opacity(0.7)
            
            HStack (alignment: .center) {
                // City name and Temperature Info
                VStack (alignment: .leading) {
                    Text(name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                    
                    Text(temp)
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // Weather Symbol and Description
                VStack {
                    Image(systemName: getWeatherIcon(for: id))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundStyle(getWeatherIconColor(for: id))
                    
                    Text(description)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 48)
        }
    }
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
    SearchView()
}
