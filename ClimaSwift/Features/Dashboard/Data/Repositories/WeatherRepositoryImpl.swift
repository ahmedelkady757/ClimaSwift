//
//  WeatherRepositoryImpl.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Foundation

class WeatherRepositoryImpl: WeatherRepositoryInterface {
    private let remoteDataSource: RemoteWeatherDataSource
    
    init(remoteDataSource: RemoteWeatherDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func getCurrentWeather(lat: Double, lon: Double) async throws -> WeatherDomainModel {
        do {
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
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error.localizedDescription)
        }
    }
}
