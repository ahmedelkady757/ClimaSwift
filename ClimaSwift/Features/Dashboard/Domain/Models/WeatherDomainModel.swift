//
//  WeatherDomainModel.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Foundation

struct WeatherDomainModel {
    let locationName: String
    let localtime: String       // City's wall-clock time from API, e.g. "2024-01-15 22:30"
    let temperature: Double
    let conditionText: String
    let conditionIconURL: String
    let maxTemp: Double
    let minTemp: Double
    let visibility: Double
    let humidity: Int
    let feelsLike: Double
    let pressure: Double
    let forecast: [ForecastDayModel]
}

struct ForecastDayModel: Identifiable, Hashable {
    let id = UUID()
    let date: String
    let iconURL: String
    let minTemp: Double
    let maxTemp: Double
    let avgTemp: Double
    let conditionText: String
    let windSpeed: Double
    let precipitation: Double
    let humidity: Int
    let uvIndex: Double
    let hourlyForecast: [HourlyForecastDomainModel]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ForecastDayModel, rhs: ForecastDayModel) -> Bool {
        lhs.id == rhs.id
    }
}

protocol WeatherRepositoryInterface {
    func getCurrentWeather(lat: Double, lon: Double) async throws -> WeatherDomainModel
}
