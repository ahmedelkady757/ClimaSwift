import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [LocationDomainModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let searchUseCase: SearchLocationUseCaseProtocol
    private let manageSavedUseCase: ManageSavedLocationsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(searchUseCase: SearchLocationUseCaseProtocol, manageSavedUseCase: ManageSavedLocationsUseCaseProtocol) {
        self.searchUseCase = searchUseCase
        self.manageSavedUseCase = manageSavedUseCase
        
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task { await self?.performSearch(query: query) }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func performSearch(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            searchResults = try await searchUseCase.execute(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func saveLocation(_ location: LocationDomainModel) async {
        do {
            try await manageSavedUseCase.saveLocation(location)
            if let index = searchResults.firstIndex(where: { $0.latitude == location.latitude && $0.longitude == location.longitude }) {
                var updated = searchResults[index]
                updated = LocationDomainModel(
                    id: updated.id,
                    name: updated.name,
                    region: updated.region,
                    country: updated.country,
                    latitude: updated.latitude,
                    longitude: updated.longitude,
                    isSaved: true
                )
                searchResults[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
