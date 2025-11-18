//
//  AppCategory.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//
import Foundation

enum AppCategory: String, CaseIterable, Identifiable, Codable {
    case medical // 의료
    case productivity // 생산성
    case graphicsAndDesign // 그래픽 및 디자인
    case government // 정부
    case lifestyle // 라이프스타일
    case navigation // 내비게이션
    case photoAndVideo // 사진 및 비디오
    case education // 교육
    case utility // 유틸리티
    case healthAndFitness // 건강 및 피트니스
    case news // 뉴스
    case entertainment // 엔터테인먼트
    case socialNetworking // 소셜 네트워킹
    case music // 음악
    case other // 기타 (예비용)

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .medical: return "의료"
        case .productivity: return "생산성"
        case .graphicsAndDesign: return "그래픽 및 디자인"
        case .government: return "정부"
        case .lifestyle: return "라이프스타일"
        case .navigation: return "내비게이션"
        case .photoAndVideo: return "사진 및 비디오"
        case .education: return "교육"
        case .utility: return "유틸리티"
        case .healthAndFitness: return "건강 및 피트니스"
        case .news: return "뉴스"
        case .entertainment: return "엔터테인먼트"
        case .socialNetworking: return "소셜 네트워킹"
        case .music: return "음악"
        case .other: return "기타"
        }
    }

    // Add this:
    var systemImageName: String {
        switch self {
        case .medical: return "cross.case.fill"
        case .productivity: return "checklist"
        case .graphicsAndDesign: return "paintpalette.fill"
        case .government: return "building.columns.fill"
        case .lifestyle: return "leaf.fill"
        case .navigation: return "location.fill"
        case .photoAndVideo: return "camera.fill"
        case .education: return "book.fill"
        case .utility: return "wrench.and.screwdriver.fill"
        case .healthAndFitness: return "figure.run"
        case .news: return "newspaper.fill"
        case .entertainment: return "party.popper.fill"
        case .socialNetworking: return "person.2.fill"
        case .music: return "music.note"
        case .other: return "square.grid.2x2.fill"
        }
    }
}
