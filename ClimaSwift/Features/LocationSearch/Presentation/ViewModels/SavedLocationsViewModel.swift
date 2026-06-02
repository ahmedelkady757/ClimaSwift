import Foundation

@MainActor
final class SavedLocationsViewModel: ObservableObject {
    @Published var savedLocations: [LocationDomainModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let manageSavedUseCase: ManageSavedLocationsUseCaseProtocol
    
    init(manageSavedUseCase: ManageSavedLocationsUseCaseProtocol) {
        self.manageSavedUseCase = manageSavedUseCase
    }
    
    func fetchSavedLocations() async {
        isLoading = true
        errorMessage = nil
        do {
            savedLocations = try await manageSavedUseCase.getSavedLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func deleteLocation(byId id: UUID) async {
        do {
            try await manageSavedUseCase.deleteLocation(byId: id)
            await fetchSavedLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
