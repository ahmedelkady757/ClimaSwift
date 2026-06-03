//
//  GetCurrentWeatherUseCase.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Foundation

protocol GetCurrentWeatherUseCaseProtocol {
    func execute(lat: Double, lon: Double) async throws -> WeatherDomainModel
}

class GetCurrentWeatherUseCase: GetCurrentWeatherUseCaseProtocol {
    private let repository: WeatherRepositoryInterface
    
    init(repository: WeatherRepositoryInterface) {
        self.repository = repository
    }
    
    func execute(lat: Double, lon: Double) async throws -> WeatherDomainModel {
        return try await repository.getCurrentWeather(lat: lat, lon: lon)
    }
}
