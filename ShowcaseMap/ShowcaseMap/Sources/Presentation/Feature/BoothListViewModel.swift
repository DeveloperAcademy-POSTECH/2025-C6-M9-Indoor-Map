//
//  BoothListViewModel.swift
//  ShowcaseMap
//
//  Created by bishoe01 on 11/15/25.
//

import Foundation

@Observable
@MainActor
class BoothListViewModel {
    var teamInfoList: [TeamInfo] = []
    
    private let repository: TeamInfoRepository
    
    init(repository: TeamInfoRepository = MockTeamRepository()) {
        self.repository = repository
    }
    
    func fetchTeamInfo() async {
        do {
            teamInfoList = try await repository.fetchTeamInfo()
        } catch {
            teamInfoList = []
        }
    }
}
    
