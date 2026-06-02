//
//  GetWeatherDashboardDataUseCase.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Foundation

protocol GetWeatherDashboardDataUseCaseProtocol {
    func execute(lat: Double, lon: Double) async throws -> WeatherDomainModel
}

class GetWeatherDashboardDataUseCase: GetWeatherDashboardDataUseCaseProtocol {
    private let repository: WeatherRepositoryInterface
    
    init(repository: WeatherRepositoryInterface) {
        self.repository = repository
    }
    
    func execute(lat: Double, lon: Double) async throws -> WeatherDomainModel {
        return try await repository.getCurrentWeather(lat: lat, lon: lon)
    }
}
