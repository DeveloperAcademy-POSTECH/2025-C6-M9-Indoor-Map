import MapKit

protocol StylableFeature {
    var geometry: [MKShape & MKGeoJSONObject] { get }
    func configure(overlayRenderer: MKOverlayPathRenderer)
    func configure(annotationView: MKAnnotationView)
}

extension StylableFeature {
    func configure(overlayRenderer: MKOverlayPathRenderer) {}
    func configure(annotationView: MKAnnotationView) {}
}

extension Level: StylableFeature {
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor(named: "LevelStroke")
        overlayRenderer.lineWidth = 2.0
    }
}

extension Unit: StylableFeature {
    private enum StylableCategory: String {
        case elevator
        case escalator
        case stairs
        case restroom
        case restroomMale = "restroom.male"
        case restroomFemale = "restroom.female"
        case room
        case nonpublic
        case walkway
    }
    
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .elevator, .escalator, .stairs:
                overlayRenderer.fillColor = UIColor(named: "ElevatorFill")
            case .restroom, .restroomMale, .restroomFemale:
                overlayRenderer.fillColor = UIColor(named: "RestroomFill")
            case .room:
                overlayRenderer.fillColor = UIColor(named: "RoomFill")
            case .nonpublic:
                overlayRenderer.fillColor = UIColor(named: "NonPublicFill")
            case .walkway:
                overlayRenderer.fillColor = UIColor(named: "WalkwayFill")
            }
        } else {
            overlayRenderer.fillColor = UIColor(named: "DefaultUnitFill")
        }

        overlayRenderer.strokeColor = UIColor(named: "UnitStroke")
        overlayRenderer.lineWidth = 1.3
    }
}

extension Opening: StylableFeature {
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor(named: "WalkwayFill")
        overlayRenderer.lineWidth = 2.0
    }
}

extension Amenity: StylableFeature {
    private enum StylableCategory: String {
        case exhibit
    }
    
    func configure(annotationView: MKAnnotationView) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .exhibit:
                annotationView.backgroundColor = UIColor(named: "ExhibitFill")
            }
        } else {
            annotationView.backgroundColor = UIColor(named: "DefaultAmenityFill")
        }
        annotationView.displayPriority = .defaultLow
    }
}

extension Occupant: StylableFeature {
    private enum StylableCategory: String {
        case restaurant
        case shopping
    }

    func configure(annotationView: MKAnnotationView) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .restaurant:
                annotationView.backgroundColor = UIColor(named: "RestaurantFill")
            case .shopping:
                annotationView.backgroundColor = UIColor(named: "ShoppingFill")
            }
        }

        annotationView.displayPriority = .defaultHigh
    }
}
