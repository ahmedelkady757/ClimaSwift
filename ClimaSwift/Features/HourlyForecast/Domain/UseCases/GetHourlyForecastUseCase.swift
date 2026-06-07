//
//  GetHourlyForecastUseCase.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 02/06/2026.
//

import Foundation

protocol GetHourlyForecastUseCaseProtocol {
    func execute(lat: Double, lon: Double) async throws -> [HourlyForecastDomainModel]
}

class GetHourlyForecastUseCase: GetHourlyForecastUseCaseProtocol {
    private let repository: HourlyForecastRepositoryInterface

    init(repository: HourlyForecastRepositoryInterface) {
        self.repository = repository
    }

    func execute(lat: Double, lon: Double) async throws -> [HourlyForecastDomainModel] {
        return try await repository.getHourlyForecast(lat: lat, lon: lon)
    }
}
