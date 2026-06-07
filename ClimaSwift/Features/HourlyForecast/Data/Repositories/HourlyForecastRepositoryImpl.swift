//
//  HourlyForecastRepositoryImpl.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 02/06/2026.
//

import Foundation

class HourlyForecastRepositoryImpl: HourlyForecastRepositoryInterface {
    private let remoteDataSource: RemoteHourlyForecastDataSource

    init(remoteDataSource: RemoteHourlyForecastDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func getHourlyForecast(lat: Double, lon: Double) async throws -> [HourlyForecastDomainModel] {
        do {
            let dto = try await remoteDataSource.fetchHourlyForecast(lat: lat, lon: lon)

            let allHours = dto.forecast.forecastday.flatMap { $0.hour }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let now = Date()

            let filtered = allHours.filter { hourDTO in
                guard let hourDate = formatter.date(from: hourDTO.time) else { return false }
                return hourDate >= now
            }

            let source = filtered.isEmpty ? allHours : filtered

            return source.prefix(24).map { hourDTO in
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
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error.localizedDescription)
        }
    }
}
