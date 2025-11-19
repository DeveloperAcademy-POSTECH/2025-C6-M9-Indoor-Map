/*
 Category Model for filtering amenities and units
 */

import Foundation
import UIKit

enum POICategory: String, CaseIterable, Identifiable {
    case registration = "등록데스크"
    case information = "안내데스크"
    case restroom = "화장실"
    case breakArea = "휴식 공간"
    case dining = "취식 공간"
    case coatRoom = "코트룸"
    case elevator = "엘리베이터"
    case stairs = "계단"
    case photobooth = "포토부스"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .registration:
            return "checkmark.circle.fill"
        case .information:
            return "info.circle"
        case .restroom:
            return "toilet"
        case .breakArea:
            return "chair.lounge"
        case .dining:
            return "fork.knife"
        case .coatRoom:
            return "cabinet"
        case .elevator:
            return "arrow.up.arrow.down"
        case .stairs:
            return "figure.stairs"
        case .photobooth:
            return "person.crop.square.badge.camera"
        }
    }

    // Amenity 카테고리와 매핑
    var amenityCategories: [String] {
        switch self {
        case .restroom:
            return ["restroom", "restroom.male", "restroom.female", "restroom.unisex.wheelchair"]
        case .elevator:
            return ["elevator"]
        case .stairs:
            return ["stairs"]
        case .breakArea:
            return ["breakarea"]
        case .dining:
            return ["diningarea"]
        case .coatRoom:
            return ["coatroom"]
        case .registration:
            return ["registrationdesk"]
        case .information:
            return ["informationdesk"]
        case .photobooth:
            return ["photobooth"]
        default:
            return []
        }
    }

    // Unit 카테고리와 매핑
    var unitCategories: [String] {
        switch self {
        case .registration, .information:
            return ["lobby"]
        case .dining:
            return ["foodservice"]
        default:
            return []
        }
    }

    var hasData: Bool {
        return !amenityCategories.isEmpty || !unitCategories.isEmpty
    }

    // Amenity -> POICategory
    static func from(amenityCategory: String) -> POICategory? {
        for category in POICategory.allCases {
            if category.amenityCategories.contains(amenityCategory) {
                return category
            }
        }
        return nil
    }

    // Unit -< POICategory
    static func from(unitCategory: String) -> POICategory? {
        for category in POICategory.allCases {
            if category.unitCategories.contains(unitCategory) {
                return category
            }
        }
        return nil
    }
}
