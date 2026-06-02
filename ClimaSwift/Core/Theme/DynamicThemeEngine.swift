//
//  DynamicThemeEngine.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import SwiftUI

enum ThemeType: Equatable {
    case morning
    case evening
    
    var foregroundColor: Color {
        switch self {
        case .morning:
            return .black
        case .evening:
            return .white
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
