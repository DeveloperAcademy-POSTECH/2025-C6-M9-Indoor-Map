//
//  IndoorMapViewModel.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

@MainActor
class IndoorMapViewModel: ObservableObject {
    @Published var venue: Venue?
    @Published var levels: [Level] = []
    @Published var currentLevelFeatures: [StylableFeature] = []
    @Published var currentLevelOverlays: [MKOverlay] = []
    @Published var currentLevelAnnotations: [MKAnnotation] = []
    @Published var region: MKMapRect = MKMapRect()
    @Published var selectedLevelIndex: Int = 0 {
        didSet {
            if selectedLevelIndex >= 0 && selectedLevelIndex < levels.count {
                let selectedLevel = levels[selectedLevelIndex]
                showFeaturesForOrdinal(selectedLevel.properties.ordinal)
            }
        }
    }
    @Published var selectedCategory: POICategory? = nil {
        didSet {
            if selectedLevelIndex >= 0 && selectedLevelIndex < levels.count {
                let selectedLevel = levels[selectedLevelIndex]
                showFeaturesForOrdinal(selectedLevel.properties.ordinal)
            }
        }
    }

    private let locationManager = CLLocationManager()

    init() {
        locationManager.requestWhenInUseAuthorization()
    }

    func loadIMDFData() {
        guard let imdfDirectory = Bundle.main.resourceURL?.appendingPathComponent("IMDFData") else {
            print("IMDF directory not found")
            return
        }

        do {
            let imdfDecoder = IMDFDecoder()
            venue = try imdfDecoder.decode(imdfDirectory)

            if let levelsByOrdinal = venue?.levelsByOrdinal {
                let processedLevels = levelsByOrdinal.mapValues { (levels: [Level]) -> [Level] in
                    if let level = levels.first(where: { $0.properties.outdoor == false }) {
                        return [level]
                    } else {
                        return [levels.first!]
                    }
                }.flatMap({ $0.value })

                let filteredLevels = processedLevels.filter { level in
                    level.properties.ordinal == 4 || level.properties.ordinal == 5
                }

                self.levels = filteredLevels.sorted(by: { $0.properties.ordinal > $1.properties.ordinal })
            }

            if let venue = venue, let venueOverlay = venue.geometry[0] as? MKOverlay {
                region = venueOverlay.boundingMapRect
            }

            if let level5 = levels.first(where: { $0.properties.ordinal == 4 }),
               let index = levels.firstIndex(of: level5) {
                selectedLevelIndex = index
                showFeaturesForOrdinal(4)
            } else if let firstLevel = levels.first {
                selectedLevelIndex = 0
                showFeaturesForOrdinal(firstLevel.properties.ordinal)
            }
        } catch {
            print("Error loading IMDF data: \(error)")
        }
    }

    private func showFeaturesForOrdinal(_ ordinal: Int) {
        guard venue != nil else {
            return
        }

        currentLevelFeatures.removeAll()
        currentLevelOverlays.removeAll()
        currentLevelAnnotations.removeAll()

        if let levels = venue?.levelsByOrdinal[ordinal] {
            for level in levels {
                currentLevelFeatures.append(level)
                currentLevelFeatures += level.units
                currentLevelFeatures += level.openings

                let occupants = level.units.flatMap({ $0.occupants })
                let amenities = level.units.flatMap({ $0.amenities })

                if let selectedCategory = selectedCategory {
                    let filteredAmenities = filterAmenities(amenities, for: selectedCategory)
                    let filteredUnits = filterUnits(level.units, for: selectedCategory)

                    currentLevelAnnotations += filteredAmenities
                    currentLevelAnnotations += filteredUnits
                } else {
                    currentLevelAnnotations += occupants
                    currentLevelAnnotations += amenities
                }
            }
        }

        let currentLevelGeometry = currentLevelFeatures.flatMap({ $0.geometry })
        currentLevelOverlays = currentLevelGeometry.compactMap({ $0 as? MKOverlay })
    }

    private func filterAmenities(_ amenities: [Amenity], for category: POICategory) -> [Amenity] {
        let amenityCategories = category.amenityCategories

        guard !amenityCategories.isEmpty else {
            return []
        }

        return amenities.filter { amenity in
            amenityCategories.contains(amenity.properties.category)
        }
    }

    private func filterUnits(_ units: [Unit], for category: POICategory) -> [MKAnnotation] {
        let unitCategories = category.unitCategories

        guard !unitCategories.isEmpty else {
            return []
        }

        let filteredUnits = units.filter { unit in
            unitCategories.contains(unit.properties.category)
        }

        return filteredUnits.compactMap { unit -> MKAnnotation? in
            guard let polygon = unit.geometry.first as? MKPolygon else {
                return nil
            }

            let centroid = calculateCentroid(of: polygon)
            let annotation = UnitAnnotation(coordinate: centroid, unit: unit)
            return annotation
        }
    }

    private func calculateCentroid(of polygon: MKPolygon) -> CLLocationCoordinate2D {
        let points = polygon.points()
        var x: Double = 0
        var y: Double = 0

        for i in 0..<polygon.pointCount {
            let point = points[i]
            x += point.x
            y += point.y
        }

        let centerPoint = MKMapPoint(x: x / Double(polygon.pointCount), y: y / Double(polygon.pointCount))
        return centerPoint.coordinate
    }
}

class UnitAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let unit: Unit
    let category: POICategory?

    init(coordinate: CLLocationCoordinate2D, unit: Unit) {
        self.coordinate = coordinate
        self.unit = unit
        self.category = POICategory.from(unitCategory: unit.properties.category)
        self.title = category?.rawValue ?? unit.properties.category
        super.init()
    }
}
