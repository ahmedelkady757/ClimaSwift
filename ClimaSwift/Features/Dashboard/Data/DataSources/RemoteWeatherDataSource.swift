//
//  RemoteWeatherDataSource.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Foundation

class RemoteWeatherDataSource {
    private let networkClient: NetworkClientProtocol
    private let apiKey: String
    
    init(networkClient: NetworkClientProtocol, apiKey: String) {
        self.networkClient = networkClient
        self.apiKey = apiKey
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponseDTO {
        let endpoint = WeatherEndpoint.forecast(lat: lat, lon: lon, days: 3, apiKey: apiKey)
        return try await networkClient.request(endpoint)
    }
}
