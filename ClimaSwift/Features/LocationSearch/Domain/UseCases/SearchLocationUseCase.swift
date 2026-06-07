import Foundation

protocol SearchLocationUseCaseProtocol {
    func execute(query: String) async throws -> [LocationDomainModel]
}

final class SearchLocationUseCase: SearchLocationUseCaseProtocol {
    private let repository: LocationRepositoryInterface

    init(repository: LocationRepositoryInterface) {
        self.repository = repository
    }

    func execute(query: String) async throws -> [LocationDomainModel] {
        guard !query.isEmpty else { return [] }
        return try await repository.searchLocations(query: query)
    }
}
