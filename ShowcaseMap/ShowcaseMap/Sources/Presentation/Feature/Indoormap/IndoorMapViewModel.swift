//
//  IndoorMapViewModel.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/16/25.
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

                self.levels = processedLevels.sorted(by: { $0.properties.ordinal > $1.properties.ordinal })
            }

            if let venue = venue, let venueOverlay = venue.geometry[0] as? MKOverlay {
                region = venueOverlay.boundingMapRect
            }

            showFeaturesForOrdinal(0)

            if let baseLevel = levels.first(where: { $0.properties.ordinal == 0 }),
               let index = levels.firstIndex(of: baseLevel) {
                selectedLevelIndex = index
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
                currentLevelAnnotations += occupants
                currentLevelAnnotations += amenities
            }
        }

        let currentLevelGeometry = currentLevelFeatures.flatMap({ $0.geometry })
        currentLevelOverlays = currentLevelGeometry.compactMap({ $0 as? MKOverlay })
    }
}

