//
//  DailyForecastView.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 02/06/2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct DailyForecastView: View {
    let day: ForecastDayModel
    let theme: ThemeType
    
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            // Background
            AnimatedBackgroundView(theme: theme)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Header Section
                    VStack(spacing: 15) {
                        Text(formattedDate)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(theme.foregroundColor)
                        
                        WebImage(url: URL(string: day.iconURL)) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            Image(systemName: "cloud.sun.fill")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: 100, height: 100)
                        
                        Text("\(Int(day.avgTemp))°")
                            .font(.system(size: 72, weight: .thin, design: .rounded))
                            .foregroundColor(theme.foregroundColor)
                        
                        Text(day.conditionText)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(theme.foregroundColor.opacity(0.9))
                        
                        HStack(spacing: 20) {
                            Label("\(Int(day.maxTemp))°", systemImage: "arrow.up")
                            Label("\(Int(day.minTemp))°", systemImage: "arrow.down")
                        }
                        .font(.headline)
                        .foregroundColor(theme.foregroundColor.opacity(0.8))
                    }
                    .padding(.top, 20)
                    .scaleEffect(isVisible ? 1 : 0.9)
                    .opacity(isVisible ? 1 : 0)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("DAILY SUMMARY")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(theme.foregroundColor.opacity(0.6))
                                Text(day.conditionText)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(theme.foregroundColor)
                            }
                            Spacer()
                            Image(systemName: "sparkles")
                                .font(.title)
                                .foregroundColor(.yellow.opacity(0.8))
                        }
                        .padding()
                        .background(theme.cardBackground)
                        .cornerRadius(20)
                        .padding(.horizontal)

                        // Metrics Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            CompactMetricTile(title: "WIND", value: "\(Int(day.windSpeed)) km/h", icon: "wind", theme: theme)
                            CompactMetricTile(title: "HUMIDITY", value: "\(day.humidity)%", icon: "humidity.fill", theme: theme)
                            CompactMetricTile(title: "PRECIP", value: "\(day.precipitation) mm", icon: "drop.fill", theme: theme)
                            CompactMetricTile(title: "UV INDEX", value: "\(Int(day.uvIndex))", icon: "sun.max.fill", theme: theme)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("HOURLY FORECAST")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(theme.foregroundColor.opacity(0.6))
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(day.hourlyForecast) { hour in
                                    HourlyForecastRow(hour: hour, theme: theme)
                                    if hour.id != day.hourlyForecast.last?.id {
                                        Divider()
                                            .background(theme.foregroundColor.opacity(0.1))
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(theme.cardBackground)
                            )
                            .padding(.horizontal)
                        }
                    }
                    .offset(y: isVisible ? 0 : 50)
                    .opacity(isVisible ? 1 : 0)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(theme == .evening ? .dark : .light, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: day.date) else { return day.date }
        let display = DateFormatter()
        display.dateFormat = "EEEE, MMMM d"
        return display.string(from: date)
    }
}

private struct HourlyForecastRow: View {
    let hour: HourlyForecastDomainModel
    let theme: ThemeType
    
    var body: some View {
        HStack(spacing: 12) {
            // Time
            Text(formattedTime)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(theme.foregroundColor)
                .frame(width: 60, alignment: .leading)
            
            // Condition icon
            WebImage(url: URL(string: hour.conditionIconURL)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "cloud.fill")
                    .foregroundColor(theme.foregroundColor.opacity(0.4))
            }
            .frame(width: 50, height: 50)
            
            // Temperature
            Text("\(Int(hour.tempC))°")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.foregroundColor)
                .frame(width: 44, alignment: .leading)
            
            Spacer(minLength: 4)
            
            // Trailing: rain badge stacked above condition text — no overflow
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(hour.chanceOfRain)%")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    hour.chanceOfRain > 0
                        ? Color(red: 0.13, green: 0.53, blue: 0.95).opacity(0.9)
                        : Color.white.opacity(0.15)
                )
                .clipShape(Capsule())
                
                Text(hour.conditionText)
                    .font(.system(size: 11))
                    .foregroundColor(theme.foregroundColor.opacity(0.7))
                    .lineLimit(1)
                    .frame(maxWidth: 110, alignment: .trailing)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = formatter.date(from: hour.time) else { return hour.time }
        let display = DateFormatter()
        display.dateFormat = "h a"
        return display.string(from: date)
    }
}

private struct CompactMetricTile: View {
    let title: String
    let value: String
    let icon: String
    let theme: ThemeType
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(theme.foregroundColor.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(theme.foregroundColor.opacity(0.5))
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.foregroundColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(theme.cardBackground)
        )
    }
}
