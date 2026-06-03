//
//  WeatherResponseDTO.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Foundation

struct WeatherResponseDTO: Decodable {
    let location: LocationDTO
    let current: CurrentWeatherDTO
    let forecast: ForecastDTO
}

struct LocationDTO: Decodable {
    let name: String
}

struct CurrentWeatherDTO: Decodable {
    let temp_c: Double
    let condition: ConditionDTO
    let vis_km: Double
    let humidity: Int
    let feelslike_c: Double
    let pressure_mb: Double
}

struct ConditionDTO: Decodable {
    let text: String
    let icon: String
}

struct ForecastDTO: Decodable {
    let forecastday: [ForecastDayDTO]
}

struct ForecastDayDTO: Decodable {
    let date: String
    let day: DayDTO
}

struct DayDTO: Decodable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let condition: ConditionDTO
}
