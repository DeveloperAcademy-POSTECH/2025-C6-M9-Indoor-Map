//
//  SearchViewModel.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/16/25.
//

import Foundation

@Observable
@MainActor
class SearchViewModel {
    var searchText: String = ""
    var teamInfoList: [TeamInfo] = []
    var currentLevelAmenities: [Amenity] = []

    private let repository: TeamInfoRepository
    
    init(repository: TeamInfoRepository = MockTeamRepository()) {
        self.repository = repository
    }
    
    // 부스검색
    var filteredTeamInfo: [TeamInfo] {
        guard !searchText.isEmpty else { return [] }
        
        let searchLowercased = searchText.lowercased()
        
        return teamInfoList.filter { teamInfo in
            // 앱 이름
            teamInfo.appName.lowercased().contains(searchLowercased) ||
            // 부스번호
            String(teamInfo.boothNumber).contains(searchText) ||
            // 멤버이름(본명이랑 영어이름 둘다)
            teamInfo.members.contains { member in
                member.name.lowercased().contains(searchLowercased) ||
                member.id.lowercased().contains(searchLowercased)
            }
        }
    }
    
    // 편의시설 검색
    var filteredAmenities: [Amenity] {
        guard !searchText.isEmpty else { return [] }

        let searchLowercased = searchText.lowercased()
        return currentLevelAmenities.filter { amenity in
            // 이름검색
            if let name = amenity.properties.name?.bestLocalizedValue,
               name.lowercased().contains(searchLowercased) {
                print("name\n", name)
                return true
            }
            return false
        }
    }
    
    func fetchTeamInfo() async {
        do {
            teamInfoList = try await repository.fetchTeamInfo()
        } catch {
            teamInfoList = []
        }
    }
}

