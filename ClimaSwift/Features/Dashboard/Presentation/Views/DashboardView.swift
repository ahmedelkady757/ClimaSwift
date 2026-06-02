//
//  DashboardView.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct DashboardView: View {
    @StateObject private var themeEngine: DynamicThemeEngine
    @StateObject private var viewModel: DashboardViewModel

    private let defaultLat: Double = 30.0444
    private let defaultLon: Double = 31.2357

    init() {
        let container = DependencyContainer.shared.container
        _themeEngine = StateObject(wrappedValue: container.resolve(DynamicThemeEngine.self)!)
        _viewModel = StateObject(wrappedValue: container.resolve(DashboardViewModel.self)!)
    }

    var body: some View {
        ZStack {
            AnimatedBackgroundView(theme: themeEngine.currentTheme)

            switch viewModel.loadingState {
            case .idle, .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: themeEngine.currentTheme.foregroundColor))
                    .scaleEffect(1.5)

            case .failure(let message):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                    Text(message)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .foregroundColor(themeEngine.currentTheme.foregroundColor)

            case .success(let weather):
                WeatherContentView(weather: weather, forecast: viewModel.forecast, theme: themeEngine.currentTheme)
            }
        }
        .task {
            await viewModel.fetchWeather(lat: defaultLat, lon: defaultLon)
        }
    }
}

private struct WeatherContentView: View {
    let weather: WeatherDomainModel
    let forecast: [ForecastDayModel]
    let theme: ThemeType

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(weather.locationName)
                    .font(.system(size: 32, weight: .medium))

                Text("\(Int(weather.temperature))°")
                    .font(.system(size: 72, weight: .thin))

                Text(weather.conditionText)
                    .font(.title3)

                Text("H:\(Int(weather.maxTemp))° L:\(Int(weather.minTemp))°")
                    .font(.headline)

                WebImage(url: URL(string: weather.conditionIconURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(theme.foregroundColor.opacity(0.4))
                }
                .frame(width: 80, height: 80)
            }
            .foregroundColor(theme.foregroundColor)
            .padding(.top, 40)

            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Text("3-DAY FORECAST")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Divider()
                    .background(theme.foregroundColor.opacity(0.3))

                ForEach(forecast) { day in
                    ForecastRowView(day: day, theme: theme)
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .foregroundColor(theme.foregroundColor)
            .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                MetricTile(title: "VISIBILITY", value: "\(Int(weather.visibility)) km", theme: theme)
                MetricTile(title: "HUMIDITY", value: "\(weather.humidity)%", theme: theme)
                MetricTile(title: "FEELS LIKE", value: "\(Int(weather.feelsLike))°", theme: theme)
                MetricTile(title: "PRESSURE", value: "\(Int(weather.pressure)) mb", theme: theme)
            }
            .padding()
        }
    }
}

private struct ForecastRowView: View {
    let day: ForecastDayModel
    let theme: ThemeType

    var body: some View {
        HStack {
            Text(formattedDay)
                .frame(width: 80, alignment: .leading)

            Spacer()

            WebImage(url: URL(string: day.iconURL)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Image(systemName: "cloud.fill")
                    .foregroundColor(theme.foregroundColor.opacity(0.4))
            }
            .frame(width: 28, height: 28)

            Spacer()

            Text("\(Int(day.minTemp))° - \(Int(day.maxTemp))°")
        }
        .padding(.horizontal)
    }

    private var formattedDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: day.date) else { return day.date }
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE" // Full day name (e.g., Wednesday)
            return dayFormatter.string(from: date)
        }
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let theme: ThemeType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(theme.foregroundColor.opacity(0.6))

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme.foregroundColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}
