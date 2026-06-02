//
//  HourlyForecastView.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 02/06/2026.
//

import SwiftUI

struct HourlyForecastView: View {
    @StateObject private var themeEngine: DynamicThemeEngine

    private let hardcodedHours: [HardcodedHourModel] = [
        HardcodedHourModel(time: "Now",   icon: "sun.max.fill",         temp: 33, feelsLike: 35, humidity: 40, rain: 0,  wind: 12),
        HardcodedHourModel(time: "1 PM",  icon: "sun.max.fill",         temp: 34, feelsLike: 36, humidity: 38, rain: 0,  wind: 14),
        HardcodedHourModel(time: "2 PM",  icon: "cloud.sun.fill",       temp: 33, feelsLike: 35, humidity: 42, rain: 5,  wind: 15),
        HardcodedHourModel(time: "3 PM",  icon: "cloud.fill",           temp: 31, feelsLike: 33, humidity: 48, rain: 10, wind: 18),
        HardcodedHourModel(time: "4 PM",  icon: "cloud.drizzle.fill",   temp: 29, feelsLike: 30, humidity: 58, rain: 35, wind: 20),
        HardcodedHourModel(time: "5 PM",  icon: "cloud.rain.fill",      temp: 27, feelsLike: 28, humidity: 70, rain: 60, wind: 22),
        HardcodedHourModel(time: "6 PM",  icon: "cloud.rain.fill",      temp: 26, feelsLike: 27, humidity: 75, rain: 55, wind: 19),
        HardcodedHourModel(time: "7 PM",  icon: "cloud.fill",           temp: 25, feelsLike: 26, humidity: 65, rain: 20, wind: 16),
        HardcodedHourModel(time: "8 PM",  icon: "moon.stars.fill",      temp: 24, feelsLike: 25, humidity: 60, rain: 5,  wind: 13),
        HardcodedHourModel(time: "9 PM",  icon: "moon.fill",            temp: 23, feelsLike: 24, humidity: 58, rain: 0,  wind: 11),
        HardcodedHourModel(time: "10 PM", icon: "moon.fill",            temp: 23, feelsLike: 23, humidity: 57, rain: 0,  wind: 10),
        HardcodedHourModel(time: "11 PM", icon: "moon.fill",            temp: 22, feelsLike: 22, humidity: 55, rain: 0,  wind: 9),
    ]

    init() {
        let container = DependencyContainer.shared.container
        _themeEngine = StateObject(wrappedValue: container.resolve(DynamicThemeEngine.self)!)
    }

    var body: some View {
        ZStack {
            AnimatedBackgroundView(theme: themeEngine.currentTheme)

            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(hardcodedHours) { hour in
                            HourlyStripCard(hour: hour, theme: themeEngine.currentTheme)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.white.opacity(0.1))

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(hardcodedHours.enumerated()), id: \.element.id) { index, hour in
                            HourlyDetailRow(hour: hour, theme: themeEngine.currentTheme)
                            if index < hardcodedHours.count - 1 {
                                Divider()
                                    .background(themeEngine.currentTheme.foregroundColor.opacity(0.2))
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Hourly Forecast")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(themeEngine.currentTheme == .evening ? .dark : .light, for: .navigationBar)
    }
}

private struct HardcodedHourModel: Identifiable {
    let id = UUID()
    let time: String
    let icon: String
    let temp: Int
    let feelsLike: Int
    let humidity: Int
    let rain: Int
    let wind: Int
}

private struct HourlyStripCard: View {
    let hour: HardcodedHourModel
    let theme: ThemeType

    var body: some View {
        VStack(spacing: 6) {
            Text(hour.time)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.foregroundColor.opacity(0.7))

            Image(systemName: hour.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(theme.foregroundColor)

            Text("\(hour.temp)°")
                .font(.headline)
                .foregroundColor(theme.foregroundColor)

            if hour.rain > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill").font(.system(size: 9))
                    Text("\(hour.rain)%").font(.caption2)
                }
                .foregroundColor(.blue.opacity(0.85))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .frame(minWidth: 60)
    }
}

private struct HourlyDetailRow: View {
    let hour: HardcodedHourModel
    let theme: ThemeType

    var body: some View {
        HStack(spacing: 12) {
            Text(hour.time)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 52, alignment: .leading)
                .foregroundColor(theme.foregroundColor)

            Image(systemName: hour.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .foregroundColor(theme.foregroundColor)

            Text("\(hour.temp)°")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(width: 44, alignment: .leading)
                .foregroundColor(theme.foregroundColor)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "thermometer.medium").font(.caption2)
                    Text("Feels \(hour.feelsLike)°").font(.caption)
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
                    Text("\(hour.wind) km/h").font(.caption)
                }
                if hour.rain > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill").font(.caption2)
                        Text("\(hour.rain)%").font(.caption)
                    }
                    .foregroundColor(.blue.opacity(0.85))
                }
            }
            .foregroundColor(theme.foregroundColor.opacity(0.7))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
