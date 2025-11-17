import Foundation

class Venue: Feature<Venue.Properties> {
    struct Properties: Codable {
        let category: String
    }
    
    var levelsByOrdinal: [Int: [Level]] = [:]
}
