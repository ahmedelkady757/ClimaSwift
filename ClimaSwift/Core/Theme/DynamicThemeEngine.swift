//
//  DynamicThemeEngine.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.


import SwiftUI

enum ThemeType: Equatable {
    case morning
    case evening

    /// Primary text / icon color — guaranteed readable on the new animated sky.
    var foregroundColor: Color {
        switch self {
        case .morning:
            return Color(red: 0.06, green: 0.13, blue: 0.28)
        case .evening:
            return Color(red: 0.97, green: 0.96, blue: 0.92)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .morning:
            return Color(red: 0.12, green: 0.22, blue: 0.42).opacity(0.75)
        case .evening:
            return Color(red: 0.97, green: 0.96, blue: 0.92).opacity(0.65)
        }
    }

    var cardBackground: Color {
        switch self {
        case .morning:
            return Color.white.opacity(0.28)
        case .evening:
            return Color.white.opacity(0.10)
        }
    }
}

class DynamicThemeEngine: ObservableObject {
    @Published var currentTheme: ThemeType = .morning

    init() {
        updateThemeFromDevice()   // sensible default before any city data arrives
    }

    /// Called once weather data loads — uses the **city's** wall-clock hour from the API.
    /// `localtime` format: "yyyy-MM-dd HH:mm"  (WeatherAPI standard)
    func updateTheme(for localtime: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = formatter.date(from: localtime) {
            let hour = Calendar.current.component(.hour, from: date)
            currentTheme = (hour >= 5 && hour < 18) ? .morning : .evening
        } else {
            updateThemeFromDevice()   // graceful fallback if parsing fails
        }
    }

    /// Fallback: uses the running device's local clock (only for initial state).
    private func updateThemeFromDevice() {
        let hour = Calendar.current.component(.hour, from: Date())
        currentTheme = (hour >= 5 && hour < 18) ? .morning : .evening
    }
}
