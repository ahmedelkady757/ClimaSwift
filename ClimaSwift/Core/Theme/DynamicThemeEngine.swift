//
//  DynamicThemeEngine.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import SwiftUI

enum ThemeType {
    case morning
    case evening
    
    var backgroundColor: Color {
        switch self {
        case .morning:
            return Color.blue.opacity(0.3) // Placeholder for actual background image logic
        case .evening:
            return Color.black.opacity(0.8)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .morning:
            return .black
        case .evening:
            return .white
        }
    }
    
    var backgroundImageName: String {
        switch self {
        case .morning:
            return "bg_morning"
        case .evening:
            return "bg_evening"
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
        if hour >= 5 && hour < 18 {
            currentTheme = .morning
        } else {
            currentTheme = .evening
        }
    }
}
