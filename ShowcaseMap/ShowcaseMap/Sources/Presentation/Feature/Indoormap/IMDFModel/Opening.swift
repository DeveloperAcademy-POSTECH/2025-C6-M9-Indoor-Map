import Foundation

class Opening: Feature<Opening.Properties> {
    struct Properties: Codable {
        let category: String
        let levelId: UUID
    }
    
    var openings: [Opening] = []
}
