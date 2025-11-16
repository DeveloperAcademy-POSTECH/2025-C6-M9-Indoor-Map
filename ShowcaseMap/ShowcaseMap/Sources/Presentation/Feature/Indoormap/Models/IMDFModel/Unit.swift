import Foundation

class Unit: Feature<Unit.Properties> {
    struct Properties: Codable {
        let category: String
        let levelId: UUID
    }
    
    var occupants: [Occupant] = []
    var amenities: [Amenity] = []
}
