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
                localtime: dto.location.localtime,
                temperature: dto.current.temp_c,
                conditionText: dto.current.condition.text,
                conditionIconURL: "https:\(dto.current.condition.icon)",
                maxTemp: dto.forecast.forecastday.first?.day.maxtemp_c ?? 0,
                minTemp: dto.forecast.forecastday.first?.day.mintemp_c ?? 0,
                visibility: dto.current.vis_km,
                humidity: dto.current.humidity,
                feelsLike: dto.current.feelslike_c,
                pressure: dto.current.pressure_mb,
                forecast: dto.forecast.forecastday.map { dayDTO in
                    ForecastDayModel(
                        date: dayDTO.date,
                        iconURL: "https:\(dayDTO.day.condition.icon)",
                        minTemp: dayDTO.day.mintemp_c,
                        maxTemp: dayDTO.day.maxtemp_c,
                        avgTemp: dayDTO.day.avgtemp_c,
                        conditionText: dayDTO.day.condition.text,
                        windSpeed: dayDTO.day.maxwind_kph,
                        precipitation: dayDTO.day.totalprecip_mm,
                        humidity: Int(dayDTO.day.avghumidity),
                        uvIndex: dayDTO.day.uv,
                        hourlyForecast: dayDTO.hour.map { hourDTO in
                            HourlyForecastDomainModel(
                                time: hourDTO.time,
                                tempC: hourDTO.temp_c,
                                conditionText: hourDTO.condition.text,
                                conditionIconURL: "https:\(hourDTO.condition.icon)",
                                feelsLikeC: hourDTO.feelslike_c,
                                humidity: hourDTO.humidity,
                                chanceOfRain: hourDTO.chance_of_rain,
                                windKph: hourDTO.wind_kph,
                                isDay: hourDTO.is_day
                            )
                        }
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
