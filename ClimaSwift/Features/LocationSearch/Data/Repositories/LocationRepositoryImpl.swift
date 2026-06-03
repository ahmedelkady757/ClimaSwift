import Foundation

final class LocationRepositoryImpl: LocationRepositoryInterface {
    private let remoteDataSource: RemoteSearchDataSourceProtocol
    private let localDataSource: LocalLocationDataSourceProtocol

    init(remoteDataSource: RemoteSearchDataSourceProtocol, localDataSource: LocalLocationDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func searchLocations(query: String) async throws -> [LocationDomainModel] {
        let dtos = try await remoteDataSource.searchLocations(query: query)
        let savedLocations = try await localDataSource.getSavedLocations()
        
        return dtos.map { dto in
            let isSaved = savedLocations.contains { $0.latitude == dto.lat && $0.longitude == dto.lon }
            return LocationDomainModel(
                name: dto.name,
                region: dto.region,
                country: dto.country,
                latitude: dto.lat,
                longitude: dto.lon,
                isSaved: isSaved
            )
        }
    }

    func getSavedLocations() async throws -> [LocationDomainModel] {
        let models = try await localDataSource.getSavedLocations()
        return models.map { model in
            LocationDomainModel(
                id: model.id,
                name: model.name,
                region: model.region,
                country: model.country,
                latitude: model.latitude,
                longitude: model.longitude,
                isSaved: true
            )
        }
    }

    func saveLocation(_ location: LocationDomainModel) async throws {
        let model = LocationSwiftDataModel(
            name: location.name,
            region: location.region,
            country: location.country,
            latitude: location.latitude,
            longitude: location.longitude
        )
        try await localDataSource.saveLocation(model)
    }

    func deleteLocation(byId id: UUID) async throws {
        try await localDataSource.deleteLocation(byId: id)
    }
}
