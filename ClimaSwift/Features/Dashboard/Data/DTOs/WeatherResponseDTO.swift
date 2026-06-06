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
    let localtime: String   // e.g. "2024-01-15 22:30" — city's wall-clock time
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
    let hour: [HourDTO]
}

struct DayDTO: Decodable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let avgtemp_c: Double
    let maxwind_kph: Double
    let totalprecip_mm: Double
    let avghumidity: Double
    let uv: Double
    let condition: ConditionDTO
}
