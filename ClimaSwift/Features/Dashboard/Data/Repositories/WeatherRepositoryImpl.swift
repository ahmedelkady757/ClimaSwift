//
//  WeatherRepositoryImpl.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Foundation

class RemoteWeatherDataSource {
    private let networkClient: NetworkClientProtocol
    private let apiKey = "71defb2970cc479db84110601242611"
    
    init(networkClient: NetworkClientProtocol = NetworkClient.shared) {
        self.networkClient = networkClient
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponseDTO {
        let endpoint = WeatherEndpoint.forecast(lat: lat, lon: lon, days: 3, apiKey: apiKey)
        return try await networkClient.request(endpoint)
    }
}

class WeatherRepositoryImpl: WeatherRepositoryInterface {
    private let remoteDataSource: RemoteWeatherDataSource
    
    init(remoteDataSource: RemoteWeatherDataSource = RemoteWeatherDataSource()) {
        self.remoteDataSource = remoteDataSource
    }
    
    func getCurrentWeather(lat: Double, lon: Double) async throws -> WeatherDomainModel {
        let dto = try await remoteDataSource.fetchWeather(lat: lat, lon: lon)
        
        return WeatherDomainModel(
            locationName: dto.location.name,
            temperature: dto.current.temp_c,
            conditionText: dto.current.condition.text,
            conditionIconURL: "https:\(dto.current.condition.icon)",
            maxTemp: dto.forecast.forecastday.first?.day.maxtemp_c ?? 0,
            minTemp: dto.forecast.forecastday.first?.day.mintemp_c ?? 0,
            visibility: dto.current.vis_km,
            humidity: dto.current.humidity,
            feelsLike: dto.current.feelslike_c,
            pressure: dto.current.pressure_mb,
            forecast: dto.forecast.forecastday.map {
                ForecastDayModel(
                    date: $0.date,
                    iconURL: "https:\($0.day.condition.icon)",
                    minTemp: $0.day.mintemp_c,
                    maxTemp: $0.day.maxtemp_c
                )
            }
        )
    }
}
