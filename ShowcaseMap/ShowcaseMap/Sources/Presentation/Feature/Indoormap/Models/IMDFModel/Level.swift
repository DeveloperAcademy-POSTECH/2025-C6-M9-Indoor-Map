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
