import Foundation

class Level: Feature<Level.Properties> {
    struct Properties: Codable {
        let ordinal: Int
        let category: String
        let shortName: LocalizedName
        let outdoor: Bool
        let buildingIds: [String]?
    }

    var units: [Unit] = []
    var openings: [Opening] = []
}

enum BuildingFloorID {
    static let L5 = "90005828-dce9-49ff-be8c-d392a8254e77"
    static let L6 = "87f7a8b3-0ccc-4a1e-86e4-1d9602dcb96f"
}
