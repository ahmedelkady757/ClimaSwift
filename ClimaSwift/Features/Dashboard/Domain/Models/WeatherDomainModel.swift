//
//  WeatherDomainModel.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Foundation

struct WeatherDomainModel {
    let locationName: String
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

struct ForecastDayModel: Identifiable {
    let id = UUID()
    let date: String
    let iconURL: String
    let minTemp: Double
    let maxTemp: Double
}

protocol WeatherRepositoryInterface {
    func getCurrentWeather(lat: Double, lon: Double) async throws -> WeatherDomainModel
}
