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

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .registration:
            return "person.text.rectangle"
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
        }
    }

    // Amenity 카테고리와 매핑
    var amenityCategories: [String] {
        switch self {
        case .restroom:
            return ["restroom.male", "restroom.female", "restroom.unisex.wheelchair"]
        case .elevator:
            return ["elevator"]
        case .stairs:
            return ["stairs"]
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

    // Helper method to get category from amenity category string
    static func from(amenityCategory: String) -> POICategory? {
        for category in POICategory.allCases {
            if category.amenityCategories.contains(amenityCategory) {
                return category
            }
        }
        return nil
    }

    // Helper method to get category from unit category string
    static func from(unitCategory: String) -> POICategory? {
        for category in POICategory.allCases {
            if category.unitCategories.contains(unitCategory) {
                return category
            }
        }
        return nil
    }
}
