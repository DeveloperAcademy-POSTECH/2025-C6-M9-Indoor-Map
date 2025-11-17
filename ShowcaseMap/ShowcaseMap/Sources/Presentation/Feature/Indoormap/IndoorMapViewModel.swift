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
    @Published var mapPolygons: [MapPolygonData] = []
    @Published var mapMarkers: [MapMarkerData] = []
    @Published var mapCameraPosition: MapCameraPosition = .automatic
    @Published var selectedLevelIndex: Int = 0 {
        didSet {
            updateMapData()
        }
    }
    @Published var selectedCategory: POICategory? = nil {
        didSet {
            updateMapData()
        }
    }
    @Published var selectedBooth: TeamInfo? = nil

    private let imdfStore = IMDFStore()
    private let locationManager = CLLocationManager()

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

    init() {
        locationManager.requestWhenInUseAuthorization()
    }

    func loadIMDFData() {
        imdfStore.loadIMDFData()

        // 카메라 포지션 설정
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
           let index = levels.firstIndex(of: level5) {
            selectedLevelIndex = index
        } else if !levels.isEmpty {
            selectedLevelIndex = 0
        }

        updateMapData()
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
    }

    // SwiftUI Map에서는 카메라 제한을 didSet에서 적용하면 무한 루프 발생
    // 대신 초기 카메라 위치만 설정하고, 사용자가 자유롭게 이동할 수 있도록 함
    // minZoomDistance, maxZoomDistance, cameraBoundary는 참고용으로 유지

    // 테스트용 표시입니다. 메인랩 Annotation 클릭하면 나옵니다.
    func handleAnnotationTap(_ annotation: MKAnnotation?) {
        guard let annotation = annotation else { return }

        // 메인랩 annotation을 탭하면 테스트용 부스 데이터 표시
        if let occupant = annotation as? Occupant {
            // Use bestLocalizedValue (or title as a fallback) instead of subscripting LocalizedName
            let localizedName = occupant.properties.name.bestLocalizedValue ?? occupant.title
            if localizedName == "메인랩" || localizedName == "MainLab" {
                selectedBooth = createMockBoothData()
            }
        }
    }

    private func createMockBoothData() -> TeamInfo {
        let mockMembers = [
            Learner(id: "딘", name: "Dean"),
            Learner(id: "제이", name: "Jay"),
            Learner(id: "앨리스", name: "Alice")
        ]

        return TeamInfo(
            boothNumber: "01",
            name: "테스트 팀",
            appName: "테스트 앱",
            appDescription: "이것은 BoothDetailSheetView를 테스트하기 위한 가상의 부스입니다. 메인랩을 탭하면 이 시트가 표시됩니다.",
            members: mockMembers,
            category: .productivity,
            downloadUrl: URL(string: "https://example.com")!,
            teamUrl: URL(string: "https://example.com/team")!
        )
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

