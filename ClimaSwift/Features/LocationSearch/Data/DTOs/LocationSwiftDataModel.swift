import Foundation
import SwiftData

@Model
final class LocationSwiftDataModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var region: String
    var country: String
    var latitude: Double
    var longitude: Double
    var addedAt: Date

    init(name: String, region: String, country: String, latitude: Double, longitude: Double) {
        self.id = UUID()
        self.name = name
        self.region = region
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.addedAt = Date()
    }
}
