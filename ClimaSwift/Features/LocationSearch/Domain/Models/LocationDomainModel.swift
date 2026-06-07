import Foundation

struct LocationDomainModel: Identifiable, Equatable {
    let id: UUID
    let name: String
    let region: String
    let country: String
    let latitude: Double
    let longitude: Double
    let isSaved: Bool
    
    init(id: UUID = UUID(), name: String, region: String, country: String, latitude: Double, longitude: Double, isSaved: Bool = false) {
        self.id = id
        self.name = name
        self.region = region
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.isSaved = isSaved
    }
}
