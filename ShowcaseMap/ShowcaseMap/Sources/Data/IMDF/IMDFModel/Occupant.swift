import Foundation
import MapKit

class Occupant: Feature<Occupant.Properties>, MKAnnotation {
    struct Properties: Codable {
        let category: String
        let name: LocalizedName
        let anchorId: UUID
        let hours: String?
        let phone: String?
        let website: URL?
    }
    
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var title: String?
    var subtitle: String?
    weak var unit: Unit?
}
