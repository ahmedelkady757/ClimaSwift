//
//  DashboardView.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct DashboardView: View {
    @StateObject private var themeEngine = DynamicThemeEngine()
    
    var body: some View {
        ZStack {
            // Background
            themeEngine.currentTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Top Division: Current Weather
                VStack(spacing: 8) {
                    Text("Cairo")
                        .font(.system(size: 32, weight: .medium))
                    
                    Text("21°")
                        .font(.system(size: 72, weight: .thin))
                    
                    Text("Partly Cloudy")
                        .font(.title3)
                    
                    Text("H:16° L:6°")
                        .font(.headline)
                    
                    // Adaptive Icon (Placeholder)
                    Image(systemName: "cloud.sun.fill")
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                }
                .foregroundColor(themeEngine.currentTheme.foregroundColor)
                .padding(.top, 40)
                
                Spacer()
                
                // Middle Division: 3-Day Forecast (Placeholder for Sprint 3)
                VStack(alignment: .leading, spacing: 12) {
                    Text("3-DAY FORECAST")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Divider()
                        .background(themeEngine.currentTheme.foregroundColor.opacity(0.3))
                    
                    ForEach(0..<3) { _ in
                        HStack {
                            Text("Today")
                                .frame(width: 80, alignment: .leading)
                            Spacer()
                            Image(systemName: "sun.max.fill")
                                .symbolRenderingMode(.multicolor)
                            Spacer()
                            Text("7.8° - 15.5°")
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .foregroundColor(themeEngine.currentTheme.foregroundColor)
                .padding(.horizontal)
                
                // Bottom Division: 4-Metric Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    MetricTile(title: "VISIBILITY", value: "10 km", theme: themeEngine.currentTheme)
                    MetricTile(title: "HUMIDITY", value: "36%", theme: themeEngine.currentTheme)
                    MetricTile(title: "FEELS LIKE", value: "16°", theme: themeEngine.currentTheme)
                    MetricTile(title: "PRESSURE", value: "1,021", theme: themeEngine.currentTheme)
                }
                .padding()
            }
        }
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let theme: ThemeType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
            Text(value)
                .font(.title2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .foregroundColor(theme.foregroundColor)
    }
}

#Preview {
    DashboardView()
}
