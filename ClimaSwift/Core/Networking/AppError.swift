//
//  AppError.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Foundation

enum AppError: LocalizedError {
    case networkError(String)
    case decodingError
    case unauthorized
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .decodingError:
            return "Failed to process weather data."
        case .unauthorized:
            return "Invalid API Key. Please check your configuration."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}
