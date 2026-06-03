//
//  HourlyForecastDomainModel.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 02/06/2026.
//

import Foundation

struct HourlyForecastDomainModel: Identifiable {
    let id = UUID()
    let time: String
    let tempC: Double
    let conditionText: String
    let conditionIconURL: String
    let feelsLikeC: Double
    let humidity: Int
    let chanceOfRain: Int
    let windKph: Double
    let isDay: Int
}

protocol HourlyForecastRepositoryInterface {
    func getHourlyForecast(lat: Double, lon: Double) async throws -> [HourlyForecastDomainModel]
}
