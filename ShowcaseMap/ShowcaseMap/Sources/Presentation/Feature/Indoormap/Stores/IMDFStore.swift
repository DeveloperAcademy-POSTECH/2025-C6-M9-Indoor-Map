//
//  IMDFStore.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/17/25.
//

import Foundation
import MapKit
import SwiftUI

@Observable
@MainActor
class IMDFStore {
    var venue: Venue?
    var levels: [Level] = []
    var mapPolygons: [MapPolygonData] = []
    var mapMarkers: [MapMarkerData] = []
    var fixtures: [Fixture] = []
    var amenities: [Amenity] = []

    private let imdfDecoder = IMDFDecoder()

    func loadIMDFData() {
        guard let imdfDirectory = Bundle.main.resourceURL?.appendingPathComponent("IMDFData") else {
            print("IMDF directory not found")
            return
        }

        do {
            venue = try imdfDecoder.decode(imdfDirectory)

            if let levelsByOrdinal = venue?.levelsByOrdinal {
                let processedLevels = levelsByOrdinal.mapValues { (levels: [Level]) -> [Level] in
                    if let level = levels.first(where: { $0.properties.outdoor == false }) {
                        return [level]
                    } else {
                        return [levels.first!]
                    }
                }.flatMap { $0.value }

                let filteredLevels = processedLevels.filter { level in
                    level.properties.ordinal == 4 || level.properties.ordinal == 5
                }

                levels = filteredLevels.sorted(by: { $0.properties.ordinal > $1.properties.ordinal })
            }

            loadFixtures()
            loadAllAmenities()
        } catch {
            print("load IMDF Error : \(error)")
        }
    }

    private func loadAllAmenities() {
        amenities = []

        guard let venue = venue else { return }

        for (_, levels) in venue.levelsByOrdinal {
            for level in levels {
                for unit in level.units {
                    for amenity in unit.amenities {
                        guard amenity.properties.category != "phone" else { continue }
                        amenities.append(amenity)
                    }
                }
            }
        }
    }

    func loadFixtures() {
        guard let fixtureURL = Bundle.main.url(forResource: "fixture", withExtension: "geojson", subdirectory: "IMDFData") else {
            return
        }

        do {
            let data = try Data(contentsOf: fixtureURL)
            let collection = try JSONDecoder().decode(FixtureCollection.self, from: data)
            fixtures = collection.features
        } catch {
            print("fixture로딩 에러 \(error)")
        }
    }

    func getMapData(for ordinal: Int, category: POICategory?) -> (polygons: [MapPolygonData], markers: [MapMarkerData]) {
        guard let levels = venue?.levelsByOrdinal[ordinal] else {
            return ([], [])
        }

        var polygons: [MapPolygonData] = []
        var markers: [MapMarkerData] = []

        for level in levels {
            // Level geometry를 polygon으로 변환
            for geometry in level.geometry {
                if let polygon = geometry as? MKPolygon {
                    polygons.append(createPolygonData(from: polygon, feature: level))
                } else if let multiPolygon = geometry as? MKMultiPolygon {
                    for poly in multiPolygon.polygons {
                        polygons.append(createPolygonData(from: poly, feature: level))
                    }
                }
            }

            // Units를 polygon으로 변환
            for unit in level.units {
                for geometry in unit.geometry {
                    if let polygon = geometry as? MKPolygon {
                        polygons.append(createPolygonData(from: polygon, feature: unit))
                    } else if let multiPolygon = geometry as? MKMultiPolygon {
                        for poly in multiPolygon.polygons {
                            polygons.append(createPolygonData(from: poly, feature: unit))
                        }
                    }
                }

                // Amenities를 마커로 추가
                let amenities = unit.amenities
//                let occupants = unit.occupants

                if let category = category {
                    // 카테고리 필터링 (폰부스 제외)
                    let filteredAmenities = amenities.filter { amenity in
                        category.amenityCategories.contains(amenity.properties.category) &&
                            amenity.properties.category != "phone"
                    }
                    for amenity in filteredAmenities {
                        if let markerData = createMarkerData(from: amenity, category: category) {
                            markers.append(markerData)
                        }
                    }
                } else {
                    // 모든 amenities와 occupants 표시 (phone 제외)
                    for amenity in amenities {
                        guard amenity.properties.category != "phone" else { continue }
                        if let amenityCategory = POICategory.from(amenityCategory: amenity.properties.category),
                           let markerData = createMarkerData(from: amenity, category: amenityCategory)
                        {
                            markers.append(markerData)
                        }
                    }
                }
            }

            // Openings를 polygon으로 변환
            for opening in level.openings {
                for geometry in opening.geometry {
                    if let polyline = geometry as? MKPolyline {
                        // Opening은 polyline이지만 polygon처럼 처리
                        let coordinates = extractCoordinates(from: polyline)
                        polygons.append(MapPolygonData(
                            coordinates: coordinates,
                            fillColor: .clear,
                            strokeColor: Color(uiColor: UIColor(named: "WalkwayFill") ?? .gray),
                            lineWidth: 2.0
                        ))
                    }
                }
            }
        }

        // Fixtures를 polygon으로 변환
        let currentLevelId = levels.first?.identifier.uuidString.lowercased()

        for fixture in fixtures {
            guard fixture.levelId.lowercased() == currentLevelId else { continue }

            if let firstPolygon = fixture.geometry.coordinates.first,
               let firstRing = firstPolygon.first
            {
                let coordinates = firstRing.map { point in
                    CLLocationCoordinate2D(latitude: point[1], longitude: point[0])
                }
                polygons.append(MapPolygonData(
                    coordinates: coordinates,
                    fillColor: Color.deskFill,
                    strokeColor: Color.deskFill,
                    lineWidth: 0.01
                ))
            }
        }

        return (polygons, markers)
    }

    private func createPolygonData(from polygon: MKPolygon, feature: StylableFeature) -> MapPolygonData {
        let coordinates = extractCoordinates(from: polygon)
        var fillColor = Color.gray.opacity(0.3)
        var strokeColor = Color.gray
        var lineWidth: CGFloat = 1.0

        if let unit = feature as? Unit {
            switch unit.properties.category {
            case "unspecified":
                fillColor = Color(uiColor: UIColor(named: "NonPublicFill") ?? .orange)
                strokeColor = Color(uiColor: UIColor(named: "UnitStroke") ?? .gray)
                lineWidth = 1.3
            case "elevator", "stairs":
                fillColor = Color(uiColor: UIColor(named: "ElevatorFill") ?? .gray)
                strokeColor = Color(uiColor: UIColor(named: "UnitStroke") ?? .gray)
                lineWidth = 1.3
            case "restroom", "restroom.male", "restroom.female", "restroom.unisex.wheelchair":
                fillColor = Color(uiColor: UIColor(named: "RoomFill") ?? .gray)
                strokeColor = Color(uiColor: UIColor(named: "UnitStroke") ?? .gray)
                lineWidth = 1.3
            case "room", "auditorium", "conferenceroom", "phoneroom":
                fillColor = Color(uiColor: UIColor(named: "RoomFill") ?? .gray)
                strokeColor = Color(uiColor: UIColor(named: "UnitStroke") ?? .gray)
                lineWidth = 1.3
            case "walkway":
                fillColor = Color(uiColor: UIColor(named: "WalkwayFill") ?? .gray)
                strokeColor = Color(uiColor: UIColor(named: "UnitStroke") ?? .gray)
                lineWidth = 1.3
            case "lounge", "lobby", "kitchen", "storage":
                fillColor = Color(uiColor: UIColor(named: "LoungeFill") ?? .gray)
                strokeColor = Color(uiColor: UIColor(named: "LoungeStroke") ?? .gray)
                lineWidth = 1.3
            case "structure":
                fillColor = Color(uiColor: UIColor(named: "StructureFill") ?? .gray)
                strokeColor = Color(uiColor: UIColor(named: "UnitStroke") ?? .gray)
                lineWidth = 1.3
            default:
                fillColor = Color(uiColor: UIColor(named: "DefaultUnitFill") ?? .gray)
                strokeColor = Color(uiColor: UIColor(named: "UnitStroke") ?? .gray)
                lineWidth = 1.3
            }
        } else if feature is Level {
            fillColor = .clear
            strokeColor = Color(uiColor: UIColor(named: "LevelStroke") ?? .gray)
            lineWidth = 2.0
        }

        return MapPolygonData(
            coordinates: coordinates,
            fillColor: fillColor,
            strokeColor: strokeColor,
            lineWidth: lineWidth
        )
    }

    private func createMarkerData(from amenity: Amenity, category: POICategory) -> MapMarkerData? {
        guard amenity.coordinate.latitude != 0, amenity.coordinate.longitude != 0 else {
            return nil
        }

        return MapMarkerData(
            coordinate: amenity.coordinate,
            title: amenity.title!,
            category: category
        )
    }

//    private func createMarkerData(from occupant: Occupant, category: POICategory) -> MapMarkerData? {
//        guard occupant.coordinate.latitude != 0, occupant.coordinate.longitude != 0 else {
//            return nil
//        }
//
//        return MapMarkerData(
//            coordinate: occupant.coordinate,
//            title: occupant.title ?? "Occupant",
//            category: category,
//            annotation: occupant
//        )
//    }

    private func createMarkerDataFromUnit(_ unit: Unit, category: POICategory) -> MapMarkerData? {
        // Unit의 중심점 계산
        guard let polygon = unit.geometry.first as? MKPolygon else {
            return nil
        }

        let centroid = calculateCentroid(of: polygon)

        print(centroid)

        return MapMarkerData(
            coordinate: centroid,
            title: category.rawValue,
            category: category
        )
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

    private func extractCoordinates(from polygon: MKPolygon) -> [CLLocationCoordinate2D] {
        let points = polygon.points()
        var coordinates: [CLLocationCoordinate2D] = []
        for i in 0..<polygon.pointCount {
            coordinates.append(points[i].coordinate)
        }
        return coordinates
    }

    private func extractCoordinates(from polyline: MKPolyline) -> [CLLocationCoordinate2D] {
        let points = polyline.points()
        var coordinates: [CLLocationCoordinate2D] = []
        for i in 0..<polyline.pointCount {
            coordinates.append(points[i].coordinate)
        }
        return coordinates
    }
}

// MARK: - Map Data Models

struct MapPolygonData: Identifiable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
    let fillColor: Color
    let strokeColor: Color
    let lineWidth: CGFloat
}

struct MapMarkerData: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let category: POICategory
}
