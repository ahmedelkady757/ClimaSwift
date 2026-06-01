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

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var loadingState: WeatherLoadingState = .idle

    private let getCurrentWeatherUseCase: GetCurrentWeatherUseCaseProtocol

    init(getCurrentWeatherUseCase: GetCurrentWeatherUseCaseProtocol) {
        self.getCurrentWeatherUseCase = getCurrentWeatherUseCase
    }

    func fetchWeather(lat: Double, lon: Double) async {
        loadingState = .loading
        do {
            let weather = try await getCurrentWeatherUseCase.execute(lat: lat, lon: lon)
            loadingState = .success(weather)
        } catch {
            loadingState = .failure(error.localizedDescription)
        }
    }
}
