//
//  DashboardViewModel.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Foundation

enum WeatherLoadingState {
    case idle
    case loading
    case success(WeatherDomainModel)
    case failure(String)
}

class DashboardViewModel: ObservableObject {
    @Published var loadingState: WeatherLoadingState = .idle
    @Published var forecast: [ForecastDayModel] = []

    private let getCurrentWeatherUseCase: GetCurrentWeatherUseCaseProtocol
    private let getForecastUseCase: GetForecastUseCaseProtocol

    init(
        getCurrentWeatherUseCase: GetCurrentWeatherUseCaseProtocol,
        getForecastUseCase: GetForecastUseCaseProtocol
    ) {
        self.getCurrentWeatherUseCase = getCurrentWeatherUseCase
        self.getForecastUseCase = getForecastUseCase
    }

    @MainActor
    func fetchWeather(lat: Double, lon: Double) async {
        loadingState = .loading
        do {
            async let weather = getCurrentWeatherUseCase.execute(lat: lat, lon: lon)
            async let forecastDays = getForecastUseCase.execute(lat: lat, lon: lon)
            let (fetchedWeather, fetchedForecast) = try await (weather, forecastDays)
            forecast = fetchedForecast
            loadingState = .success(fetchedWeather)
        } catch {
            loadingState = .failure(error.localizedDescription)
        }
    }
}
