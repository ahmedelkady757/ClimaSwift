import Foundation

protocol LocationRepositoryInterface {
    func searchLocations(query: String) async throws -> [LocationDomainModel]
    func getSavedLocations() async throws -> [LocationDomainModel]
    func saveLocation(_ location: LocationDomainModel) async throws
    func deleteLocation(byId id: UUID) async throws
}
