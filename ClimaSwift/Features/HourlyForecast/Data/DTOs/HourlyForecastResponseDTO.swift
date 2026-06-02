//
//  HourlyForecastResponseDTO.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 02/06/2026.
//

import Foundation

struct HourlyWeatherResponseDTO: Decodable {
    let location: HourlyLocationDTO
    let forecast: HourlyForecastContainerDTO
}

struct HourlyLocationDTO: Decodable {
    let name: String
}

struct HourlyForecastContainerDTO: Decodable {
    let forecastday: [HourlyForecastDayDTO]
}

struct HourlyForecastDayDTO: Decodable {
    let date: String
    let hour: [HourDTO]
}

struct HourDTO: Decodable {
    let time: String
    let temp_c: Double
    let condition: HourlyConditionDTO
    let feelslike_c: Double
    let humidity: Int
    let chance_of_rain: Int
    let wind_kph: Double
    let is_day: Int
}

struct HourlyConditionDTO: Decodable {
    let text: String
    let icon: String
}
