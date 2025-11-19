//
//  IntegrateMarker.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/19/25.
//

import CoreLocation
import SwiftUI

/// 마커 타입을 구분하는 열거형
enum MarkerType {
    case booth(TeamInfo)
    case amenity(MapMarkerData)
}

/// 마커로 보여줄만한 아이템들 (부스 , 편의시설 +a(추가예정))
struct IntegrateMarker: Identifiable {
    let id: UUID
    let type: MarkerType
    let coordinate: CLLocationCoordinate2D
    let title: String

    init(id: UUID, type: MarkerType, coordinate: CLLocationCoordinate2D, title: String) {
        self.id = id
        self.type = type
        self.coordinate = coordinate
        self.title = title
    }

    var iconName: String {
        switch type {
        case .booth:
            return "mappin"
        case .amenity(let data):
            return data.category.iconName
        }
    }

    var tintColor: Color {
        switch type {
        case .booth:
            return .teal
        case .amenity:
            return .blue
        }
    }

    // MARK: - Type-Safe Accessors

    /// Booth 타입일 경우 TeamInfo 반환
    var teamInfo: TeamInfo? {
        if case .booth(let info) = type {
            return info
        }
        return nil
    }

    /// Amenity 타입일 경우 MapMarkerData 반환
    var amenityData: MapMarkerData? {
        if case .amenity(let data) = type {
            return data
        }
        return nil
    }

    /// Booth 마커 여부
    var isBooth: Bool {
        if case .booth = type { return true }
        return false
    }

    /// Amenity 마커 여부
    var isAmenity: Bool {
        if case .amenity = type { return true }
        return false
    }
}
