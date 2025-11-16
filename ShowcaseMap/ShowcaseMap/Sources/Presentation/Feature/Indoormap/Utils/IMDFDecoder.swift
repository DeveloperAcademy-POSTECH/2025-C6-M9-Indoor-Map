import Foundation
import MapKit

protocol IMDFDecodableFeature {
    init(feature: MKGeoJSONFeature) throws
}

enum IMDFError: Error {
    case invalidType
    case invalidData
}

private struct IMDFArchive {
    let baseDirectory: URL
    init(directory: URL) {
        baseDirectory = directory
    }
    
    enum File {
        case address
        case amenity
        case anchor
        case building
        case detail
        case fixture
        case footprint
        case geofence
        case kiosk
        case level
        case manifest
        case occupant
        case opening
        case relationship
        case section
        case unit
        case venue
        
        var filename: String {
            return "\(self).geojson"
        }
    }
    
    func fileURL(for file: File) -> URL {
        return baseDirectory.appendingPathComponent(file.filename)
    }
}

class IMDFDecoder {
    private let geoJSONDecoder = MKGeoJSONDecoder()
    func decode(_ imdfDirectory: URL) throws -> Venue {
        let archive = IMDFArchive(directory: imdfDirectory)

        let venues = try decodeFeatures(Venue.self, from: .venue, in: archive)
        let levels = try decodeFeatures(Level.self, from: .level, in: archive)
        let units = try decodeFeatures(Unit.self, from: .unit, in: archive)
        let openings = (try? decodeFeatures(Opening.self, from: .opening, in: archive)) ?? []
        let amenities = (try? decodeFeatures(Amenity.self, from: .amenity, in: archive)) ?? []

        guard venues.count == 1 else {
            throw IMDFError.invalidData
        }
        let venue = venues[0]
        venue.levelsByOrdinal = Dictionary(grouping: levels, by: { $0.properties.ordinal })

        let unitsByLevel = Dictionary(grouping: units, by: { $0.properties.levelId })
        let openingsByLevel = Dictionary(grouping: openings, by: { $0.properties.levelId })

        for level in levels {
            if let unitsInLevel = unitsByLevel[level.identifier] {
                level.units = unitsInLevel
            }
            if let openingsInLevel = openingsByLevel[level.identifier] {
                level.openings = openingsInLevel
            }
        }

        let unitsById = units.reduce(into: [UUID: Unit]()) {
            $0[$1.identifier] = $1
        }

        for amenity in amenities {
            guard let pointGeometry = amenity.geometry[0] as? MKPointAnnotation else {
                continue
            }

            if let name = amenity.properties.name?.bestLocalizedValue {
                amenity.title = name
                amenity.subtitle = amenity.properties.category.capitalized
            } else {
                amenity.title = amenity.properties.category.capitalized
            }

            for unitID in amenity.properties.unitIds {
                let unit = unitsById[unitID]
                unit?.amenities.append(amenity)
            }

            amenity.coordinate = pointGeometry.coordinate
        }

        try? decodeOccupants(units: units, in: archive)

        return venue
    }
    
    private func decodeOccupants(units: [Unit], in archive: IMDFArchive) throws {
        let occupants = try decodeFeatures(Occupant.self, from: .occupant, in: archive)
        let anchors = try decodeFeatures(Anchor.self, from: .anchor, in: archive)
        let unitsById = units.reduce(into: [UUID: Unit]()) {
            $0[$1.identifier] = $1
        }
        let anchorsById = anchors.reduce(into: [UUID: Anchor]()) {
            $0[$1.identifier] = $1
        }
        
        for occupant in occupants {
            guard let anchor = anchorsById[occupant.properties.anchorId] else {
                throw IMDFError.invalidData
            }
            
            guard let pointGeometry = anchor.geometry[0] as? MKPointAnnotation else {
                throw IMDFError.invalidData
            }
            occupant.coordinate = pointGeometry.coordinate
            
            if let name = occupant.properties.name.bestLocalizedValue {
                occupant.title = name
                occupant.subtitle = occupant.properties.category.capitalized
            } else {
                occupant.title = occupant.properties.category.capitalized
            }
            
            guard let unit = unitsById[anchor.properties.unitId] else {
                continue
            }
            
            unit.occupants.append(occupant)
            occupant.unit = unit
        }
    }
    
    private func decodeFeatures<T: IMDFDecodableFeature>(_ type: T.Type, from file: IMDFArchive.File, in archive: IMDFArchive) throws -> [T] {
        let fileURL = archive.fileURL(for: file)
        let data = try Data(contentsOf: fileURL)
        let geoJSONFeatures = try geoJSONDecoder.decode(data)
        guard let features = geoJSONFeatures as? [MKGeoJSONFeature] else {
            throw IMDFError.invalidType
        }
        
        let imdfFeatures = try features.map { try type.init(feature: $0) }
        return imdfFeatures
    }
}

