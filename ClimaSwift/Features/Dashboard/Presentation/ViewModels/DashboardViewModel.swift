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

    private let getWeatherDashboardDataUseCase: GetWeatherDashboardDataUseCaseProtocol

    init(getWeatherDashboardDataUseCase: GetWeatherDashboardDataUseCaseProtocol) {
        self.getWeatherDashboardDataUseCase = getWeatherDashboardDataUseCase
    }

    @MainActor
    func fetchWeather(lat: Double, lon: Double) async {
        loadingState = .loading
        do {
            let weather = try await getWeatherDashboardDataUseCase.execute(lat: lat, lon: lon)
            self.forecast = weather.forecast
            self.loadingState = .success(weather)
        } catch let error as AppError {
            self.loadingState = .failure(error.errorDescription ?? "An error occurred.")
        } catch {
            self.loadingState = .failure(error.localizedDescription)
        }
    }
}
