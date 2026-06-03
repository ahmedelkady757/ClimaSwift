//
//  DependencyContainer.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Swinject

class DependencyContainer {
    static let shared = DependencyContainer()
    let container = Container()

    private init() {
        registerDependencies()
    }

    private func registerDependencies() {
        // Core
        container.register(DynamicThemeEngine.self) { _ in
            DynamicThemeEngine()
        }.inObjectScope(.container)

        container.register(NetworkClientProtocol.self) { _ in
            NetworkClient.shared
        }.inObjectScope(.container)

        // API Configuration
        let apiKey = "71defb2970cc479db84110601242611"

        // Features - Dashboard
        container.register(RemoteWeatherDataSource.self) { resolver in
            RemoteWeatherDataSource(
                networkClient: resolver.resolve(NetworkClientProtocol.self)!,
                apiKey: apiKey
            )
        }.inObjectScope(.transient)

        container.register(WeatherRepositoryInterface.self) { resolver in
            WeatherRepositoryImpl(
                remoteDataSource: resolver.resolve(RemoteWeatherDataSource.self)!
            )
        }.inObjectScope(.transient)

        container.register(GetWeatherDashboardDataUseCaseProtocol.self) { resolver in
            GetWeatherDashboardDataUseCase(
                repository: resolver.resolve(WeatherRepositoryInterface.self)!
            )
        }.inObjectScope(.transient)

        container.register(DashboardViewModel.self) { resolver in
            DashboardViewModel(
                getWeatherDashboardDataUseCase: resolver.resolve(GetWeatherDashboardDataUseCaseProtocol.self)!
            )
        }.inObjectScope(.transient)

        container.register(RemoteHourlyForecastDataSource.self) { resolver in
            RemoteHourlyForecastDataSource(
                networkClient: resolver.resolve(NetworkClientProtocol.self)!,
                apiKey: apiKey
            )
        }.inObjectScope(.transient)

        container.register(HourlyForecastRepositoryInterface.self) { resolver in
            HourlyForecastRepositoryImpl(
                remoteDataSource: resolver.resolve(RemoteHourlyForecastDataSource.self)!
            )
        }.inObjectScope(.transient)

        container.register(GetHourlyForecastUseCaseProtocol.self) { resolver in
            GetHourlyForecastUseCase(
                repository: resolver.resolve(HourlyForecastRepositoryInterface.self)!
            )
        }.inObjectScope(.transient)

        container.register(HourlyForecastViewModel.self) { resolver in
            HourlyForecastViewModel(
                getHourlyForecastUseCase: resolver.resolve(GetHourlyForecastUseCaseProtocol.self)!
            )
        }.inObjectScope(.transient)
    }
}
