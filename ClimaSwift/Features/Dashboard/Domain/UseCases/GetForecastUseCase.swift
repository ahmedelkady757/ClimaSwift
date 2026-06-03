//
//  GetForecastUseCase.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//


import Foundation

protocol GetForecastUseCaseProtocol {
    func execute(lat: Double, lon: Double) async throws -> [ForecastDayModel]
}

class GetForecastUseCase: GetForecastUseCaseProtocol {
    private let repository: WeatherRepositoryInterface

    init(repository: WeatherRepositoryInterface) {
        self.repository = repository
    }

    func execute(lat: Double, lon: Double) async throws -> [ForecastDayModel] {
        let weather = try await repository.getCurrentWeather(lat: lat, lon: lon)
        return weather.forecast
    }
}
