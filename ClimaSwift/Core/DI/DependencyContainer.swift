//
//  DependencyContainer.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import Swinject
import SwiftData

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

        // Features - Location Search
        container.register(ModelContainer.self) { _ in
            let schema = Schema([LocationSwiftDataModel.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try! ModelContainer(for: schema, configurations: [config])
        }.inObjectScope(.container)

        container.register(LocalLocationDataSourceProtocol.self) { resolver in
            LocalLocationDataSource(modelContainer: resolver.resolve(ModelContainer.self)!)
        }.inObjectScope(.container)

        container.register(RemoteSearchDataSourceProtocol.self) { resolver in
            RemoteSearchDataSource(networkClient: resolver.resolve(NetworkClientProtocol.self)!)
        }.inObjectScope(.transient)

        container.register(LocationRepositoryInterface.self) { resolver in
            LocationRepositoryImpl(
                remoteDataSource: resolver.resolve(RemoteSearchDataSourceProtocol.self)!,
                localDataSource: resolver.resolve(LocalLocationDataSourceProtocol.self)!
            )
        }.inObjectScope(.transient)

        container.register(SearchLocationUseCaseProtocol.self) { resolver in
            SearchLocationUseCase(repository: resolver.resolve(LocationRepositoryInterface.self)!)
        }.inObjectScope(.transient)

        container.register(ManageSavedLocationsUseCaseProtocol.self) { resolver in
            ManageSavedLocationsUseCase(repository: resolver.resolve(LocationRepositoryInterface.self)!)
        }.inObjectScope(.transient)

        container.register(SearchViewModel.self) { resolver in
            SearchViewModel(
                searchUseCase: resolver.resolve(SearchLocationUseCaseProtocol.self)!,
                manageSavedUseCase: resolver.resolve(ManageSavedLocationsUseCaseProtocol.self)!
            )
        }.inObjectScope(.transient)

        container.register(SavedLocationsViewModel.self) { resolver in
            SavedLocationsViewModel(
                manageSavedUseCase: resolver.resolve(ManageSavedLocationsUseCaseProtocol.self)!
            )
        }.inObjectScope(.transient)
    }
}
