import Foundation

protocol RemoteSearchDataSourceProtocol {
    func searchLocations(query: String) async throws -> [SearchResponseDTO]
}

final class RemoteSearchDataSource: RemoteSearchDataSourceProtocol {
    private let networkClient: NetworkClientProtocol
    private let apiKey = "71defb2970cc479db84110601242611" // From Roadmap

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func searchLocations(query: String) async throws -> [SearchResponseDTO] {
        return try await networkClient.request(SearchEndpoint.search(query: query, apiKey: apiKey))
    }
}
