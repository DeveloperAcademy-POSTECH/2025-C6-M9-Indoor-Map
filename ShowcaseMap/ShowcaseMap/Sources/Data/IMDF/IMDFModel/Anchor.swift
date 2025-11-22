import Foundation

class Anchor: Feature<Anchor.Properties> {
    struct Properties: Codable {
        let addressId: String?
        let unitId: UUID
    }
}
