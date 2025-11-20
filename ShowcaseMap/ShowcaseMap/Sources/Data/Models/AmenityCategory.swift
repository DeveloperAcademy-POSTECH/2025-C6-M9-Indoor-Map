//
//  AmenityCategory.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/16/25.
//

import SwiftUI

enum AmenityCategory: String, CaseIterable, Identifiable, Codable {
    case registrationDesk // 등록 데스크
    case informationDesk // 안내 데스크
    case restroom // 화장실
    case breakArea // 휴식 공간
    case diningArea // 취식 공간
    case coatroom // 코트룸
    case elevator // 엘리베이터
    case stairs // 계단

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .registrationDesk: return "등록 데스크"
        case .informationDesk: return "안내 데스크"
        case .restroom: return "화장실"
        case .breakArea: return "휴식 공간"
        case .diningArea: return "취식 공간"
        case .coatroom: return "코트룸"
        case .elevator: return "엘리베이터"
        case .stairs: return "계단"
        }
    }

    /// 연결할 SFsymbol 이름
    var symbolName: String {
        switch self {
        case .registrationDesk:
            return "person.text.rectangle"
        case .informationDesk:
            return "info.circle"
        case .restroom:
            return "toilet.fill"
        case .breakArea:
            return "sofa.fill"
        case .diningArea:
            return "fork.knife"
        case .coatroom:
            return "cabinet"
        case .elevator:
            return "arrow.up.arrow.down.square"
        case .stairs:
            return "stairs"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .stairs, .elevator:
            return .primary
        default:
            return Color(rawValue)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .stairs, .elevator:
            return Color.secondary.opacity(0.32)
        default:
            return Color(rawValue).opacity(0.1)
        }
    }

    // POICategory로 변환
    var toPOICategory: POICategory? {
        switch self {
        case .registrationDesk:
            return .registration
        case .informationDesk:
            return .information
        case .restroom:
            return .restroom
        case .breakArea:
            return .breakArea
        case .diningArea:
            return .dining
        case .coatroom:
            return .coatRoom
        case .elevator:
            return .elevator
        case .stairs:
            return .stairs
        }
    }
}
