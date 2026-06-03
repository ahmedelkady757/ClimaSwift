//
//  RemoteHourlyForecastDataSource.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 02/06/2026.
//

import Foundation

class RemoteHourlyForecastDataSource {
    private let networkClient: NetworkClientProtocol
    private let apiKey: String

    init(networkClient: NetworkClientProtocol, apiKey: String) {
        self.networkClient = networkClient
        self.apiKey = apiKey
    }

    func fetchHourlyForecast(lat: Double, lon: Double) async throws -> HourlyWeatherResponseDTO {
        let endpoint = WeatherEndpoint.forecast(lat: lat, lon: lon, days: 2, apiKey: apiKey)
        return try await networkClient.request(endpoint)
    }
}
