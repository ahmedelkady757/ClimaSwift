import Foundation
import SwiftData

protocol LocalLocationDataSourceProtocol {
    func getSavedLocations() async throws -> [LocationSwiftDataModel]
    func saveLocation(_ location: LocationSwiftDataModel) async throws
    func deleteLocation(byId id: UUID) async throws
}

final class LocalLocationDataSource: LocalLocationDataSourceProtocol {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    func getSavedLocations() async throws -> [LocationSwiftDataModel] {
        let descriptor = FetchDescriptor<LocationSwiftDataModel>(sortBy: [SortDescriptor(\.addedAt, order: .reverse)])
        return try modelContainer.mainContext.fetch(descriptor)
    }

    @MainActor
    func saveLocation(_ location: LocationSwiftDataModel) async throws {
        modelContainer.mainContext.insert(location)
        try modelContainer.mainContext.save()
    }

    @MainActor
    func deleteLocation(byId id: UUID) async throws {
        let idString = id.uuidString // Workaround for Predicate macro limitations
        let descriptor = FetchDescriptor<LocationSwiftDataModel>()
        let locations = try modelContainer.mainContext.fetch(descriptor)
        if let locationToDelete = locations.first(where: { $0.id.uuidString == idString }) {
            modelContainer.mainContext.delete(locationToDelete)
            try modelContainer.mainContext.save()
        }
    }
}
