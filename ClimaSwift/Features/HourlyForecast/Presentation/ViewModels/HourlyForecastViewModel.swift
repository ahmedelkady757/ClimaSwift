//
//  HourlyForecastViewModel.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 02/06/2026.
//

import Foundation

enum HourlyForecastLoadingState {
    case idle
    case loading
    case success([HourlyForecastDomainModel])
    case failure(String)
}

class HourlyForecastViewModel: ObservableObject {
    @Published var loadingState: HourlyForecastLoadingState = .idle

    private let getHourlyForecastUseCase: GetHourlyForecastUseCaseProtocol

    init(getHourlyForecastUseCase: GetHourlyForecastUseCaseProtocol) {
        self.getHourlyForecastUseCase = getHourlyForecastUseCase
    }

    @MainActor
    func fetchHourlyForecast(lat: Double, lon: Double) async {
        loadingState = .loading
        do {
            let hours = try await getHourlyForecastUseCase.execute(lat: lat, lon: lon)
            self.loadingState = .success(hours)
        } catch let error as AppError {
            self.loadingState = .failure(error.errorDescription ?? "An error occurred.")
        } catch {
            self.loadingState = .failure(error.localizedDescription)
        }
    }
}
