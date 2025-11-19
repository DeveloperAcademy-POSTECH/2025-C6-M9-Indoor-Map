//
//  IndoorMapViewModel.swift
//  ShowcaseMap
//
//  Created by 딘은딘딘 on 11/15/25.
//

import CoreLocation
import MapKit
import SwiftUI

@Observable
@MainActor
class IndoorMapViewModel {
    var mapPolygons: [MapPolygonData] = []
    var mapMarkers: [MapMarkerData] = []
    var integrateMarkers: [IntegrateMarker] = []
    var mapCameraPosition: MapCameraPosition = .automatic
    var selectedLevelIndex: Int = 0 {
        didSet {
            updateMapData()
        }
    }

    var selectedCategory: POICategory? {
        didSet {
            updateMapData()
        }
    }

    var selectedBooth: TeamInfo?
    var teamInfos: [TeamInfo] = []
    private var allTeamInfos: [TeamInfo] = []
    var userLocation: CLLocationCoordinate2D?

    private let imdfStore: IMDFStore
    private let locationService = IndoorMapLocationManager()
    private let teamRepository: TeamInfoRepository = MockTeamRepository()

    // 카메라 제한 설정
    private let centerCoordinate = CLLocationCoordinate2D(latitude: 36.014267, longitude: 129.325778)
    private let minZoomDistance: CLLocationDistance = 10
    private let maxZoomDistance: CLLocationDistance = 250
    private let cameraBoundary = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.014267, longitude: 129.325778),
        latitudinalMeters: 180,
        longitudinalMeters: 80
    )

    var levels: [Level] {
        return imdfStore.levels
    }

    var fixtures: [Fixture] {
        return imdfStore.fixtures
    }

    var currentLevelName: String {
        guard !levels.isEmpty, selectedLevelIndex < levels.count else {
            return ""
        }
        let level = levels[selectedLevelIndex]
        return level.properties.shortName.bestLocalizedValue ?? "\(level.properties.ordinal + 1)"
    }

    init(imdfStore: IMDFStore) {
        self.imdfStore = imdfStore
        locationService.onLocationUpdate = { [weak self] coordinate in
            self?.userLocation = coordinate
        }
        locationService.requestAuthorization()
        locationService.startUpdating()
    }

    func loadIMDFData() {
        Task {
            do {
                allTeamInfos = try await teamRepository.fetchTeamInfo()
                updateMapData()
            } catch {
                print("Failed to load team info: \(error)")
            }
        }

        let centerCoordinate = CLLocationCoordinate2D(latitude: 36.014267, longitude: 129.325778)
        mapCameraPosition = .camera(
            MapCamera(
                centerCoordinate: centerCoordinate,
                distance: 250,
                heading: -23,
                pitch: 0
            )
        )

        // 초기 레벨 선택
        if let level5 = levels.first(where: { $0.properties.ordinal == 4 }),
           let index = levels.firstIndex(of: level5)
        {
            selectedLevelIndex = index
        } else if !levels.isEmpty {
            selectedLevelIndex = 0
        }
    }

    private func updateMapData() {
        guard !levels.isEmpty, selectedLevelIndex < levels.count else {
            return
        }

        let selectedLevel = levels[selectedLevelIndex]
        let ordinal = selectedLevel.properties.ordinal

        let data = imdfStore.getMapData(for: ordinal, category: selectedCategory)
        mapPolygons = data.polygons
        mapMarkers = data.markers

        teamInfos = allTeamInfos.filter { $0.levelId == ordinal }

        // 부스를 포함한 시설물들 다포함한 마커 생성
        var markers: [IntegrateMarker] = []

        // Amenity추가
        markers.append(contentsOf: data.markers.map { markerData in
            IntegrateMarker(
                id: markerData.id,
                type: .amenity(markerData),
                coordinate: markerData.coordinate,
                title: markerData.title
            )
        })

        // Booth추가 (카테고리에 포함되지않아서 체크하면 사라짐)
        if selectedCategory == nil {
            markers.append(contentsOf: teamInfos.map { teamInfo in
                IntegrateMarker(
                    id: teamInfo.id,
                    type: .booth(teamInfo),
                    coordinate: teamInfo.displayPoint,
                    title: teamInfo.name
                )
            })
        }

        // 추가

        integrateMarkers = markers
    }

    // 지금은 TeamInfo만이지만 추후 확장 예정
    func selectBooth(withId id: UUID) -> TeamInfo? {
        return teamInfos.first { $0.id == id }
    }

    /// 통합 마커 선택
    func selectMarker(withId id: UUID) -> IntegrateMarker? {
        return integrateMarkers.first { $0.id == id }
    }

    func moveCameraToSelectedBooth(coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.3)) {
            mapCameraPosition = .camera(
                MapCamera(
                    centerCoordinate: coordinate,
                    distance: 175,
                    heading: -23,
                    pitch: 0
                )
            )
        }
    }

    func moveCameraToUserLocation() {
        switch locationService.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationService.startUpdating()
        case .notDetermined:
            locationService.requestAuthorization()
        default:
            break
        }

        guard let coordinate = userLocation ?? locationService.lastKnownLocation else {
            locationService.requestSingleLocation()
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            mapCameraPosition = .camera(
                MapCamera(
                    centerCoordinate: coordinate,
                    distance: 100,
                    heading: -23,
                    pitch: 0
                )
            )
        }
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
