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
        updateTheme()
    }

    func updateTheme() {
        let hour = Calendar.current.component(.hour, from: Date())
        currentTheme = (hour >= 5 && hour < 18) ? .morning : .evening
    }
}
