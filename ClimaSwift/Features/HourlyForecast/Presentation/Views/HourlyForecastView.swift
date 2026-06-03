//
//  HourlyForecastView.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 02/06/2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct HourlyForecastView: View {
    @StateObject private var viewModel: HourlyForecastViewModel
    @StateObject private var themeEngine: DynamicThemeEngine

    let lat: Double
    let lon: Double

    init(lat: Double = 30.0444, lon: Double = 31.2357) {
        self.lat = lat
        self.lon = lon
        let container = DependencyContainer.shared.container
        _themeEngine = StateObject(wrappedValue: container.resolve(DynamicThemeEngine.self)!)
        _viewModel = StateObject(wrappedValue: container.resolve(HourlyForecastViewModel.self)!)
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

            case .success(let hours):
                HourlyContentView(hours: hours, theme: themeEngine.currentTheme)
            }
        }
        .navigationTitle("Hourly Forecast")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(themeEngine.currentTheme == .evening ? .dark : .light, for: .navigationBar)
        .task {
            await viewModel.fetchHourlyForecast(lat: lat, lon: lon)
        }
    }
}

private struct HourlyContentView: View {
    let hours: [HourlyForecastDomainModel]
    let theme: ThemeType

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(hours) { hour in
                        HourlyStripCard(hour: hour, theme: theme)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color.white.opacity(0.1))

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(hours.enumerated()), id: \.element.id) { index, hour in
                        HourlyDetailRow(hour: hour, theme: theme)
                        if index < hours.count - 1 {
                            Divider()
                                .background(theme.foregroundColor.opacity(0.2))
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

private struct HourlyStripCard: View {
    let hour: HourlyForecastDomainModel
    let theme: ThemeType

    var body: some View {
        VStack(spacing: 6) {
            Text(formattedTime)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.foregroundColor.opacity(0.7))

            WebImage(url: URL(string: hour.conditionIconURL)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "cloud.fill")
                    .foregroundColor(theme.foregroundColor.opacity(0.4))
            }
            .frame(width: 36, height: 36)

            Text("\(Int(hour.tempC))°")
                .font(.headline)
                .foregroundColor(theme.foregroundColor)

            if hour.chanceOfRain > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill").font(.system(size: 9))
                    Text("\(hour.chanceOfRain)%").font(.caption2)
                }
                .foregroundColor(.blue.opacity(0.8))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .frame(minWidth: 60)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = formatter.date(from: hour.time) else { return hour.time }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            if calendar.component(.hour, from: date) == calendar.component(.hour, from: Date()) {
                return "Now"
            }
        }
        let display = DateFormatter()
        display.dateFormat = "h a"
        return display.string(from: date)
    }
}

private struct HourlyDetailRow: View {
    let hour: HourlyForecastDomainModel
    let theme: ThemeType

    var body: some View {
        HStack(spacing: 12) {
            Text(formattedTime)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 52, alignment: .leading)
                .foregroundColor(theme.foregroundColor)

            WebImage(url: URL(string: hour.conditionIconURL)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "cloud.fill")
                    .foregroundColor(theme.foregroundColor.opacity(0.4))
            }
            .frame(width: 28, height: 28)

            Text("\(Int(hour.tempC))°")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(width: 44, alignment: .leading)
                .foregroundColor(theme.foregroundColor)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "thermometer.medium").font(.caption2)
                    Text("Feels \(Int(hour.feelsLikeC))°").font(.caption)
                }
                HStack(spacing: 4) {
                    Image(systemName: "humidity.fill").font(.caption2)
                    Text("\(hour.humidity)%").font(.caption)
                }
            }
            .foregroundColor(theme.foregroundColor.opacity(0.7))

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "wind").font(.caption2)
                    Text("\(Int(hour.windKph)) km/h").font(.caption)
                }
                if hour.chanceOfRain > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill").font(.caption2)
                        Text("\(hour.chanceOfRain)%").font(.caption)
                    }
                    .foregroundColor(.blue.opacity(0.85))
                }
            }
            .foregroundColor(theme.foregroundColor.opacity(0.7))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = formatter.date(from: hour.time) else { return hour.time }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            if calendar.component(.hour, from: date) == calendar.component(.hour, from: Date()) {
                return "Now"
            }
        }
        let display = DateFormatter()
        display.dateFormat = "h a"
        return display.string(from: date)
    }
}
