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
        container.register(DynamicThemeEngine.self) { _ in
            DynamicThemeEngine()
        }.inObjectScope(.container)

        container.register(NetworkClientProtocol.self) { _ in
            NetworkClient.shared
        }.inObjectScope(.container)

        container.register(RemoteWeatherDataSource.self) { resolver in
            RemoteWeatherDataSource(networkClient: resolver.resolve(NetworkClientProtocol.self)!)
        }.inObjectScope(.transient)

        container.register(WeatherRepositoryInterface.self) { resolver in
            WeatherRepositoryImpl(
                remoteDataSource: resolver.resolve(RemoteWeatherDataSource.self)!
            )
        }.inObjectScope(.transient)

        container.register(GetCurrentWeatherUseCaseProtocol.self) { resolver in
            GetCurrentWeatherUseCase(
                repository: resolver.resolve(WeatherRepositoryInterface.self)!
            )
        }.inObjectScope(.transient)

        container.register(DashboardViewModel.self) { resolver in
            DashboardViewModel(
                getCurrentWeatherUseCase: resolver.resolve(GetCurrentWeatherUseCaseProtocol.self)!
            )
        }.inObjectScope(.transient)
    }
}
