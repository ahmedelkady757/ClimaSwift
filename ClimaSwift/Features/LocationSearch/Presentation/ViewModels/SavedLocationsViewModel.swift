import Foundation

final class SavedLocationsViewModel: ObservableObject {
    @Published var savedLocations: [LocationDomainModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let manageSavedUseCase: ManageSavedLocationsUseCaseProtocol
    
    init(manageSavedUseCase: ManageSavedLocationsUseCaseProtocol) {
        self.manageSavedUseCase = manageSavedUseCase
    }
    
    @MainActor
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
    
    @MainActor
    func deleteLocation(byId id: UUID) async {
        do {
            try await manageSavedUseCase.deleteLocation(byId: id)
            await fetchSavedLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func saveLocation(_ location: LocationDomainModel) async {
        do {
            try await manageSavedUseCase.saveLocation(location)
            await fetchSavedLocations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
