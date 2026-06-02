import Foundation

protocol ManageSavedLocationsUseCaseProtocol {
    func getSavedLocations() async throws -> [LocationDomainModel]
    func saveLocation(_ location: LocationDomainModel) async throws
    func deleteLocation(byId id: UUID) async throws
}

final class ManageSavedLocationsUseCase: ManageSavedLocationsUseCaseProtocol {
    private let repository: LocationRepositoryInterface

    init(repository: LocationRepositoryInterface) {
        self.repository = repository
    }

    func getSavedLocations() async throws -> [LocationDomainModel] {
        return try await repository.getSavedLocations()
    }

    func saveLocation(_ location: LocationDomainModel) async throws {
        try await repository.saveLocation(location)
    }

    func deleteLocation(byId id: UUID) async throws {
        try await repository.deleteLocation(byId: id)
    }
}
